format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printString@@u8
        ;   rsp+24: arg str
_printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length.1{r2}, length.1{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+32: arg chr
_printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; move t.1.1{r1}, t.1.1{r9}
        mov rdi, r12
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+0: arg number
_printUint@i16:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+24: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos.1{r8}, 20
        mov bl, 20
        ; 33:2 while true
        ; move number.1{r5}, number{r1}
        mov r8, rdi
_while_1:
        ; sub pos.3{r8}, 1
        sub bl, 1
        ; move remainder.1{r6}, number.1{r5}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r6}
        mov rax, r9
        ; mod remainder.1{r3}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r6}, remainder.1{r3}
        mov r9, rdx
        ; move number.2{r0}, number.2{r5}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r5}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r6}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r8}(u8)
        movzx rdx, bl
        ; addrof t.6.1{r4}, buffer
        lea rcx, [rsp+40]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; store [t.6.2{r4}], digit.1{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number.2{r5} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; move t.9.1{r0}, t.9.1{r3}
        mov rax, rdx
        ; addrof t.8.1{r3}, buffer
        lea rdx, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rdi, rdx
        ; move t.8.2{r1}, t.8.2{r4}
        mov rdi, rcx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov sil, al
        ; sub t.10.1{r2}, pos.3{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rsi, 0
        ; 69:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rsi
        jmp _for_3
_for_3_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_3:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_3_body
        cmp sil, 0
        jne _for_3_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void initRandom@i32
        ;   rsp+0: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.1.1{r0}, salt{r1}
        mov eax, edi
        ; addrof a.2.1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.2.1{r1}], t.1.1{r0}
        mov [rdi], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.5.1{r1}, __random__
        lea rdi, [var_0]
        ; load r.1{r1}, [a.5.1{r1}]
        mov edi, [rdi]
        ; move t.6.1{r2}, r.1{r1}
        mov esi, edi
        ; and t.6.1{r2}, 524287
        and esi, 524287
        ; mul b.1{r2}, 48271
        movsxd rsi, esi
        imul  rsi, 48271
        ; shiftright t.7.1{r1}, 15
        sar edi, 15
        ; mul c.1{r1}, 48271
        movsxd rdi, edi
        imul  rdi, 48271
        ; move t.8.1{r3}, c.1{r1}
        mov edx, edi
        ; and t.8.1{r3}, 65535
        and edx, 65535
        ; shiftleft d.1{r3}, 15
        sal edx, 15
        ; shiftright t.10.1{r1}, 16
        sar edi, 16
        ; add t.9.1{r1}, b.1{r2}
        add edi, esi
        ; add e.1{r1}, d.1{r3}
        add edi, edx
        ; move t.12.1{r2}, e.1{r1}
        mov esi, edi
        ; and t.12.1{r2}, 2147483647
        and esi, 2147483647
        ; shiftright t.13.1{r1}, 31
        sar edi, 31
        ; add t.11.1{r2}, t.13.1{r1}
        add esi, edi
        ; addrof a.14.1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.14.1{r1}], t.11.1{r2}
        mov [rdi], esi
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r2}
        mov eax, esi
        add rsp, 8
        ret

        ; i16 random16
