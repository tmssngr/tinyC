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

        ; i16 rowColumnToCell@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r{r1}(i16), row{r1}(u8)
        movzx di, dil
        ; cast c{r2}(i16), column{r2}(u8)
        movzx si, sil
        ; 18:19 return r * 17 + c
        ; mul t.5{r1}, t.5{r1}, 17
        movsx rdi, di
        imul  rdi, 17
        ; move t.4{r0}, t.5{r1}
        mov ax, di
        ; add t.4{r0}, t.4{r0}, c{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getCell@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_getCell@u8@u8:
        sub rsp, 8
        ; 22:15 return [...]
        ; call t.5{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
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
        ; 26:27 return cell & 1 != 0
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
        ; 30:27 return cell & 2 != 0
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
        ; 34:27 return cell & 4 != 0
        ; and t.2{r1}, t.2{r1}, 4
        and dil, 4
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp dil, 0
        setne al
        add rsp, 8
        ret

        ; void setCell@u8@u8@u8
        ;   rsp+24: arg row
        ;   rsp+25: arg column
        ;   rsp+26: arg cell
_setCell@u8@u8@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move cell{r8}, cell{r3}
        mov bl, dl
        ; call t.5{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
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

        ; u8 getBombCountAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowTo
        ;   rsp+35: var colFrom
        ;   rsp+36: var colTo
        ;   rsp+37: var count
        ;   rsp+38: var r
        ;   rsp+39: var c
_getBombCountAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move rowFrom{r0}, row{r8}
        mov al, bl
        ; 43:2 if rowFrom > 0
        ; branch rowFrom{r0} lteq 0: if_4_end, if_4_then
        cmp al, 0
        jbe _if_4_end
        ; move rowFrom{r0}, row{r8}
        mov al, bl
        ; sub rowFrom{r0}, rowFrom{r0}, 1
        sub al, 1
_if_4_end:
        ; move rowTo{r3}, row{r8}
        mov dl, bl
        ; add rowTo{r3}, rowTo{r3}, 1
        add dl, 1
        ; 47:2 if rowTo >= 20
        ; branch rowTo{r3} gteq 20: if_5_then, getBombCountAround@u8@u8.no_critical_edge_21
        cmp dl, 20
        jae _if_5_then
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo{r3}
        mov [r12], dl
        jmp _if_5_end
_if_5_then:
        ; sub rowTo{r3}, rowTo{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo{r3}
        mov [r12], dl
_if_5_end:
        ; move colFrom{r3}, column{r2}
        mov dl, sil
        ; 52:2 if colFrom > 0
        ; branch colFrom{r3} lteq 0: if_6_end, if_6_then
        cmp dl, 0
        jbe _if_6_end
        ; sub colFrom{r3}, colFrom{r3}, 1
        sub dl, 1
_if_6_end:
        ; move colTo{r4}, column{r2}
        mov cl, sil
        ; add colTo{r4}, colTo{r4}, 1
        add cl, 1
        ; 56:2 if colTo >= 17
        ; branch colTo{r4} gteq 17: if_7_then, getBombCountAround@u8@u8.no_critical_edge_23
        cmp cl, 17
        jae _if_7_then
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r4}
        mov [r12], cl
        jmp _if_7_end
_if_7_then:
        ; sub colTo{r4}, colTo{r4}, 1
        sub cl, 1
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r4}
        mov [r12], cl
_if_7_end:
        ; const count{r4}, 0
        mov cl, 0
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], count{r4}
        mov [r12], cl
        ; move r{r1}, rowFrom{r0}
        mov dil, al
        ; 61:2 for r <= rowTo
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; move r{r2}, r{r1}
        mov sil, dil
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; load colTo{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo{r3}
        mov [r12], dl
        ; move r{r1}, r{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+35]
        ; load colFrom{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c{r0}, colFrom{r3}
        mov al, dl
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom{r3}
        mov [r12], dl
        ; 62:3 for c <= colTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; move c{r2}, c{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_9
_for_9_body:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], count{r0}
        mov [r12], al
        ; move c{r0}, c{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r{r1} equals row{r8}: and_11, getBombCountAround@u8@u8.no_critical_edge_24
        cmp dil, bl
        je _and_11
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _if_10_end
_and_11:
        ; branch c{r0} equals column{r2}: getBombCountAround@u8@u8.no_critical_edge_26, getBombCountAround@u8@u8.no_critical_edge_27
        cmp al, sil
        je _getBombCountAround@u8@u8.no_critical_edge_26
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _getBombCountAround@u8@u8.no_critical_edge_27
_getBombCountAround@u8@u8.no_critical_edge_26:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_9_continue
_getBombCountAround@u8@u8.no_critical_edge_27:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
_if_10_end:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; move c{r2}, c{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; call cell{r0} = getCell@u8@u8[r{r1}, c{r2}] -> u8
        call _getCell@u8@u8
        ; 67:4 if isBomb@u8([ExprVarAccess[varName=cell, index=9, scope=function, type=u8, varIsArray=false, location=67:14]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.10{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.10{r0} notequals 0: if_12_then, getBombCountAround@u8@u8.no_critical_edge_25
        cmp al, 0
        jne _if_12_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_9_continue
_if_12_then:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+37]
        ; load count{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add count{r0}, count{r0}, 1
        add al, 1
_for_9_continue:
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+39]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c{r2}, c{r2}, 1
        add sil, 1
_for_9:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; load colTo{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch c{r2} lteq colTo{r1}: for_9_body, for_8_continue
        cmp sil, dil
        jbe _for_9_body
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+38]
        ; load r{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add r{r2}, r{r2}, 1
        add sil, 1
_for_8:
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; load rowTo{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch r{r2} lteq rowTo{r3}: for_8_body, for_8_break
        cmp sil, dl
        jbe _for_8_body
        ; 72:9 return count
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 columnToX@u8
        ;   rsp+0: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c{r1}(i16), column{r1}(u8)
        movzx di, dil
        ; 77:17 return c + 1 << 1
        ; add t.3{r1}, t.3{r1}, 1
        add di, 1
        ; move t.2{r0}, t.3{r1}
        mov ax, di
        ; shiftleft t.2{r0}, t.2{r0}, 1
        sal ax, 1
        add rsp, 8
        ret

        ; void printCellAt@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
_printCellAt@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move column{r9}, column{r2}
        mov r12b, sil
        ; move row{r1}, row{r8}
        mov dil, bl
        ; move column{r2}, column{r9}
        mov sil, r12b
        ; call cell{r0} = getCell@u8@u8[row{r1}, column{r2}] -> u8
        call _getCell@u8@u8
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move row{r2}, row{r8}
        mov sil, bl
        ; move column{r3}, column{r9}
        mov dl, r12b
        ; call printCellAt@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCellAt@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printCellAt@u8@u8@u8
        ;   rsp+32: arg cell
        ;   rsp+33: arg row
        ;   rsp+34: arg column
_printCellAt@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], sil
        ; move column{r1}, column{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dl
        ; call x{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.4{r1}(i16), row{r2}(u8)
        movzx di, sil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], sil
        ; move x{r2}, x{r0}
        mov si, ax
        ; call setCursor@i16@i16[t.4{r1}, x{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printCell@u8@u8@u8
        ;   rsp+32: arg cell
        ;   rsp+33: arg row
        ;   rsp+34: arg column
        ;   rsp+35: var chr
_printCell@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move cell{r8}, cell{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], row{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dl
        ; const chr{r1}, 46
        mov dil, 46
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; 93:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=93:13]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.5{r0} notequals 0: if_13_then, if_13_else
        cmp al, 0
        jne _if_13_then
        ; 107:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=107:18]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.7{r0} = isFlag@u8[cell{r1}] -> bool
        call _isFlag@u8
        ; branch t.7{r0} equals 0: printCell@u8@u8@u8.no_critical_edge_10, if_16_then
        cmp al, 0
        je _printCell@u8@u8@u8.no_critical_edge_10
        jmp _if_16_then
_if_13_then:
        ; 94:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=94:14]])
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.6{r0} equals 0: if_14_else, if_14_then
        cmp al, 0
        je _if_14_else
        jmp _if_14_then
_printCell@u8@u8@u8.no_critical_edge_10:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+35]
        ; load chr{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        jmp _if_13_end
_if_16_then:
        ; const chr{r8}, 35
        mov bl, 35
        jmp _if_13_end
_if_14_else:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move row{r1}, row{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move column{r2}, column{r3}
        mov sil, dl
        ; call count{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 99:4 if count > 0
        ; branch count{r0} lteq 0: if_15_else, if_15_then
        cmp al, 0
        jbe _if_15_else
        jmp _if_15_then
_if_14_then:
        ; const chr{r8}, 42
        mov bl, 42
        jmp _if_13_end
_if_15_else:
        ; const chr{r8}, 32
        mov bl, 32
        jmp _if_13_end
_if_15_then:
        ; move chr{r8}, count{r0}
        mov bl, al
        ; add chr{r8}, chr{r8}, 48
        add bl, 48
_if_13_end:
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

        ; void printField
_printField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const arg.0.0{r1}, 0
        mov di, 0
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row{r8}, 0
        mov bl, 0
        ; 115:2 for row < 20
        jmp _for_17
_for_17_body:
        ; const arg.1.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column{r9}, 0
        mov r12b, 0
        ; 117:3 for column < 17
        jmp _for_18
_for_18_body:
        ; const arg.2.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; move row{r1}, row{r8}
        mov dil, bl
        ; move column{r2}, column{r9}
        mov sil, r12b
        ; call cell{r0} = getCell@u8@u8[row{r1}, column{r2}] -> u8
        call _getCell@u8@u8
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; move row{r2}, row{r8}
        mov sil, bl
        ; move column{r3}, column{r9}
        mov dl, r12b
        ; call printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        ; add column{r9}, column{r9}, 1
        add r12b, 1
_for_18:
        ; branch column{r9} lt 17: for_18_body, for_18_break
        cmp r12b, 17
        jb _for_18_body
        ; const t.3{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.3{r1}]
        call _printString@@u8
        ; add row{r8}, row{r8}, 1
        add bl, 1
_for_17:
        ; branch row{r8} lt 20: for_17_body, printField_ret
        cmp bl, 20
        jb _for_17_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void showCursor@u8@u8@bool
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: arg show
        ;   rsp+36: var x
        ;   rsp+38: var chr
_showCursor@u8@u8@bool:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; move column{r1}, column{r2}
        mov dil, sil
        ; call x{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.5{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; move t.6{r2}, x{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, x
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], x{r0}
        mov [r12], ax
        ; sub t.6{r2}, t.6{r2}, 1
        sub si, 1
        ; call setCursor@i16@i16[t.5{r1}, t.6{r2}]
        call _setCursor@i16@i16
        ; const chr{r1}, 32
        mov dil, 32
        ; 130:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool.no_critical_edge_6, if_19_then
        cmp dl, 0
        je _showCursor@u8@u8@bool.no_critical_edge_6
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        jmp _if_19_then
_showCursor@u8@u8@bool.no_critical_edge_6:
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        jmp _if_19_end
_if_19_then:
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; const chr{r1}, 91
        mov dil, 91
_if_19_end:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; call printChar@u8[chr{r1}]
        call _printChar@u8
        ; cast t.7{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; addrof memVarAddr{r9}, x
        lea r12, [rsp+36]
        ; load x{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.8{r2}, x{r0}
        mov si, ax
        ; add t.8{r2}, t.8{r2}, 1
        add si, 1
        ; call setCursor@i16@i16[t.7{r1}, t.8{r2}]
        call _setCursor@i16@i16
        ; 136:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_20_then, showCursor@u8@u8@bool.no_critical_edge_7
        cmp dl, 0
        jne _if_20_then
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+38]
        ; load chr{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_20_end
_if_20_then:
        ; const chr{r1}, 93
        mov dil, 93
_if_20_end:
        ; call printChar@u8[chr{r1}]
        call _printChar@u8
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
        ; 143:2 for i > 0
        jmp _for_21
_for_21_body:
        ; const arg.0.0{r1}, 48
        mov dil, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; sub i{r8}, i{r8}, 1
        sub bx, 1
_for_21:
        ; branch i{r8} gt 0: for_21_body, printSpaces@i16_ret
        cmp bx, 0
        jg _for_21_body
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
        ; 150:2 if value < 0
        ; branch value{r1} gteq 0: while_23, if_22_then
        cmp di, 0
        jge _while_23
        ; const count{r2}, 1
        mov sil, 1
        ; neg value{r1}, value{r1}
        neg rdi
_while_23:
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
        ; 158:3 if value == 0
        ; branch value{r1} notequals 0: while_23, while_23_break
        cmp di, 0
        jne _while_23
        ; 163:9 return count
        ; move count{r0}, count{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+32: var r
        ;   rsp+33: var c
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
        mov dil, 0
        ; 168:2 for r < 20
        jmp _for_25
_for_25_body:
        ; const c{r2}, 0
        mov sil, 0
        ; 169:3 for c < 17
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        jmp _for_26
_for_26_body:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], sil
        ; call cell{r0} = getCell@u8@u8[r{r1}, c{r2}] -> u8
        call _getCell@u8@u8
        ; 171:4 if cell & 6 == 0
        ; move t.4{r1}, cell{r0}
        mov dil, al
        ; and t.4{r1}, t.4{r1}, 6
        and dil, 6
        ; branch t.4{r1} notequals 0: for_26_continue, if_27_then
        cmp dil, 0
        jne _for_26_continue
        ; add count{r8}, count{r8}, 1
        add bx, 1
_for_26_continue:
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+33]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c{r2}, c{r2}, 1
        add sil, 1
_for_26:
        ; branch c{r2} lt 17: for_26_body, for_25_continue
        cmp sil, 17
        jb _for_26_body
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+32]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add r{r1}, r{r1}, 1
        add dil, 1
_for_25:
        ; branch r{r1} lt 20: for_25_body, for_25_break
        cmp dil, 20
        jb _for_25_body
        ; 176:9 return count
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
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 6
        mov si, 6
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r9}, bombDigits
        lea r12, [rsp+34]
        ; load bombDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.5{r1}, bombDigits{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, leftDigits
        lea r12, [rsp+32]
        ; load leftDigits{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.5{r1}, t.5{r1}, leftDigits{r0}
        sub di, ax
        ; call printSpaces@i16[t.5{r1}]
        call _printSpaces@i16
        ; move count{r1}, count{r8}
        mov di, bx
        ; call printUint@i16[count{r1}]
        call _printUint@i16
        ; 187:15 return count == 0
        ; equals t.6{r0}, count{r8}, 0
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
        ; 191:2 if a < 0
        ; branch a{r1} lt 0: if_28_then, if_28_end
        cmp di, 0
        jl _if_28_then
        ; 194:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_28_then:
        ; 192:10 return -a
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
        mov bl, 0
        ; 198:2 for r < 20
        jmp _for_29
_for_29_body:
        ; const c{r9}, 0
        mov r12b, 0
        ; 199:3 for c < 17
        jmp _for_30
_for_30_body:
        ; move r{r1}, r{r8}
        mov dil, bl
        ; move c{r2}, c{r9}
        mov sil, r12b
        ; const arg.0.2{r3}, 0
        mov dl, 0
        ; call setCell@u8@u8@u8[r{r1}, c{r2}, arg.0.2{r3}]
        call _setCell@u8@u8@u8
        ; add c{r9}, c{r9}, 1
        add r12b, 1
_for_30:
        ; branch c{r9} lt 17: for_30_body, for_29_continue
        cmp r12b, 17
        jb _for_30_body
        ; add r{r8}, r{r8}, 1
        add bl, 1
_for_29:
        ; branch r{r8} lt 20: for_29_body, clearField_ret
        cmp bl, 20
        jb _for_29_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void initField@u8@u8
        ;   rsp+32: arg curr_r
        ;   rsp+33: arg curr_c
        ;   rsp+34: var c
        ;   rsp+36: var bombs
        ;   rsp+38: var row
        ;   rsp+40: var column
_initField@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; cast r{r8}(i16), curr_r{r1}(u8)
        movzx bx, dil
        ; cast c{r0}(i16), curr_c{r2}(u8)
        movzx ax, sil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; const bombs{r0}, 17
        mov ax, 17
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; 208:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        jmp _for_31
_for_31_body:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; call t.7{r0} = random16[] -> i16
        call _random16
        ; move row{r1}, t.7{r0}
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
        ; call t.8{r0} = random16[] -> i16
        call _random16
        ; move column{r2}, t.8{r0}
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
        ; 211:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=211:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=211:20], location=211:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=212:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=212:20], location=212:18]]) > 1
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.10{r1}, row{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], row{r0}
        mov [r12], ax
        ; sub t.10{r1}, t.10{r1}, r{r8}
        sub di, bx
        ; call t.9{r0} = abs@i16[t.10{r1}] -> i16
        call _abs@i16
        ; branch t.9{r0} gt 1: if_32_then, or_33
        cmp ax, 1
        jg _if_32_then
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12{r1}, column{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.12{r1}, t.12{r1}, c{r0}
        sub di, ax
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; call t.11{r0} = abs@i16[t.12{r1}] -> i16
        call _abs@i16
        ; branch t.11{r0} lteq 1: for_31_continue, if_32_then
        cmp ax, 1
        jle _for_31_continue
_if_32_then:
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.13{r1}(u8), row{r0}(i16)
        mov dil, al
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.14{r2}(u8), column{r0}(i16)
        mov sil, al
        ; const arg.4.2{r3}, 1
        mov dl, 1
        ; call setCell@u8@u8@u8[t.13{r1}, t.14{r2}, arg.4.2{r3}]
        call _setCell@u8@u8@u8
_for_31_continue:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs{r0}, bombs{r0}, 1
        sub ax, 1
_for_31:
        ; branch bombs{r0} gt 0: for_31_body, initField@u8@u8_ret
        cmp ax, 0
        jg _for_31_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void maybeRevealAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowTo
        ;   rsp+35: var colFrom
        ;   rsp+36: var colTo
        ;   rsp+37: var r
        ;   rsp+38: var c
        ;   rsp+39: var cell
_maybeRevealAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move row{r1}, row{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; call printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; 220:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=220:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=220:30]]) != 0
        ; move row{r1}, row{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; call t.9{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.9{r0} notequals 0: maybeRevealAround@u8@u8_ret, if_34_end
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; move rowFrom{r0}, row{r8}
        mov al, bl
        ; 225:2 if rowFrom > 0
        ; branch rowFrom{r0} lteq 0: if_35_end, if_35_then
        cmp al, 0
        jbe _if_35_end
        ; move rowFrom{r0}, row{r8}
        mov al, bl
        ; sub rowFrom{r0}, rowFrom{r0}, 1
        sub al, 1
_if_35_end:
        ; move rowTo{r3}, row{r8}
        mov dl, bl
        ; add rowTo{r3}, rowTo{r3}, 1
        add dl, 1
        ; 229:2 if rowTo >= 20
        ; branch rowTo{r3} gteq 20: if_36_then, maybeRevealAround@u8@u8.no_critical_edge_22
        cmp dl, 20
        jae _if_36_then
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo{r3}
        mov [r12], dl
        jmp _if_36_end
_if_36_then:
        ; sub rowTo{r3}, rowTo{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo{r3}
        mov [r12], dl
_if_36_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move colFrom{r3}, column{r2}
        mov dl, sil
        ; 234:2 if colFrom > 0
        ; branch colFrom{r3} lteq 0: if_37_end, if_37_then
        cmp dl, 0
        jbe _if_37_end
        ; sub colFrom{r3}, colFrom{r3}, 1
        sub dl, 1
_if_37_end:
        ; move colTo{r4}, column{r2}
        mov cl, sil
        ; add colTo{r4}, colTo{r4}, 1
        add cl, 1
        ; 238:2 if colTo >= 17
        ; branch colTo{r4} gteq 17: if_38_then, maybeRevealAround@u8@u8.no_critical_edge_24
        cmp cl, 17
        jae _if_38_then
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r4}
        mov [r12], cl
        jmp _if_38_end
_if_38_then:
        ; sub colTo{r4}, colTo{r4}, 1
        sub cl, 1
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r4}
        mov [r12], cl
_if_38_end:
        ; move r{r1}, rowFrom{r0}
        mov dil, al
        ; 241:2 for r <= rowTo
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; load colTo{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_39
_for_39_body:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+35]
        ; load colFrom{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c{r0}, colFrom{r3}
        mov al, dl
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom{r3}
        mov [r12], dl
        ; 242:3 for c <= colTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; move c{r2}, c{r0}
        mov sil, al
        jmp _for_40
_for_40_body:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo{r0}
        mov [r12], al
        ; move c{r0}, c{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r{r1} equals row{r8}: and_42, maybeRevealAround@u8@u8.no_critical_edge_26
        cmp dil, bl
        je _and_42
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _if_41_end
_and_42:
        ; branch c{r0} equals column{r2}: maybeRevealAround@u8@u8.no_critical_edge_28, maybeRevealAround@u8@u8.no_critical_edge_29
        cmp al, sil
        je _maybeRevealAround@u8@u8.no_critical_edge_28
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _maybeRevealAround@u8@u8.no_critical_edge_29
_maybeRevealAround@u8@u8.no_critical_edge_28:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        jmp _for_40_continue
_maybeRevealAround@u8@u8.no_critical_edge_29:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
_if_41_end:
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; move c{r2}, c{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; call cell{r0} = getCell@u8@u8[r{r1}, c{r2}] -> u8
        call _getCell@u8@u8
        ; 248:4 if isOpen@u8([ExprVarAccess[varName=cell, index=8, scope=function, type=u8, varIsArray=false, location=248:15]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.10{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.10{r0} notequals 0: for_40_continue, if_43_end
        cmp al, 0
        jne _for_40_continue
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+39]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.11{r3}, cell{r0}
        mov dl, al
        ; or t.11{r3}, t.11{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], sil
        ; call setCell@u8@u8@u8[r{r1}, c{r2}, t.11{r3}]
        call _setCell@u8@u8@u8
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], sil
        ; call maybeRevealAround@u8@u8[r{r1}, c{r2}]
        call _maybeRevealAround@u8@u8
_for_40_continue:
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+38]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c{r2}, c{r2}, 1
        add sil, 1
_for_40:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+36]
        ; load colTo{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; branch c{r2} lteq colTo{r0}: for_40_body, for_39_continue
        cmp sil, al
        jbe _for_40_body
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+37]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add r{r1}, r{r1}, 1
        add dil, 1
_for_39:
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+34]
        ; load rowTo{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch r{r1} lteq rowTo{r2}: for_39_body, maybeRevealAround@u8@u8_ret
        cmp dil, sil
        jbe _for_39_body
_maybeRevealAround@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void main
        ;   rsp+32: var curr_c
        ;   rsp+33: var curr_r
        ;   rsp+34: var chr
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
        ; call printField[]
        call _printField
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const t.6{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.6{r1}]
        call _printString@@u8
        ; const curr_c{r2}, 8
        mov sil, 8
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; const curr_r{r1}, 10
        mov dil, 10
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; 267:2 while true
        jmp _while_44
_if_45_then:
        ; 269:4 if printLeft([])
        ; call t.7{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.7{r0} notequals 0: if_46_then, if_45_end
        cmp al, 0
        jne _if_46_then
_if_45_end:
        ; const t.9{r3}, 1
        mov dl, 1
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call showCursor@u8@u8@bool[curr_r{r1}, curr_c{r2}, t.9{r3}]
        call _showCursor@u8@u8@bool
        ; call chr{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; const t.10{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call showCursor@u8@u8@bool[curr_r{r1}, curr_c{r2}, t.10{r3}]
        call _showCursor@u8@u8@bool
        ; 278:3 if chr == 27
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; branch chr{r0} equals 27: main_ret, if_47_end
        cmp ax, 27
        je _main_ret
        ; branch chr{r0} equals 13: if_48_then, if_48_else
        cmp ax, 13
        je _if_48_then
        ; branch chr{r0} notequals -8120: if_52_else, if_52_then
        cmp ax, -8120
        jne _if_52_else
        jmp _if_52_then
_if_48_then:
        ; branch needsInitialize{r8} equals 0: main.no_critical_edge_39, if_49_then
        cmp bl, 0
        je _main.no_critical_edge_39
        jmp _if_49_then
_if_52_else:
        ; branch chr{r0} notequals -8112: if_54_else, if_54_then
        cmp ax, -8112
        jne _if_54_else
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        jmp _if_54_then
_if_52_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r{r1} lteq 0: main.no_critical_edge_38, if_53_then
        cmp dil, 0
        jbe _main.no_critical_edge_38
        jmp _if_53_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_49_end
_if_49_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; const needsInitialize{r8}, 0
        mov bl, 0
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call initField@u8@u8[curr_r{r1}, curr_c{r2}]
        call _initField@u8@u8
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_49_end
_if_54_else:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals -8117: if_56_else, if_56_then
        cmp ax, -8117
        jne _if_56_else
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        jmp _if_56_then
_if_54_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r{r1} gteq 19: main.no_critical_edge_37, if_55_then
        cmp dil, 19
        jae _main.no_critical_edge_37
        jmp _if_55_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_44
_if_53_then:
        ; sub curr_r{r1}, curr_r{r1}, 1
        sub dil, 1
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_44
_if_49_end:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call cell{r0} = getCell@u8@u8[curr_r{r1}, curr_c{r2}] -> u8
        call _getCell@u8@u8
        ; 288:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=288:16]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.11{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.11{r0} notequals 0: main.no_critical_edge_40, if_50_then
        cmp al, 0
        jne _main.no_critical_edge_40
        jmp _if_50_then
_if_56_else:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals -8115: if_58_else, if_58_then
        cmp ax, -8115
        jne _if_58_else
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        jmp _if_58_then
_if_56_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch curr_c{r2} lteq 0: main.no_critical_edge_36, if_57_then
        cmp sil, 0
        jbe _main.no_critical_edge_36
        jmp _if_57_then
_main.no_critical_edge_37:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        jmp _while_44
_if_55_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add curr_r{r1}, curr_r{r1}, 1
        add dil, 1
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_44
_main.no_critical_edge_40:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _if_50_end
_if_50_then:
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move t.12{r3}, cell{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; or t.12{r3}, t.12{r3}, 2
        or dl, 2
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call setCell@u8@u8@u8[curr_r{r1}, curr_c{r2}, t.12{r3}]
        call _setCell@u8@u8@u8
        jmp _if_50_end
_if_58_else:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals 32: while_44, if_60_then
        cmp ax, 32
        jne _while_44
        jmp _if_60_then
_if_58_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch curr_c{r2} gteq 16: main.no_critical_edge_35, if_59_then
        cmp sil, 16
        jae _main.no_critical_edge_35
        jmp _if_59_then
_main.no_critical_edge_36:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        jmp _while_44
_if_57_then:
        ; sub curr_c{r2}, curr_c{r2}, 1
        sub sil, 1
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        jmp _while_44
_if_50_end:
        ; 291:4 if isBomb@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=291:15]])
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+36]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; call t.13{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.13{r0} equals 0: if_51_end, if_51_then
        cmp al, 0
        je _if_51_end
        jmp _if_51_then
_if_60_then:
        ; branch needsInitialize{r8} notequals 0: while_44, if_61_then
        cmp bl, 0
        jne _while_44
        jmp _if_61_then
_main.no_critical_edge_35:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        jmp _while_44
_if_59_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; add curr_c{r2}, curr_c{r2}, 1
        add sil, 1
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        jmp _while_44
_if_51_end:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call maybeRevealAround@u8@u8[curr_r{r1}, curr_c{r2}]
        call _maybeRevealAround@u8@u8
        jmp _while_44
_if_61_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; call cell{r0} = getCell@u8@u8[curr_r{r1}, curr_c{r2}] -> u8
        call _getCell@u8@u8
        ; 326:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=326:17]])
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call t.15{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.15{r0} notequals 0: while_44, if_62_then
        cmp al, 0
        jne _while_44
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; xor cell{r0}, cell{r0}, 4
        xor al, 4
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; move cell{r3}, cell{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], cell{r0}
        mov [r12], al
        ; call setCell@u8@u8@u8[curr_r{r1}, curr_c{r2}, cell{r3}]
        call _setCell@u8@u8@u8
        ; addrof memVarAddr{r9}, cell
        lea r12, [rsp+37]
        ; load cell{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move cell{r1}, cell{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r3}
        mov [r12], dl
        ; call printCellAt@u8@u8@u8[cell{r1}, curr_r{r2}, curr_c{r3}]
        call _printCellAt@u8@u8@u8
_while_44:
        ; branch needsInitialize{r8} notequals 0: if_45_end, if_45_then
        cmp bl, 0
        jne _if_45_end
        jmp _if_45_then
_if_46_then:
        ; const t.8{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.8{r1}]
        call _printString@@u8
        jmp _main_ret
_if_51_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call printCellAt@u8@u8[curr_r{r1}, curr_c{r2}]
        call _printCellAt@u8@u8
        ; const t.14{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.14{r1}]
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
        string_0 db ' |', 0x0a, 0x00
        string_1 db 'Left:', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

