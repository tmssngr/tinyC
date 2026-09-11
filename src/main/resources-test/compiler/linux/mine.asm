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
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
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
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
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
        ; cast t.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call printUint@i64[t.1{r1}]
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
        ; const pos{r8}, 20
        mov bl, 20
        ; 33:2 while true
_while_1:
        ; sub pos{r8}, pos{r8}, 1
        sub bl, 1
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.5{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.6{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.6{r4}, t.6{r4}, t.7{r3}
        add rcx, rdx
        ; store [t.6{r4}], digit{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number{r1} notequals 0: while_1, while_1_break
        cmp rdi, 0
        jne _while_1
        ; cast t.9{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.8{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.8{r1}, t.8{r1}, t.9{r0}
        add rdi, rax
        ; const t.11{r0}, 20
        mov al, 20
        ; move t.10{r2}, t.11{r0}
        mov sil, al
        ; sub t.10{r2}, t.10{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.8{r1}, t.10{r2}]
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
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp _for_3
_for_3_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
_for_3:
        ; load t.2{r2}, [str{r1}]
        mov sil, [rdi]
        ; branch t.2{r2} notequals 0: for_3_body, for_3_break
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
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void initRandom@i32
        ;   rsp+32: arg salt
_initRandom@i32:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, edi
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r0}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; load tmp.__random__{r0}, [memVarAddr{r9}]
        mov eax, [r12]
        ; move r{r1}, tmp.__random__{r0}
        mov edi, eax
        ; move t.5{r2}, r{r1}
        mov esi, edi
        ; and t.5{r2}, t.5{r2}, 524287
        and esi, 524287
        ; mul b{r2}, b{r2}, 48271
        movsxd rsi, esi
        imul  rsi, 48271
        ; shiftright t.6{r1}, t.6{r1}, 15
        sar edi, 15
        ; mul c{r1}, c{r1}, 48271
        movsxd rdi, edi
        imul  rdi, 48271
        ; move t.7{r3}, c{r1}
        mov edx, edi
        ; and t.7{r3}, t.7{r3}, 65535
        and edx, 65535
        ; shiftleft d{r3}, d{r3}, 15
        sal edx, 15
        ; shiftright t.9{r1}, t.9{r1}, 16
        sar edi, 16
        ; add t.8{r1}, t.8{r1}, b{r2}
        add edi, esi
        ; add e{r1}, e{r1}, d{r3}
        add edi, edx
        ; move t.10{r2}, e{r1}
        mov esi, edi
        ; and t.10{r2}, t.10{r2}, 2147483647
        and esi, 2147483647
        ; shiftright t.11{r1}, t.11{r1}, 31
        sar edi, 31
        ; move tmp.__random__{r0}, t.10{r2}
        mov eax, esi
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.11{r1}
        add eax, edi
        ; 16:9 return __random__
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r0}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 random16
_random16:
        sub rsp, 8
        ; 20:23 return (i16) & 32767
        ; call t.2{r0} = random[] -> i32
        call _random
        ; cast t.1{r1}(i16), t.2{r0}(i32)
        mov di, ax
        ; move t.0{r0}, t.1{r1}
        mov ax, di
        ; and t.0{r0}, t.0{r0}, 32767
        and ax, 32767
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
_rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 17 + column
        ; mul t.3{r1}, t.3{r1}, 17
        movsx rdi, di
        imul  rdi, 17
        ; move t.2{r0}, t.3{r1}
        mov ax, di
        ; add t.2{r0}, t.2{r0}, column{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getCell@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
_getCell@i16@i16:
        sub rsp, 8
        ; 20:15 return [...]
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movsx rdi, ax
        ; addrof t.3{r2}, [field]
        lea rsi, [var_1]
        ; add t.3{r2}, t.3{r2}, t.4{r1}
        add rsi, rdi
        ; load t.2{r0}, [t.3{r2}]
        mov al, [rsi]
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+0: arg cell
_isBomb@u8:
        sub rsp, 8
        ; 24:27 return cell & 1 != 0
        ; and t.2{r1}, t.2{r1}, 1
        and dil, 1
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+0: arg cell
_isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; and t.2{r1}, t.2{r1}, 2
        and dil, 2
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+0: arg cell
_isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; and t.2{r1}, t.2{r1}, 4
        and dil, 4
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+0: arg row
        ;   rsp+2: arg column
_checkCellBounds@i16@i16:
        sub rsp, 8
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 17
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; gteq t.2{r0}, row{r1}, 0
        cmp di, 0
        setge al
        ; branch t.2{r0} equals 0: and_next_6, and_2nd_6
        cmp al, 0
        je _and_next_6
        ; lt t.2{r0}, row{r1}, 20
        cmp di, 20
        setl al
_and_next_6:
        ; branch t.2{r0} equals 0: and_next_5, and_2nd_5
        cmp al, 0
        je _and_next_5
        ; gteq t.2{r0}, column{r2}, 0
        cmp si, 0
        setge al
_and_next_5:
        ; branch t.2{r0} equals 0: checkCellBounds@i16@i16_ret, and_2nd_4
        cmp al, 0
        je _checkCellBounds@i16@i16_ret
        ; lt t.2{r0}, column{r2}, 17
        cmp si, 17
        setl al
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
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r1}, [field]
        lea rdi, [var_1]
        ; add t.3{r1}, t.3{r1}, t.4{r0}
        add rdi, rax
        ; store [t.3{r1}], cell{r8}
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
        ;   rsp+36: var count
        ;   rsp+38: var dr
        ;   rsp+40: var r
        ;   rsp+42: var dc
        ;   rsp+44: var c
_getBombCountAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; const count{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; const dr{r0}, -1
        mov ax, -1
        ; 46:2 for dr <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; move dr{r1}, dr{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_7
_for_7_body:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; move dr{r0}, dr{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; const dc{r0}, -1
        mov ax, -1
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move dc{r1}, dc{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; move dc{r0}, dc{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move c{r3}, column{r2}
        mov dx, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; add c{r3}, c{r3}, dc{r0}
        add dx, ax
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], dc{r0}
        mov [r12], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move c{r2}, c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dx
        ; call t.8{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8{r0} notequals 0: if_9_then, getBombCountAround@i16@i16.no_critical_edge_11
        cmp al, 0
        jne _if_9_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_8_continue
_if_9_then:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+44]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.9{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.9{r0} notequals 0: if_10_then, getBombCountAround@i16@i16.no_critical_edge_12
        cmp al, 0
        jne _if_10_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_8_continue
_if_10_then:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+36]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add count{r0}, count{r0}, 1
        add al, 1
_for_8_continue:
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+42]
        ; load dc{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add dc{r1}, dc{r1}, 1
        add di, 1
_for_8:
        ; branch dc{r1} lteq 1: for_8_body, for_7_continue
        cmp di, 1
        jle _for_8_body
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+38]
        ; load dr{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add dr{r1}, dr{r1}, 1
        add di, 1
_for_7:
        ; branch dr{r1} lteq 1: for_7_body, for_7_break
        cmp di, 1
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
        ; 62:2 if rowCursor == row
        ; branch rowCursor{r3} notequals row{r1}: if_11_end, if_11_then
        cmp dx, di
        jne _if_11_end
        ; branch columnCursor{r4} equals column{r2}: if_12_then, if_12_end
        cmp cx, si
        je _if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.5{r1}, column{r2}
        mov di, si
        ; sub t.5{r1}, t.5{r1}, 1
        sub di, 1
        ; branch columnCursor{r4} notequals t.5{r1}: if_11_end, if_13_then
        cmp cx, di
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
        mov dil, 93
        ; move t.6{r0}, t.6{r1}
        mov al, dil
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_11_end:
        ; 70:9 return 32
        ; const t.7{r1}, 32
        mov dil, 32
        ; move t.7{r0}, t.7{r1}
        mov al, dil
_getSpacer@i16@i16@i16@i16_ret:
        add rsp, 8
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+32: arg cell
        ;   rsp+34: arg row
        ;   rsp+36: arg column
        ;   rsp+38: var chr
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
        ; const chr{r1}, 46
        mov dil, 46
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.5{r0} notequals 0: if_14_then, if_14_else
        cmp al, 0
        jne _if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.7{r0} = isFlag@u8[cell{r1}] -> bool
        call _isFlag@u8
        ; branch t.7{r0} equals 0: printCell@u8@i16@i16.no_critical_edge_10, if_17_then
        cmp al, 0
        je _printCell@u8@i16@i16.no_critical_edge_10
        jmp _if_17_then
_if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.6{r0} equals 0: if_15_else, if_15_then
        cmp al, 0
        je _if_15_else
        jmp _if_15_then
_printCell@u8@i16@i16.no_critical_edge_10:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; load chr{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        jmp _if_14_end
_if_17_then:
        ; const chr{r8}, 35
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
        ; call count{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; 81:4 if count > 0
        ; branch count{r0} lteq 0: if_16_else, if_16_then
        cmp al, 0
        jbe _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr{r8}, 42
        mov bl, 42
        jmp _if_14_end
_if_16_else:
        ; const chr{r8}, 32
        mov bl, 32
        jmp _if_14_end
_if_16_then:
        ; move chr{r8}, count{r0}
        mov bl, al
        ; add chr{r8}, chr{r8}, 48
        add bl, 48
_if_14_end:
        ; move chr{r1}, chr{r8}
        mov dil, bl
        ; call printChar@u8[chr{r1}]
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
        ;   rsp+36: var row
        ;   rsp+38: var column
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
        ; const row{r1}, 0
        mov di, 0
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; 97:2 for row < 20
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        jmp _for_18
_for_18_body:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; const arg.1.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column{r2}, 0
        mov si, 0
        ; 99:3 for column < 17
        jmp _for_19
_for_19_body:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; load columnCursor{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r4}
        mov [r12], cx
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, column{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar@u8[spacer{r1}]
        call _printChar@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[row{r1}, column{r2}] -> u8
        call _getCell@i16@i16
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dx
        ; call printCell@u8@i16@i16[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@i16@i16
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+38]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add column{r2}, column{r2}, 1
        add si, 1
_for_19:
        ; branch column{r2} lt 17: for_19_body, for_19_break
        cmp si, 17
        jl _for_19_body
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; move rowCursor{r3}, rowCursor{r8}
        mov dx, bx
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; load columnCursor{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move columnCursor{r4}, columnCursor{r2}
        mov cx, si
        ; addrof memVarAddr{r9}, columnCursor
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], columnCursor{r2}
        mov [r12], si
        ; const arg.6.1{r2}, 17
        mov si, 17
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, arg.6.1{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov dil, al
        ; call printChar@u8[spacer{r1}]
        call _printChar@u8
        ; const t.7{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.7{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+36]
        ; load row{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add row{r1}, row{r1}, 1
        add di, 1
_for_18:
        ; branch row{r1} lt 20: for_18_body, printField@i16@i16_ret
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
        ; move i{r8}, i{r1}
        mov bx, di
        ; 112:2 for i > 0
        jmp _for_20
_for_20_body:
        ; const arg.0.0{r1}, 48
        mov dil, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; sub i{r8}, i{r8}, 1
        sub bx, 1
_for_20:
        ; branch i{r8} gt 0: for_20_body, printSpaces@i16_ret
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
        ; const count{r2}, 0
        mov sil, 0
        ; 119:2 if value < 0
        ; branch value{r1} gteq 0: while_22, if_21_then
        cmp di, 0
        jge _while_22
        ; const count{r2}, 1
        mov sil, 1
        ; neg value{r1}, value{r1}
        neg rdi
_while_22:
        ; add count{r2}, count{r2}, 1
        add sil, 1
        ; move value{r0}, value{r1}
        mov ax, di
        ; div value{r0}, value{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move value{r1}, value{r0}
        mov di, ax
        ; 127:3 if value == 0
        ; branch value{r1} notequals 0: while_22, while_22_break
        cmp di, 0
        jne _while_22
        ; 132:9 return count
        ; move count{r0}, count{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+32: var r
        ;   rsp+34: var c
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const count{r8}, 0
        mov bx, 0
        ; const r{r1}, 0
        mov di, 0
        ; 137:2 for r < 20
        jmp _for_24
_for_24_body:
        ; const c{r2}, 0
        mov si, 0
        ; 138:3 for c < 17
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        jmp _for_25
_for_25_body:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; 140:4 if cell & 6 == 0
        ; move t.4{r1}, cell{r0}
        mov dil, al
        ; and t.4{r1}, t.4{r1}, 6
        and dil, 6
        ; branch t.4{r1} notequals 0: for_25_continue, if_26_then
        cmp dil, 0
        jne _for_25_continue
        ; add count{r8}, count{r8}, 1
        add bx, 1
_for_25_continue:
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add c{r2}, c{r2}, 1
        add si, 1
_for_25:
        ; branch c{r2} lt 17: for_25_body, for_24_continue
        cmp si, 17
        jl _for_25_body
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add r{r1}, r{r1}, 1
        add di, 1
_for_24:
        ; branch r{r1} lt 20: for_24_body, for_24_break
        cmp di, 20
        jl _for_24_body
        ; 145:9 return count
        ; move count{r0}, count{r8}
        mov ax, bx
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+32: var leftDigits
        ;   rsp+34: var bombDigits
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call count{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count{r8}, count{r0}
        mov bx, ax
        ; move count{r1}, count{r8}
        mov di, bx
        ; call t.3{r0} = getDigitCount@i16[count{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits{r0}(i16), t.3{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, leftDigits
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], leftDigits{r0}
        mov [r12], ax
        ; const arg.2.0{r1}, 17
        mov di, 17
        ; call t.4{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombDigits{r0}
        mov [r12], ax
        ; const t.5{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.5{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; load bombDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.6{r1}, bombDigits{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, leftDigits
        lea r12, [rsp+32]
        ; load leftDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.6{r1}, t.6{r1}, leftDigits{r0}
        sub di, ax
        ; call printSpaces@i16[t.6{r1}]
        call _printSpaces@i16
        ; move count{r1}, count{r8}
        mov di, bx
        ; call printUint@i16[count{r1}]
        call _printUint@i16
        ; 156:15 return count == 0
        ; equals t.7{r0}, count{r8}, 0
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
        ; 160:2 if a < 0
        ; branch a{r1} lt 0: if_27_then, if_27_end
        cmp di, 0
        jl _if_27_then
        ; 163:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_27_then:
        ; 161:10 return -a
        ; neg t.1{r1}, a{r1}
        neg rdi
        ; move t.1{r0}, t.1{r1}
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
        ; const r{r8}, 0
        mov bx, 0
        ; 167:2 for r < 20
        jmp _for_28
_for_28_body:
        ; const c{r9}, 0
        mov r12w, 0
        ; 168:3 for c < 17
        jmp _for_29
_for_29_body:
        ; move r{r1}, r{r8}
        mov di, bx
        ; move c{r2}, c{r9}
        mov si, r12w
        ; const arg.0.2{r3}, 0
        mov dl, 0
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, arg.0.2{r3}]
        call _setCell@i16@i16@u8
        ; add c{r9}, c{r9}, 1
        add r12w, 1
_for_29:
        ; branch c{r9} lt 17: for_29_body, for_28_continue
        cmp r12w, 17
        jl _for_29_body
        ; add r{r8}, r{r8}, 1
        add bx, 1
_for_28:
        ; branch r{r8} lt 20: for_28_body, clearField_ret
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
        ;   rsp+36: var bombs
        ;   rsp+38: var row
        ;   rsp+40: var column
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
        ; const bombs{r0}, 17
        mov ax, 17
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; 175:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        jmp _for_30
_for_30_body:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; call t.5{r0} = random16[] -> i16
        call _random16
        ; move row{r1}, t.5{r0}
        mov di, ax
        ; move row{r0}, row{r1}
        mov ax, di
        ; mod row{r3}, row{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row{r1}, row{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r1}
        mov [r12], di
        ; call t.6{r0} = random16[] -> i16
        call _random16
        ; move column{r2}, t.6{r0}
        mov si, ax
        ; move column{r0}, column{r2}
        mov ax, si
        ; mod column{r3}, column{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move column{r2}, column{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.8{r1}, row{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r0}
        mov [r12], ax
        ; sub t.8{r1}, t.8{r1}, curr_r{r8}
        sub di, bx
        ; call t.7{r0} = abs@i16[t.8{r1}] -> i16
        call _abs@i16
        ; branch t.7{r0} gt 1: if_31_then, or_32
        cmp ax, 1
        jg _if_31_then
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.10{r1}, column{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; sub t.10{r1}, t.10{r1}, curr_c{r2}
        sub di, si
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call t.9{r0} = abs@i16[t.10{r1}] -> i16
        call _abs@i16
        ; branch t.9{r0} lteq 1: for_30_continue, if_31_then
        cmp ax, 1
        jle _for_30_continue
_if_31_then:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move row{r1}, row{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move column{r2}, column{r0}
        mov si, ax
        ; const arg.4.2{r3}, 1
        mov dl, 1
        ; call setCell@i16@i16@u8[row{r1}, column{r2}, arg.4.2{r3}]
        call _setCell@i16@i16@u8
_for_30_continue:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs{r0}, bombs{r0}, 1
        sub ax, 1
_for_30:
        ; branch bombs{r0} gt 0: for_30_body, initField@i16@i16_ret
        cmp ax, 0
        jg _for_30_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void revealCells@i16@i16@i16
        ;   rsp+32: arg row
        ;   rsp+34: arg left
        ;   rsp+36: arg right
        ;   rsp+38: var c
        ;   rsp+40: var cell
_revealCells@i16@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], right{r3}
        mov [r12], dx
        ; move t.6{r0}, left{r2}
        mov ax, si
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], left{r2}
        mov [r12], si
        ; shiftleft t.6{r0}, t.6{r0}, 1
        sal ax, 1
        ; move t.5{r1}, t.6{r0}
        mov di, ax
        ; add t.5{r1}, t.5{r1}, 2
        add di, 2
        ; move row{r2}, row{r8}
        mov si, bx
        ; call setCursor@i16@i16[t.5{r1}, row{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+34]
        ; load left{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; 187:2 for c <= right
        jmp _for_33
_for_33_body:
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], right{r3}
        mov [r12], dx
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[row{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; move t.7{r3}, cell{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; or t.7{r3}, t.7{r3}, 2
        or dl, 2
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call setCell@i16@i16@u8[row{r1}, c{r2}, t.7{r3}]
        call _setCell@i16@i16@u8
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+40]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move row{r2}, row{r8}
        mov si, bx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; load c{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dx
        ; call printCell@u8@i16@i16[cell{r1}, row{r2}, c{r3}]
        call _printCell@u8@i16@i16
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add c{r2}, c{r2}, 1
        add si, 1
_for_33:
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+36]
        ; load right{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; branch c{r2} lteq right{r3}: for_33_body, revealCells@i16@i16@i16_ret
        cmp si, dx
        jle _for_33_body
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
        ;   rsp+36: var left
        ;   rsp+38: var right
        ;   rsp+40: var dr
        ;   rsp+42: var r
        ;   rsp+44: var dc
        ;   rsp+46: var c
        ;   rsp+48: var cell
_maybeRevealAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; 195:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=195:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=195:30]]) != 0
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call t.9{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; branch t.9{r0} notequals 0: maybeRevealAround@i16@i16_ret, if_34_end
        cmp al, 0
        jne _maybeRevealAround@i16@i16_ret
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move left{r0}, column{r2}
        mov ax, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; 200:2 while left > 0
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], left{r0}
        mov [r12], ax
        jmp _while_35
_while_35_body:
        ; move left{r0}, left{r2}
        mov ax, si
        ; sub left{r0}, left{r0}, 1
        sub ax, 1
        ; 202:3 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=202:26], ExprVarAccess[varName=left, index=2, scope=function, type=i16, varIsArray=false, location=202:31]]) != 0
        ; move row{r1}, row{r8}
        mov di, bx
        ; move left{r2}, left{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], left{r0}
        mov [r12], ax
        ; call t.10{r0} = getBombCountAround@i16@i16[row{r1}, left{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; branch t.10{r0} notequals 0: while_35_break, while_35
        cmp al, 0
        jne _while_35_break
_while_35:
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+36]
        ; load left{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; branch left{r2} lteq 0: maybeRevealAround@i16@i16.no_critical_edge_20, while_35_body
        cmp si, 0
        jle _maybeRevealAround@i16@i16.no_critical_edge_20
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], left{r2}
        mov [r12], si
        jmp _while_35_body
_maybeRevealAround@i16@i16.no_critical_edge_20:
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], left{r2}
        mov [r12], si
_while_35_break:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move right{r0}, column{r2}
        mov ax, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; 208:2 while right < 17
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], right{r0}
        mov [r12], ax
        jmp _while_37
_while_37_body:
        ; move right{r0}, right{r3}
        mov ax, dx
        ; add right{r0}, right{r0}, 1
        add ax, 1
        ; 210:3 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=210:26], ExprVarAccess[varName=right, index=3, scope=function, type=i16, varIsArray=false, location=210:31]]) != 0
        ; move row{r1}, row{r8}
        mov di, bx
        ; move right{r2}, right{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], right{r0}
        mov [r12], ax
        ; call t.11{r0} = getBombCountAround@i16@i16[row{r1}, right{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; branch t.11{r0} notequals 0: maybeRevealAround@i16@i16.no_critical_edge_29, while_37
        cmp al, 0
        jne _maybeRevealAround@i16@i16.no_critical_edge_29
_while_37:
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+38]
        ; load right{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; branch right{r3} gteq 17: while_37_break, while_37_body
        cmp dx, 17
        jge _while_37_break
        jmp _while_37_body
_maybeRevealAround@i16@i16.no_critical_edge_29:
        ; addrof memVarAddr{r9}, right
        lea r12, [rsp+38]
        ; load right{r3}, [memVarAddr{r9}]
        mov dx, [r12]
_while_37_break:
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, left
        lea r12, [rsp+36]
        ; load left{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call revealCells@i16@i16@i16[row{r1}, left{r2}, right{r3}]
        call _revealCells@i16@i16@i16
        ; const dr{r0}, -1
        mov ax, -1
        ; 217:2 for dr <= 1
        jmp _for_39
_for_39_body:
        ; move r{r1}, row{r8}
        mov di, bx
        ; add r{r1}, r{r1}, dr{r0}
        add di, ax
        ; const dc{r3}, -1
        mov dx, -1
        ; 219:3 for dc <= 1
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move dc{r0}, dc{r3}
        mov ax, dx
        jmp _for_40
_for_40_body:
        ; move dc{r3}, dc{r0}
        mov dx, ax
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+40]
        ; load dr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; branch dr{r0} notequals 0: maybeRevealAround@i16@i16.no_critical_edge_23, and_42
        cmp ax, 0
        jne _maybeRevealAround@i16@i16.no_critical_edge_23
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        jmp _and_42
_maybeRevealAround@i16@i16.no_critical_edge_23:
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        jmp _if_41_end
_and_42:
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], dr{r0}
        mov [r12], ax
        ; branch dc{r3} notequals 0: if_41_end, maybeRevealAround@i16@i16.no_critical_edge_26
        cmp dx, 0
        jne _if_41_end
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], dc{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        jmp _for_40_continue
_if_41_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move c{r0}, column{r2}
        mov ax, si
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; add c{r0}, c{r0}, dc{r3}
        add ax, dx
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], dc{r3}
        mov [r12], dx
        ; 225:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=5, scope=function, type=i16, varIsArray=false, location=225:25], ExprVarAccess[varName=c, index=7, scope=function, type=i16, varIsArray=false, location=225:28]])
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; move c{r2}, c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; call t.12{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.12{r0} equals 0: for_40_continue, if_43_end
        cmp al, 0
        je _for_40_continue
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+46]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; 230:4 if isOpen@u8([ExprVarAccess[varName=cell, index=8, scope=function, type=u8, varIsArray=false, location=230:15]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+48]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.13{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.13{r0} notequals 0: for_40_continue, if_44_end
        cmp al, 0
        jne _for_40_continue
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+48]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.14{r3}, cell{r0}
        mov dl, al
        ; or t.14{r3}, t.14{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+46]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], si
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.14{r3}]
        call _setCell@i16@i16@u8
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; load r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+46]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call maybeRevealAround@i16@i16[r{r1}, c{r2}]
        call _maybeRevealAround@i16@i16
_for_40_continue:
        ; addrof memVarAddr{r9}, dc
        lea r12, [rsp+44]
        ; load dc{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add dc{r0}, dc{r0}, 1
        add ax, 1
_for_40:
        ; branch dc{r0} lteq 1: for_40_body, for_39_continue
        cmp ax, 1
        jle _for_40_body
        ; addrof memVarAddr{r9}, dr
        lea r12, [rsp+40]
        ; load dr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add dr{r0}, dr{r0}, 1
        add ax, 1
_for_39:
        ; branch dr{r0} lteq 1: for_39_body, maybeRevealAround@i16@i16_ret
        cmp ax, 1
        jle _for_39_body
_maybeRevealAround@i16@i16_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var curr_c
        ;   rsp+34: var curr_r
        ;   rsp+36: var cell
        ;   rsp+37: var cell
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const tmp.__random__{r8}, 0
        mov ebx, 0
        ; end initialize global variables
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r8}
        mov [r12], ebx
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize{r8}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; const curr_c{r0}, 8
        mov ax, 8
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; const curr_r{r0}, 10
        mov ax, 10
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; 246:2 while true
        jmp _while_45
_if_46_then:
        ; 249:4 if printLeft([])
        ; call t.6{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.6{r0} notequals 0: if_47_then, if_46_end
        cmp al, 0
        jne _if_47_then
_if_46_end:
        ; call chr{r0} = getChar[] -> i16
        call _getChar
        ; move chr{r5}, chr{r0}
        mov r8w, ax
        ; 256:3 if chr == 27
        ; branch chr{r5} equals 27: main_ret, if_48_end
        cmp r8w, 27
        je _main_ret
        ; branch chr{r5} equals -8120: if_49_then, if_49_else
        cmp r8w, -8120
        je _if_49_then
        ; branch chr{r5} notequals -8112: if_50_else, if_50_then
        cmp r8w, -8112
        jne _if_50_else
        jmp _if_50_then
_if_49_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.9{r5}, curr_r{r1}
        mov r8w, di
        ; add t.9{r5}, t.9{r5}, 20
        add r8w, 20
        ; sub t.8{r5}, t.8{r5}, 1
        sub r8w, 1
        ; move curr_r{r1}, t.8{r5}
        mov di, r8w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _while_45
_if_50_else:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; branch chr{r5} notequals -8117: if_51_else, if_51_then
        cmp r8w, -8117
        jne _if_51_else
        jmp _if_51_then
_if_50_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.10{r5}, curr_r{r1}
        mov r8w, di
        ; add t.10{r5}, t.10{r5}, 1
        add r8w, 1
        ; move curr_r{r1}, t.10{r5}
        mov di, r8w
        ; move curr_r{r0}, curr_r{r1}
        mov ax, di
        ; mod curr_r{r3}, curr_r{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move curr_r{r1}, curr_r{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _while_45
_if_51_else:
        ; branch chr{r5} notequals -8115: if_52_else, if_52_then
        cmp r8w, -8115
        jne _if_52_else
        jmp _if_52_then
_if_51_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move t.12{r5}, curr_c{r2}
        mov r8w, si
        ; add t.12{r5}, t.12{r5}, 17
        add r8w, 17
        ; sub t.11{r5}, t.11{r5}, 1
        sub r8w, 1
        ; move curr_c{r2}, t.11{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move curr_c{r2}, curr_c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _while_45
_if_52_else:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; branch chr{r5} notequals 32: if_53_else, if_53_then
        cmp r8w, 32
        jne _if_53_else
        jmp _if_53_then
_if_52_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move t.13{r5}, curr_c{r2}
        mov r8w, si
        ; add t.13{r5}, t.13{r5}, 1
        add r8w, 1
        ; move curr_c{r2}, t.13{r5}
        mov si, r8w
        ; move curr_c{r0}, curr_c{r2}
        mov ax, si
        ; mod curr_c{r3}, curr_c{r0}, 17
        movsx rax, ax
        cqo
        mov rcx, 17
        idiv rcx
        ; move curr_c{r2}, curr_c{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _while_45
_if_53_else:
        ; branch chr{r5} notequals 13: main.no_critical_edge_28, if_56_then
        cmp r8w, 13
        jne _main.no_critical_edge_28
        jmp _if_56_then
_if_53_then:
        ; branch needsInitialize{r8} notequals 0: main.no_critical_edge_31, if_54_then
        cmp bl, 0
        jne _main.no_critical_edge_31
        jmp _if_54_then
_main.no_critical_edge_28:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _while_45
_if_56_then:
        ; branch needsInitialize{r8} equals 0: main.no_critical_edge_29, if_57_then
        cmp bl, 0
        je _main.no_critical_edge_29
        jmp _if_57_then
_main.no_critical_edge_31:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _while_45
_if_54_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call _getCell@i16@i16
        ; 280:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=280:17]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.14{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.14{r0} notequals 0: while_45, if_55_then
        cmp al, 0
        jne _while_45
        jmp _if_55_then
_main.no_critical_edge_29:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        jmp _if_57_end
_if_57_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; const needsInitialize{r8}, 0
        mov bl, 0
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call initField@i16@i16[curr_r{r1}, curr_c{r2}]
        call _initField@i16@i16
        jmp _if_57_end
_if_55_then:
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; xor cell{r0}, cell{r0}, 4
        xor al, 4
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], si
        ; move cell{r3}, cell{r0}
        mov dl, al
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, cell{r3}]
        call _setCell@i16@i16@u8
        jmp _while_45
_if_57_end:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call _getCell@i16@i16
        ; 292:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=292:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.15{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.15{r0} notequals 0: if_58_end, if_58_then
        cmp al, 0
        jne _if_58_end
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.16{r3}, cell{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; or t.16{r3}, t.16{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, t.16{r3}]
        call _setCell@i16@i16@u8
_if_58_end:
        ; 295:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=295:15]])
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.17{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.17{r0} notequals 0: if_59_then, if_59_end
        cmp al, 0
        jne _if_59_then
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call maybeRevealAround@i16@i16[curr_r{r1}, curr_c{r2}]
        call _maybeRevealAround@i16@i16
_while_45:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], curr_r{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r0}
        mov [r12], ax
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call _printField@i16@i16
        ; 248:3 if !needsInitialize
        ; branch needsInitialize{r8} notequals 0: if_46_end, if_46_then
        cmp bl, 0
        jne _if_46_end
        jmp _if_46_then
_if_47_then:
        ; const t.7{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.7{r1}]
        call _printString@@u8
        jmp _main_ret
_if_59_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+34]
        ; load curr_r{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_r{r1}, curr_r{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move curr_c{r2}, curr_c{r0}
        mov si, ax
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call _printField@i16@i16
        ; const t.18{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.18{r1}]
        call _printString@@u8
_main_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
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
        ; variable 1: field[] (u8*/2720)
        var_1 rb 2720

segment readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