_random16:
        sub rsp, 8
        ; 20:23 return (i16) & 32767
        ; call t.2.1{r0} = random[] -> i32
        call _random
        ; cast t.1.1{r1}(i16), t.2.1{r0}(i32)
        mov di, ax
        ; move t.0.1{r0}, t.1.1{r1}
        mov ax, di
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
_rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 40 + column
        ; mul t.3.1{r1}, 40
        movsx rdi, di
        imul  rdi, 40
        ; move t.2.1{r0}, t.3.1{r1}
        mov ax, di
        ; add t.2.1{r0}, column{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
_getCell@i16@i16:
        sub rsp, 8
        ; 20:15 return [...]
        ; call t.5.1{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4.1{r1}(i64), t.5.1{r0}(i16)
        movsx rdi, ax
        ; addrof t.3.1{r2}, field
        lea rsi, [var_1]
        ; add t.3.2{r2}, t.4.1{r1}
        add rsi, rdi
        ; load t.2.1{r0}, [t.3.2{r2}]
        mov al, [rsi]
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+0: arg cell
_isBomb@u8:
        sub rsp, 8
        ; 24:27 return cell & 1 != 0
        ; and t.2.1{r1}, 1
        and dil, 1
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+0: arg cell
_isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; and t.2.1{r1}, 2
        and dil, 2
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+0: arg cell
_isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; and t.2.1{r1}, 4
        and dil, 4
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
_checkCellBounds@i16@i16:
        sub rsp, 8
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 36:40 logic and
        ; 36:21 logic and
        ; gteq t.2.1{r3}, row{r1}, 0
        cmp di, 0
        setge dl
        ; branch t.2.1{r3} notequals 0: and_2nd_6
        cmp dl, 0
        jne _and_2nd_6
        ; move t.2.2{r1}, t.2.1{r3}
        mov dil, dl
        jmp _and_next_6
_and_2nd_6:
        ; lt t.2.3{r1}, row{r1}, 20
        cmp di, 20
        setl dil
_and_next_6:
        ; branch t.2.2{r1} equals 0: and_next_5
        cmp dil, 0
        je _and_next_5
        ; gteq t.2.5{r1}, column{r2}, 0
        cmp si, 0
        setge dil
_and_next_5:
        ; branch t.2.4{r1} notequals 0: and_2nd_4
        cmp dil, 0
        jne _and_2nd_4
        ; move t.2.6{r0}, t.2.4{r1}
        mov al, dil
        jmp _checkCellBounds@i16@i16_ret
_and_2nd_4:
        ; lt t.2.7{r1}, column{r2}, 40
        cmp si, 40
        setl dil
        ; move t.2.6{r0}, t.2.7{r1}
        mov al, dil
_checkCellBounds@i16@i16_ret:
        add rsp, 8
        ret

        ; void setCell@i16@i16@u8
        ;   rsp+24: arg row
        ;   rsp+26: arg column
        ;   rsp+28: arg cell
_setCell@i16@i16@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move cell{r8}, cell{r3}
        mov bl, dl
        ; call t.5.1{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r1}, field
        lea rdi, [var_1]
        ; add t.3.2{r1}, t.4.1{r0}
        add rdi, rax
        ; store [t.3.2{r1}], cell{r8}
        mov [rdi], bl
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; u8 getBombCountAround@i16@i16
        ;   rsp+32: arg row
        ;   rsp+34: arg column
        ;   rsp+36: var dr.2
        ;   rsp+38: var r.1
        ;   rsp+40: var count.3
        ;   rsp+42: var dc.2
        ;   rsp+44: var c.1
        ;   rsp+46: var count.4
_getBombCountAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; const count.1{r0}, 0
        mov al, 0
        ; const dr.1{r3}, -1
        mov dx, -1
        ; 46:2 for dr <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; move dr.2{r2}, dr.2{r3}
        mov si, dx
        jmp _for_7
_for_7_body:
        ; move dr.2{r3}, dr.2{r2}
        mov dx, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move r.1{r1}, row{r8}
        mov di, bx
        ; add r.1{r1}, dr.2{r3}
        add di, dx
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr.2{r3}
        mov [r12], dx
        ; const dc.1{r3}, -1
        mov dx, -1
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], count.3{r0}
        mov [r12], al
        ; move dc.2{r0}, dc.1{r3}
        mov ax, dx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r.1{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+40]
        ; load count.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move dc.2{r2}, dc.2{r0}
        mov si, ax
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], count.3{r1}
        mov [r12], dil
        ; move dc.2{r0}, dc.2{r2}
        mov ax, si
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; load r.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move c.1{r3}, column{r2}
        mov dx, si
        ; add c.1{r3}, dc.2{r0}
        add dx, ax
        ; addrof memVarAddr{r9}, dc.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], dc.2{r0}
        mov [r12], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; move c.1{r2}, c.1{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], c.1{r3}
        mov [r12], dx
        ; call t.8.1{r0} = checkCellBounds@i16@i16[r.1{r1}, c.1{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8.1{r0} notequals 0: if_9_then
        cmp al, 0
        jne _if_9_then
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+40]
        ; load count.3{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, count.4
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], count.4{r0}
        mov [r12], al
        ; move count.4{r1}, count.4{r0}
        mov dil, al
        jmp _for_8_continue
_if_9_then:
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; load r.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+44]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call cell.1{r0} = getCell@i16@i16[r.1{r1}, c.1{r2}] -> u8
        call _getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; call t.9.1{r0} = isBomb@u8[cell.1{r1}] -> bool
        call _isBomb@u8
        ; branch t.9.1{r0} notequals 0: if_10_then
        cmp al, 0
        jne _if_10_then
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+40]
        ; load count.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _for_8_continue
_if_10_then:
        ; addrof memVarAddr{r9}, count.3
        lea r12, [rsp+40]
        ; load count.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add count.5{r1}, 1
        add dil, 1
_for_8_continue:
        ; addrof memVarAddr{r9}, dc.2
        lea r12, [rsp+42]
        ; load dc.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add dc.4{r2}, 1
        add si, 1
_for_8:
        ; branch dc.2{r2} lteq 1: for_8_body
        cmp si, 1
        jle _for_8_body
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; load dr.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add dr.4{r2}, 1
        add si, 1
        ; move count.2{r0}, count.3{r1}
        mov al, dil
_for_7:
        ; branch dr.2{r2} lteq 1: for_7_body
        cmp si, 1
        jle _for_7_body
        ; 58:9 return count
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; u8 getSpacer@i16@i16@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
        ;   rsp+4: arg rowCursor
        ;   rsp+6: arg columnCursor
_getSpacer@i16@i16@i16@i16:
        sub rsp, 8
        ; branch rowCursor{r3} notequals row{r1}: if_11_end
        cmp dx, di
        jne _if_11_end
        ; branch columnCursor{r4} equals column{r2}: if_12_then
        cmp cx, si
        je _if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.4.1{r1}, column{r2}
        mov di, si
        ; sub t.4.1{r1}, 1
        sub di, 1
        ; branch columnCursor{r4} notequals t.4.1{r1}: if_11_end, if_13_then
        cmp cx, di
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
        ;   rsp+32: arg cell
        ;   rsp+34: arg row
        ;   rsp+36: arg column
        ;   rsp+38: var chr.1
_printCell@u8@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dx
        ; const chr.1{r0}, 46
        mov al, 46
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], al
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; call t.5.1{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.5.1{r0} notequals 0: if_14_then
        cmp al, 0
        jne _if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.7.1{r0} = isFlag@u8[cell{r1}] -> bool
        call _isFlag@u8
        ; branch t.7.1{r0} equals 0: printCell@u8@i16@i16.no_critical_edge_10, if_17_then
        cmp al, 0
        je _printCell@u8@i16@i16.no_critical_edge_10
        jmp _if_17_then
_if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6.1{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.6.1{r0} equals 0: if_15_else, if_15_then
        cmp al, 0
        je _if_15_else
        jmp _if_15_then
_printCell@u8@i16@i16.no_critical_edge_10:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+38]
        ; load chr.1{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        jmp _if_14_end
_if_17_then:
        ; const chr.3{r8}, 35
        mov bl, 35
        jmp _if_14_end
_if_15_else:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+34]
        ; load row{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move row{r1}, row{r2}
        mov di, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+36]
        ; load column{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; move column{r2}, column{r3}
        mov si, dx
        ; call count.1{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; 81:4 if count > 0
        ; branch count.1{r0} lteq 0: if_16_else, if_16_then
        cmp al, 0
        jbe _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr.4{r8}, 42
        mov bl, 42
        jmp _if_14_end
_if_16_else:
        ; const chr.5{r8}, 32
        mov bl, 32
        jmp _if_14_end
_if_16_then:
        ; move chr.6{r8}, count.1{r0}
        mov bl, al
        ; add chr.6{r8}, 48
        add bl, 48
_if_14_end:
        ; move chr.2{r1}, chr.2{r8}
        mov dil, bl
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printField@i16@i16
        ;   rsp+32: arg rowCursor
        ;   rsp+34: arg columnCursor
        ;   rsp+36: var row.2
        ;   rsp+38: var column.2
_printField@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move rowCursor{r8}, rowCursor{r1}
        mov bx, di
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r2}
        mov [r12], si
        ; const arg.0.0{r1}, 0
        mov di, 0
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row.1{r0}, 0
        mov ax, 0
        ; 97:2 for row < 20
        ; move row.2{r1}, row.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], di
        jmp _for_18
_for_18_body:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], di
        ; const arg.1.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column.1{r0}, 0
        mov ax, 0
        ; 99:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov si, ax
        jmp _for_19
_for_19_body:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], si
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; load columnCursor{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; call spacer.2{r0} = getSpacer@i16@i16@i16@i16[row.2{r1}, column.2{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer.2{r1}, spacer.2{r0}
        mov dil, al
        ; call printChar@u8[spacer.2{r1}]
        call _printChar@u8
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+38]
        ; load column.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call cell.1{r0} = getCell@i16@i16[row.2{r1}, column.2{r2}] -> u8
        call _getCell@i16@i16
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+38]
        ; load column.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; call printCell@u8@i16@i16[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@i16@i16
        ; load column.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move column.3{r0}, column.2{r2}
        mov ax, si
        ; add column.3{r0}, 1
        add ax, 1
        ; move column.2{r2}, column.3{r0}
        mov si, ax
_for_19:
        ; branch column.2{r2} lt 40: for_19_body
        cmp si, 40
        jl _for_19_body
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; load columnCursor{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move columnCursor{r4}, columnCursor{r2}
        mov cx, si
        ; const arg.6.1{r2}, 40
        mov si, 40
        ; call spacer.1{r0} = getSpacer@i16@i16@i16@i16[row.2{r1}, arg.6.1{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer.1{r1}, spacer.1{r0}
        mov dil, al
        ; call printChar@u8[spacer.1{r1}]
        call _printChar@u8
        ; const t.7.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+36]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move row.4{r0}, row.2{r1}
        mov ax, di
        ; add row.4{r0}, 1
        add ax, 1
        ; move row.2{r1}, row.4{r0}
        mov di, ax
_for_18:
        ; branch row.2{r1} lt 20: for_18_body
        cmp di, 20
        jl _for_18_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printSpaces@i16
        ;   rsp+24: arg i
_printSpaces@i16:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move i.1{r8}, i{r1}
        mov bx, di
        jmp _for_20
_for_20_body:
        ; const arg.0.0{r1}, 48
        mov dil, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; move i.2{r0}, i.1{r8}
        mov ax, bx
        ; sub i.2{r0}, 1
        sub ax, 1
        ; move i.1{r8}, i.2{r0}
        mov bx, ax
_for_20:
        ; branch i.1{r8} gt 0: for_20_body
        cmp bx, 0
        jg _for_20_body
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; u8 getDigitCount@i16
        ;   rsp+0: arg value
_getDigitCount@i16:
        sub rsp, 8
        ; const count.1{r2}, 0
        mov sil, 0
        ; 119:2 if value < 0
        ; branch value{r1} gteq 0: while_22
        cmp di, 0
        jge _while_22
        ; const count.3{r2}, 1
        mov sil, 1
        ; neg value.2{r1}, value{r1}
        neg rdi
_while_22:
        ; add count.5{r2}, 1
        add sil, 1
        ; move value.4{r0}, value.4{r1}
        mov ax, di
        ; div value.4{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move value.4{r1}, value.4{r0}
        mov di, ax
        ; 127:3 if value == 0
        ; branch value.4{r1} notequals 0: while_22
        cmp di, 0
        jne _while_22
        ; 132:9 return count
        ; move count.5{r0}, count.5{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+32: var r.2
        ;   rsp+34: var c.2
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const count.1{r8}, 0
        mov bx, 0
        ; const r.1{r0}, 0
        mov ax, 0
        ; 137:2 for r < 20
        ; move r.2{r1}, r.1{r0}
        mov di, ax
        jmp _for_24
_for_24_body:
        ; const c.1{r0}, 0
        mov ax, 0
        ; 138:3 for c < 40
        ; move c.2{r2}, c.1{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], di
        jmp _for_25
_for_25_body:
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], si
        ; call cell.1{r0} = getCell@i16@i16[r.2{r1}, c.2{r2}] -> u8
        call _getCell@i16@i16
        ; 140:4 if cell & 6 == 0
        ; move t.4.1{r1}, cell.1{r0}
        mov dil, al
        ; and t.4.1{r1}, 6
        and dil, 6
        ; branch t.4.1{r1} equals 0: if_26_then
        cmp dil, 0
        je _if_26_then
        ; move count.4{r1}, count.3{r8}
        mov di, bx
        jmp _for_25_continue
_if_26_then:
        ; move count.5{r1}, count.3{r8}
        mov di, bx
        ; add count.5{r1}, 1
        add di, 1
_for_25_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+34]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add c.4{r2}, 1
        add si, 1
        ; move count.3{r8}, count.4{r1}
        mov bx, di
_for_25:
        ; branch c.2{r2} lt 40: for_25_body
        cmp si, 40
        jl _for_25_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add r.4{r1}, 1
        add di, 1
_for_24:
        ; branch r.2{r1} lt 20: for_24_body
        cmp di, 20
        jl _for_24_body
        ; 145:9 return count
        ; move count.2{r0}, count.2{r8}
        mov ax, bx
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+32: var leftDigits.1
        ;   rsp+34: var bombDigits.1
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call count.1{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count.1{r8}, count.1{r0}
        mov bx, ax
        ; move count.1{r1}, count.1{r8}
        mov di, bx
        ; call t.3.1{r0} = getDigitCount@i16[count.1{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits.1{r0}(i16), t.3.1{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, leftDigits.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], leftDigits.1{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 40
        mov di, 40
        ; call t.4.1{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits.1{r0}(i16), t.4.1{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, bombDigits.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombDigits.1{r0}
        mov [r12], ax
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 6
        mov si, 6
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; load bombDigits.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.5.1{r1}, bombDigits.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, leftDigits.1
        lea r12, [rsp+32]
        ; load leftDigits.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.5.1{r1}, leftDigits.1{r0}
        sub di, ax
        ; call printSpaces@i16[t.5.1{r1}]
        call _printSpaces@i16
        ; move count.1{r1}, count.1{r8}
        mov di, bx
        ; call printUint@i16[count.1{r1}]
        call _printUint@i16
        ; 156:15 return count == 0
        ; equals t.6.1{r0}, count.1{r8}, 0
        cmp bx, 0
        sete al
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 abs@i16
        ;   rsp+0: arg a
_abs@i16:
        sub rsp, 8
        ; branch a{r1} lt 0: if_27_then
        cmp di, 0
        jl _if_27_then
        ; 163:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_27_then:
        ; 161:10 return -a
        ; neg t.1.1{r1}, a{r1}
        neg rdi
        ; move t.1.1{r0}, t.1.1{r1}
        mov ax, di
_abs@i16_ret:
        add rsp, 8
        ret

        ; void clearField
_clearField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const r.1{r8}, 0
        mov bx, 0
        ; 167:2 for r < 20
        jmp _for_28
_for_28_body:
        ; const c.1{r9}, 0
        mov r12w, 0
        ; 168:3 for c < 40
        jmp _for_29
_for_29_body:
        ; move r.2{r1}, r.2{r8}
        mov di, bx
        ; move c.2{r2}, c.2{r9}
        mov si, r12w
        ; const arg.0.2{r3}, 0
        mov dl, 0
        ; call setCell@i16@i16@u8[r.2{r1}, c.2{r2}, arg.0.2{r3}]
        call _setCell@i16@i16@u8
        ; move c.3{r0}, c.2{r9}
        mov ax, r12w
        ; add c.3{r0}, 1
        add ax, 1
        ; move c.2{r9}, c.3{r0}
        mov r12w, ax
_for_29:
        ; branch c.2{r9} lt 40: for_29_body
        cmp r12w, 40
        jl _for_29_body
        ; move r.4{r0}, r.2{r8}
        mov ax, bx
        ; add r.4{r0}, 1
        add ax, 1
        ; move r.2{r8}, r.4{r0}
        mov bx, ax
_for_28:
        ; branch r.2{r8} lt 20: for_28_body
        cmp bx, 20
        jl _for_28_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void initField@i16@i16
        ;   rsp+32: arg curr_r
        ;   rsp+34: arg curr_c
        ;   rsp+36: var bombs.2
        ;   rsp+38: var row.1
        ;   rsp+40: var column.1
_initField@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move curr_r{r8}, curr_r{r1}
        mov bx, di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; const bombs.1{r0}, 40
        mov ax, 40
        ; 175:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        jmp _for_30
_for_30_body:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        ; call t.5.1{r0} = random16[] -> i16
        call _random16
        ; move row.1{r1}, t.5.1{r0}
        mov di, ax
        ; mod row.1{r3}, row.1{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row.1{r1}, row.1{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row.1{r1}
        mov [r12], di
        ; call t.6.1{r0} = random16[] -> i16
        call _random16
        ; move column.1{r2}, t.6.1{r0}
        mov si, ax
        ; mod column.1{r3}, column.1{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move column.1{r2}, column.1{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column.1{r2}
        mov [r12], si
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.8.1{r1}, row.1{r0}
        mov di, ax
        ; sub t.8.1{r1}, curr_r{r8}
        sub di, bx
        ; call t.7.1{r0} = abs@i16[t.8.1{r1}] -> i16
        call _abs@i16
        ; branch t.7.1{r0} gt 1: if_31_then
        cmp ax, 1
        jg _if_31_then
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.10.1{r1}, column.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; sub t.10.1{r1}, curr_c{r2}
        sub di, si
        ; call t.9.1{r0} = abs@i16[t.10.1{r1}] -> i16
        call _abs@i16
        ; branch t.9.1{r0} lteq 1: for_30_continue, if_31_then
        cmp ax, 1
        jle _for_30_continue
_if_31_then:
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move row.1{r1}, row.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move column.1{r2}, column.1{r0}
        mov si, ax
        ; const arg.4.2{r3}, 1
        mov dl, 1
        ; call setCell@i16@i16@u8[row.1{r1}, column.1{r2}, arg.4.2{r3}]
        call _setCell@i16@i16@u8
_for_30_continue:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; load bombs.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs.5{r0}, 1
        sub ax, 1
_for_30:
        ; branch bombs.2{r0} gt 0: for_30_body
        cmp ax, 0
        jg _for_30_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void maybeRevealAround@i16@i16
        ;   rsp+32: arg row
        ;   rsp+34: arg column
        ;   rsp+36: var dr.2
        ;   rsp+38: var r.1
        ;   rsp+40: var dc.2
        ;   rsp+42: var c.1
        ;   rsp+44: var cell.1
_maybeRevealAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call t.7.1{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; branch t.7.1{r0} notequals 0: maybeRevealAround@i16@i16_ret
        cmp al, 0
        jne _maybeRevealAround@i16@i16_ret
        ; const dr.1{r0}, -1
        mov ax, -1
        ; 190:2 for dr <= 1
        jmp _for_34
_for_34_body:
        ; move r.1{r1}, row{r8}
        mov di, bx
        ; add r.1{r1}, dr.2{r0}
        add di, ax
        ; const dc.1{r3}, -1
        mov dx, -1
        ; 192:3 for dc <= 1
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r.1{r1}
        mov [r12], di
        ; move dc.2{r0}, dc.2{r3}
        mov ax, dx
        jmp _for_35
_for_35_body:
        ; move dc.2{r3}, dc.2{r0}
        mov dx, ax
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; load dr.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; load r.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; branch dr.2{r0} notequals 0: maybeRevealAround@i16@i16.no_critical_edge_15, and_37
        cmp ax, 0
        jne _maybeRevealAround@i16@i16.no_critical_edge_15
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        jmp _and_37
_maybeRevealAround@i16@i16.no_critical_edge_15:
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr.2{r0}
        mov [r12], ax
        jmp _if_36_end
_and_37:
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], dr.2{r0}
        mov [r12], ax
        ; branch dc.2{r3} notequals 0: if_36_end
        cmp dx, 0
        jne _if_36_end
        ; addrof memVarAddr{r9}, dc.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dc.2{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r.1{r1}
        mov [r12], di
        jmp _for_35_continue
_if_36_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move c.1{r0}, column{r2}
        mov ax, si
        ; add c.1{r0}, dc.2{r3}
        add ax, dx
        ; addrof memVarAddr{r9}, dc.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dc.2{r3}
        mov [r12], dx
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r.1{r1}
        mov [r12], di
        ; move c.1{r2}, c.1{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c.1{r0}
        mov [r12], ax
        ; call t.8.1{r0} = checkCellBounds@i16@i16[r.1{r1}, c.1{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8.1{r0} equals 0: for_35_continue
        cmp al, 0
        je _for_35_continue
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; load r.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+42]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call cell.1{r0} = getCell@i16@i16[r.1{r1}, c.1{r2}] -> u8
        call _getCell@i16@i16
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], cell.1{r0}
        mov [r12], al
        ; call t.9.1{r0} = isOpen@u8[cell.1{r1}] -> bool
        call _isOpen@u8
        ; branch t.9.1{r0} notequals 0: for_35_continue
        cmp al, 0
        jne _for_35_continue
        ; load cell.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.10.1{r3}, cell.1{r0}
        mov dl, al
        ; or t.10.1{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; load r.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+42]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call setCell@i16@i16@u8[r.1{r1}, c.1{r2}, t.10.1{r3}]
        call _setCell@i16@i16@u8
        ; addrof memVarAddr{r9}, r.1
        lea r12, [rsp+38]
        ; load r.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+42]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call maybeRevealAround@i16@i16[r.1{r1}, c.1{r2}]
        call _maybeRevealAround@i16@i16
_for_35_continue:
        ; addrof memVarAddr{r9}, dc.2
        lea r12, [rsp+40]
        ; load dc.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add dc.5{r0}, 1
        add ax, 1
_for_35:
        ; branch dc.2{r0} lteq 1: for_35_body
        cmp ax, 1
        jle _for_35_body
        ; addrof memVarAddr{r9}, dr.2
        lea r12, [rsp+36]
        ; load dr.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add dr.4{r0}, 1
        add ax, 1
_for_34:
        ; branch dr.2{r0} lteq 1: for_34_body, maybeRevealAround@i16@i16_ret
        cmp ax, 1
        jle _for_34_body
_maybeRevealAround@i16@i16_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var curr_c.1
        ;   rsp+34: var curr_r.1
        ;   rsp+36: var curr_c.2
        ;   rsp+38: var curr_r.2
        ;   rsp+40: var cell.1
        ;   rsp+41: var cell.3
_main:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const t.6.1{r8}, 0
        mov ebx, 0
        ; addrof a.7.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.7.1{r0}], t.6.1{r8}
        mov [rax], ebx
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize.1{r8}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; const curr_c.1{r0}, 20
        mov ax, 20
        ; addrof memVarAddr{r9}, curr_c.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.1{r0}
        mov [r12], ax
        ; const curr_r.1{r0}, 10
        mov ax, 10
        ; addrof memVarAddr{r9}, curr_r.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r.1{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 20
        mov di, 20
        ; const arg.2.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; const t.8.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
        ; 221:2 while true
        ; addrof memVarAddr{r9}, curr_c.1
        lea r12, [rsp+32]
        ; load curr_c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c.2{r2}, curr_c.1{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r.1
        lea r12, [rsp+34]
        ; load curr_r.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r.2{r1}, curr_r.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        jmp _while_40
_if_41_then:
        ; 224:4 if printLeft([])
        ; call t.9.1{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.9.1{r0} notequals 0: if_42_then, if_41_end
        cmp al, 0
        jne _if_42_then
_if_41_end:
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; move chr.1{r5}, chr.1{r0}
        mov r8w, ax
        ; 231:3 if chr == 27
        ; branch chr.1{r5} equals 27: main_ret
        cmp r8w, 27
        je _main_ret
        ; branch chr.1{r5} equals -8120: if_44_then
        cmp r8w, -8120
        je _if_44_then
        ; branch chr.1{r5} notequals -8112: if_45_else, if_45_then
        cmp r8w, -8112
        jne _if_45_else
        jmp _if_45_then
_if_44_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.12.1{r5}, curr_r.2{r1}
        mov r8w, di
        ; add t.12.1{r5}, 20
        add r8w, 20
        ; sub t.11.1{r5}, 1
        sub r8w, 1
        ; move curr_r.4{r0}, curr_r.4{r5}
        mov ax, r8w
        ; mod curr_r.4{r3}, curr_r.4{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move curr_r.4{r5}, curr_r.4{r3}
        mov r8w, dx
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move curr_r.2{r1}, curr_r.4{r5}
        mov di, r8w
        jmp _while_40
_if_45_else:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; branch chr.1{r5} notequals -8117: if_46_else, if_46_then
        cmp r8w, -8117
        jne _if_46_else
        jmp _if_46_then
_if_45_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.13.1{r5}, curr_r.2{r1}
        mov r8w, di
        ; add t.13.1{r5}, 1
        add r8w, 1
        ; move curr_r.5{r0}, curr_r.5{r5}
        mov ax, r8w
        ; mod curr_r.5{r3}, curr_r.5{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move curr_r.5{r5}, curr_r.5{r3}
        mov r8w, dx
        ; move curr_r.2{r1}, curr_r.5{r5}
        mov di, r8w
        jmp _while_40
_if_46_else:
        ; branch chr.1{r5} notequals -8115: if_47_else, if_47_then
        cmp r8w, -8115
        jne _if_47_else
        jmp _if_47_then
_if_46_then:
        ; move t.15.1{r5}, curr_c.2{r2}
        mov r8w, si
        ; add t.15.1{r5}, 40
        add r8w, 40
        ; sub t.14.1{r5}, 1
        sub r8w, 1
        ; move curr_c.4{r0}, curr_c.4{r5}
        mov ax, r8w
        ; mod curr_c.4{r3}, curr_c.4{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move curr_c.4{r5}, curr_c.4{r3}
        mov r8w, dx
        ; move curr_c.2{r2}, curr_c.4{r5}
        mov si, r8w
        jmp _while_40
_if_47_else:
        ; branch chr.1{r5} notequals 32: if_48_else, if_48_then
        cmp r8w, 32
        jne _if_48_else
        jmp _if_48_then
_if_47_then:
        ; move t.16.1{r5}, curr_c.2{r2}
        mov r8w, si
        ; add t.16.1{r5}, 1
        add r8w, 1
        ; move curr_c.5{r0}, curr_c.5{r5}
        mov ax, r8w
        ; mod curr_c.5{r3}, curr_c.5{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move curr_c.5{r5}, curr_c.5{r3}
        mov r8w, dx
        ; move curr_c.2{r2}, curr_c.5{r5}
        mov si, r8w
        jmp _while_40
_if_48_else:
        ; branch chr.1{r5} notequals 13: while_40, if_51_then
        cmp r8w, 13
        jne _while_40
        jmp _if_51_then
_if_48_then:
        ; branch needsInitialize.2{r8} notequals 0: while_40, if_49_then
        cmp bl, 0
        jne _while_40
        jmp _if_49_then
_if_51_then:
        ; branch needsInitialize.2{r8} equals 0: main.no_critical_edge_29, if_52_then
        cmp bl, 0
        je _main.no_critical_edge_29
        jmp _if_52_then
_if_49_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], si
        ; call cell.1{r0} = getCell@i16@i16[curr_r.2{r1}, curr_c.2{r2}] -> u8
        call _getCell@i16@i16
        ; 255:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=255:17]])
        ; move cell.1{r1}, cell.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], cell.1{r0}
        mov [r12], al
        ; call t.17.1{r0} = isOpen@u8[cell.1{r1}] -> bool
        call _isOpen@u8
        ; branch t.17.1{r0} notequals 0: main.no_critical_edge_32, if_50_then
        cmp al, 0
        jne _main.no_critical_edge_32
        jmp _if_50_then
_main.no_critical_edge_29:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        jmp _if_52_end
_if_52_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], di
        ; const needsInitialize.5{r8}, 0
        mov bl, 0
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; call initField@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _initField@i16@i16
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        jmp _if_52_end
_main.no_critical_edge_32:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        jmp _while_40
_if_50_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, cell.1
        lea r12, [rsp+40]
        ; load cell.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell.2{r3}, cell.1{r0}
        mov dl, al
        ; xor cell.2{r3}, 4
        xor dl, 4
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; call setCell@i16@i16@u8[curr_r.2{r1}, curr_c.2{r2}, cell.2{r3}]
        call _setCell@i16@i16@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        jmp _while_40
_if_52_end:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], si
        ; call cell.3{r0} = getCell@i16@i16[curr_r.2{r1}, curr_c.2{r2}] -> u8
        call _getCell@i16@i16
        ; 267:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=267:16]])
        ; move cell.3{r1}, cell.3{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell.3
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], cell.3{r0}
        mov [r12], al
        ; call t.18.1{r0} = isOpen@u8[cell.3{r1}] -> bool
        call _isOpen@u8
        ; branch t.18.1{r0} notequals 0: if_53_end
        cmp al, 0
        jne _if_53_end
        ; load cell.3{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.19.1{r3}, cell.3{r0}
        mov dl, al
        ; or t.19.1{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call setCell@i16@i16@u8[curr_r.2{r1}, curr_c.2{r2}, t.19.1{r3}]
        call _setCell@i16@i16@u8
_if_53_end:
        ; 270:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=270:15]])
        ; addrof memVarAddr{r9}, cell.3
        lea r12, [rsp+41]
        ; load cell.3{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell.3{r1}, cell.3{r0}
        mov dil, al
        ; call t.20.1{r0} = isBomb@u8[cell.3{r1}] -> bool
        call _isBomb@u8
        ; branch t.20.1{r0} notequals 0: if_54_then
        cmp al, 0
        jne _if_54_then
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call maybeRevealAround@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _maybeRevealAround@i16@i16
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
_while_40:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], si
        ; call printField@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _printField@i16@i16
        ; 223:3 if !needsInitialize
        ; branch needsInitialize.2{r8} notequals 0: if_41_end, if_41_then
        cmp bl, 0
        jne _if_41_end
        jmp _if_41_then
_if_42_then:
        ; const t.10.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_54_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+38]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+36]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call printField@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _printField@i16@i16
        ; const t.21.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.21.1{r1}]
        call _printString@@u8
_main_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
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

segment readable writable
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/6400)
        var_1 rb 6400

segment readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left:', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

