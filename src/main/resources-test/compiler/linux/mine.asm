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
        ;   rsp+0: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.__random__{r0}, salt{r1}
        mov eax, edi
        ; addrof a.__random__{r1}, __random__
        lea rdi, [var_0]
        ; store [a.__random__{r1}], t.__random__{r0}
        mov [rdi], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.__random__{r1}, __random__
        lea rdi, [var_0]
        ; load t.__random__{r1}, [a.__random__{r1}]
        mov edi, [rdi]
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
        ; add t.__random__1{r2}, t.__random__1{r2}, t.11{r1}
        add esi, edi
        ; addrof a.__random__1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.__random__1{r1}], t.__random__1{r2}
        mov [rdi], esi
        ; 16:9 return __random__
        ; addrof a.__random__2{r1}, __random__
        lea rdi, [var_0]
        ; load t.__random__2{r0}, [a.__random__2{r1}]
        mov eax, [rdi]
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

        ; u8 getBombCountAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowFrom
        ;   rsp+35: var rowTo
        ;   rsp+36: var colFrom
        ;   rsp+37: var colTo
        ;   rsp+38: var count
_getBombCountAround@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move rowFrom{r1}, row{r8}
        mov dil, bl
        ; 23:2 if rowFrom > 0
        ; branch rowFrom{r1} lteq 0: if_4_end, if_4_then
        cmp dil, 0
        jbe _if_4_end
        ; move rowFrom{r1}, row{r8}
        mov dil, bl
        ; sub rowFrom{r1}, rowFrom{r1}, 1
        sub dil, 1
_if_4_end:
        ; move rowTo{r0}, row{r8}
        mov al, bl
        ; add rowTo{r0}, rowTo{r0}, 1
        add al, 1
        ; 27:2 if rowTo >= 20
        ; branch rowTo{r0} gteq 20: if_5_then, getBombCountAround@u8@u8.no_critical_edge_22
        cmp al, 20
        jae _if_5_then
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], rowTo{r0}
        mov [r12], al
        jmp _if_5_end
_if_5_then:
        ; sub rowTo{r0}, rowTo{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], rowTo{r0}
        mov [r12], al
_if_5_end:
        ; move colFrom{r0}, column{r2}
        mov al, sil
        ; 32:2 if colFrom > 0
        ; branch colFrom{r0} lteq 0: if_6_end, if_6_then
        cmp al, 0
        jbe _if_6_end
        ; sub colFrom{r0}, colFrom{r0}, 1
        sub al, 1
_if_6_end:
        ; move colTo{r3}, column{r2}
        mov dl, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; add colTo{r3}, colTo{r3}, 1
        add dl, 1
        ; 36:2 if colTo >= 17
        ; branch colTo{r3} gteq 17: if_7_then, getBombCountAround@u8@u8.no_critical_edge_24
        cmp dl, 17
        jae _if_7_then
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r3}
        mov [r12], dl
        jmp _if_7_end
_if_7_then:
        ; sub colTo{r3}, colTo{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r3}
        mov [r12], dl
_if_7_end:
        ; const count{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, rowFrom
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowFrom{r1}
        mov [r12], dil
        ; move colFrom{r2}, colFrom{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colFrom{r0}
        mov [r12], al
        ; call index{r0} = rowColumnToCell@u8@u8[rowFrom{r1}, colFrom{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r9}, rowFrom
        lea r12, [rsp+34]
        ; load rowFrom{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; 42:2 for r <= rowTo
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; load colFrom{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; load colTo{r6}, [memVarAddr{r9}]
        mov r9b, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; load count{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        jmp _for_8
_for_8_body:
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; load colFrom{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colFrom{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r6}
        mov [r12], r9b
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count{r5}
        mov [r12], r8b
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], rowTo{r3}
        mov [r12], dl
        ; move c{r3}, colFrom{r2}
        mov dl, sil
        ; 43:3 for c <= colTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; load count{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        jmp _for_9
_for_9_body:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r6}
        mov [r12], r9b
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count{r5}
        mov [r12], r8b
        ; branch r{r1} equals row{r8}: and_11, getBombCountAround@u8@u8.no_critical_edge_25
        cmp dil, bl
        je _and_11
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        jmp _if_10_end
_and_11:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; branch c{r3} notequals column{r4}: if_10_end, getBombCountAround@u8@u8.no_critical_edge_27
        cmp dl, cl
        jne _if_10_end
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; load count{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        jmp _for_9_continue
_if_10_end:
        ; cast t.12{r5}(i64), index{r0}(i16)
        movsx r8, ax
        ; addrof t.11{r6}, [field]
        lea r9, [var_1]
        ; add t.11{r6}, t.11{r6}, t.12{r5}
        add r9, r8
        ; load cell{r5}, [t.11{r6}]
        mov r8b, [r9]
        ; 49:4 if cell & 1 != 0
        ; and t.13{r5}, t.13{r5}, 1
        and r8b, 1
        ; branch t.13{r5} notequals 0: if_12_then, getBombCountAround@u8@u8.no_critical_edge_26
        cmp r8b, 0
        jne _if_12_then
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; load count{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        jmp _for_9_continue
_if_12_then:
        ; addrof memVarAddr{r9}, count
        lea r12, [rsp+38]
        ; load count{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        ; add count{r5}, count{r5}, 1
        add r8b, 1
_for_9_continue:
        ; add c{r3}, c{r3}, 1
        add dl, 1
        ; add index{r0}, index{r0}, 1
        add ax, 1
_for_9:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; load colTo{r6}, [memVarAddr{r9}]
        mov r9b, [r12]
        ; branch c{r3} lteq colTo{r6}: for_9_body, for_9_break
        cmp dl, r9b
        jbe _for_9_body
        ; cast t.17{r3}(i16), colTo{r6}(u8)
        movzx dx, r9b
        ; move t.16{r7}, index{r0}
        mov r10w, ax
        ; sub t.16{r7}, t.16{r7}, t.17{r3}
        sub r10w, dx
        ; cast t.18{r3}(i16), colFrom{r2}(u8)
        movzx dx, sil
        ; add t.15{r7}, t.15{r7}, t.18{r3}
        add r10w, dx
        ; move t.14{r3}, t.15{r7}
        mov dx, r10w
        ; add t.14{r3}, t.14{r3}, 17
        add dx, 17
        ; move index{r0}, t.14{r3}
        mov ax, dx
        ; sub index{r0}, index{r0}, 1
        sub ax, 1
        ; add r{r1}, r{r1}, 1
        add dil, 1
_for_8:
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; load rowTo{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch r{r1} lteq rowTo{r3}: for_8_body, for_8_break
        cmp dil, dl
        jbe _for_8_body
        ; 55:9 return count
        ; move count{r0}, count{r5}
        mov al, r8b
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
        ; 60:17 return c + 1 << 1
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
        ; call t.5{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r4}, [field]
        lea rcx, [var_1]
        ; add t.3{r4}, t.3{r4}, t.4{r0}
        add rcx, rax
        ; load cell{r1}, [t.3{r4}]
        mov dil, [rcx]
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
_printCell@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const chr{r8}, 46
        mov bl, 46
        ; 76:2 if cell & 2 != 0
        ; move t.5{r9}, cell{r1}
        mov r12b, dil
        ; and t.5{r9}, t.5{r9}, 2
        and r12b, 2
        ; branch t.5{r9} notequals 0: if_13_then, if_13_else
        cmp r12b, 0
        jne _if_13_then
        ; 90:7 if cell & 4 != 0
        ; move t.7{r9}, cell{r1}
        mov r12b, dil
        ; and t.7{r9}, t.7{r9}, 4
        and r12b, 4
        ; branch t.7{r9} equals 0: if_13_end, if_16_then
        cmp r12b, 0
        je _if_13_end
        jmp _if_16_then
_if_13_then:
        ; 77:3 if cell & 1 != 0
        ; move t.6{r8}, cell{r1}
        mov bl, dil
        ; and t.6{r8}, t.6{r8}, 1
        and bl, 1
        ; branch t.6{r8} equals 0: if_14_else, if_14_then
        cmp bl, 0
        je _if_14_else
        jmp _if_14_then
_if_16_then:
        ; const chr{r8}, 35
        mov bl, 35
        jmp _if_13_end
_if_14_else:
        ; move row{r1}, row{r2}
        mov dil, sil
        ; move column{r2}, column{r3}
        mov sil, dl
        ; call count{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 82:4 if count > 0
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
        ; 98:2 for row < 20
        jmp _for_17
_for_17_body:
        ; const arg.1.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column{r9}, 0
        mov r12b, 0
        ; 100:3 for column < 17
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
        ; call t.5{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r4}, [field]
        lea rcx, [var_1]
        ; add t.3{r4}, t.3{r4}, t.4{r0}
        add rcx, rax
        ; load cell{r1}, [t.3{r4}]
        mov dil, [rcx]
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
        ; const t.6{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.6{r1}]
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
        ; 113:2 if show
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
        ; 119:2 if show
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
        ; 126:2 for i > 0
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
        ; 133:2 if value < 0
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
        ; 141:3 if value == 0
        ; branch value{r1} notequals 0: while_23, while_23_break
        cmp di, 0
        jne _while_23
        ; 146:9 return count
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
        ; 151:2 for r < 20
        jmp _for_25
_for_25_body:
        ; const c{r2}, 0
        mov sil, 0
        ; 152:3 for c < 17
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
        ; call t.6{r0} = rowColumnToCell@u8@u8[r{r1}, c{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5{r1}(i64), t.6{r0}(i16)
        movsx rdi, ax
        ; addrof t.4{r2}, [field]
        lea rsi, [var_1]
        ; add t.4{r2}, t.4{r2}, t.5{r1}
        add rsi, rdi
        ; load cell{r1}, [t.4{r2}]
        mov dil, [rsi]
        ; 154:4 if cell & 6 == 0
        ; and t.7{r1}, t.7{r1}, 6
        and dil, 6
        ; branch t.7{r1} notequals 0: for_26_continue, if_27_then
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
        ; 159:9 return count
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
        ; const arg.2.0{r1}, 23
        mov di, 23
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
        ; 170:15 return count == 0
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
        ; 174:2 if a < 0
        ; branch a{r1} lt 0: if_28_then, if_28_end
        cmp di, 0
        jl _if_28_then
        ; 177:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_28_then:
        ; 175:10 return -a
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
        ; const index{r0}, 0
        mov ax, 0
        ; const i{r1}, 340
        mov di, 340
        ; 182:2 for i > 0
        jmp _for_29
_for_29_body:
        ; const t.2{r2}, 0
        mov sil, 0
        ; cast t.4{r3}(i64), index{r0}(i16)
        movsx rdx, ax
        ; addrof t.3{r4}, [field]
        lea rcx, [var_1]
        ; add t.3{r4}, t.3{r4}, t.4{r3}
        add rcx, rdx
        ; store [t.3{r4}], t.2{r2}
        mov [rcx], sil
        ; sub i{r1}, i{r1}, 1
        sub di, 1
_for_29:
        ; branch i{r1} gt 0: for_29_body, clearField_ret
        cmp di, 0
        jg _for_29_body
        add rsp, 8
        ret

        ; void initField@u8@u8
        ;   rsp+32: arg curr_r
        ;   rsp+33: arg curr_c
        ;   rsp+34: var c
        ;   rsp+36: var bombs
        ;   rsp+38: var row
        ;   rsp+40: var column
        ;   rsp+42: var t.13
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
        ; const bombs{r0}, 23
        mov ax, 23
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs{r0}
        mov [r12], ax
        ; 190:2 for bombs > 0
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
        ; 193:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=193:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=193:20], location=193:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=194:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=194:20], location=194:18]]) > 1
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
        ; branch t.9{r0} gt 1: if_31_then, or_32
        cmp ax, 1
        jg _if_31_then
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
        ; branch t.11{r0} lteq 1: for_30_continue, if_31_then
        cmp ax, 1
        jle _for_30_continue
_if_31_then:
        ; const t.13{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r9}, t.13
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], t.13{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+38]
        ; load row{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.17{r1}(u8), row{r0}(i16)
        mov dil, al
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+40]
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.18{r2}(u8), column{r0}(i16)
        mov sil, al
        ; call t.16{r0} = rowColumnToCell@u8@u8[t.17{r1}, t.18{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.15{r0}(i64), t.16{r0}(i16)
        movsx rax, ax
        ; addrof t.14{r1}, [field]
        lea rdi, [var_1]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rdi, rax
        ; addrof memVarAddr{r9}, t.13
        lea r12, [rsp+42]
        ; load t.13{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; store [t.14{r1}], t.13{r0}
        mov [rdi], al
_for_30_continue:
        ; addrof memVarAddr{r9}, bombs
        lea r12, [rsp+36]
        ; load bombs{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs{r0}, bombs{r0}, 1
        sub ax, 1
_for_30:
        ; branch bombs{r0} gt 0: for_30_body, initField@u8@u8_ret
        cmp ax, 0
        jg _for_30_body
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
        ;   rsp+34: var rowFrom
        ;   rsp+35: var rowTo
        ;   rsp+36: var colFrom
        ;   rsp+37: var colTo
        ;   rsp+38: var index
        ;   rsp+40: var r
        ;   rsp+41: var c
_maybeRevealAround@u8@u8:
        sub rsp, 24
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
        ; 202:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=202:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=202:30]]) != 0
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
        ; call t.11{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.11{r0} notequals 0: maybeRevealAround@u8@u8_ret, if_33_end
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; move rowFrom{r1}, row{r8}
        mov dil, bl
        ; 207:2 if rowFrom > 0
        ; branch rowFrom{r1} lteq 0: if_34_end, if_34_then
        cmp dil, 0
        jbe _if_34_end
        ; move rowFrom{r1}, row{r8}
        mov dil, bl
        ; sub rowFrom{r1}, rowFrom{r1}, 1
        sub dil, 1
_if_34_end:
        ; move rowTo{r0}, row{r8}
        mov al, bl
        ; add rowTo{r0}, rowTo{r0}, 1
        add al, 1
        ; 211:2 if rowTo >= 20
        ; branch rowTo{r0} gteq 20: if_35_then, maybeRevealAround@u8@u8.no_critical_edge_23
        cmp al, 20
        jae _if_35_then
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], rowTo{r0}
        mov [r12], al
        jmp _if_35_end
_if_35_then:
        ; sub rowTo{r0}, rowTo{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], rowTo{r0}
        mov [r12], al
_if_35_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move colFrom{r0}, column{r2}
        mov al, sil
        ; 216:2 if colFrom > 0
        ; branch colFrom{r0} lteq 0: if_36_end, if_36_then
        cmp al, 0
        jbe _if_36_end
        ; sub colFrom{r0}, colFrom{r0}, 1
        sub al, 1
_if_36_end:
        ; move colTo{r3}, column{r2}
        mov dl, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; add colTo{r3}, colTo{r3}, 1
        add dl, 1
        ; 220:2 if colTo >= 17
        ; branch colTo{r3} gteq 17: if_37_then, maybeRevealAround@u8@u8.no_critical_edge_25
        cmp dl, 17
        jae _if_37_then
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r3}
        mov [r12], dl
        jmp _if_37_end
_if_37_then:
        ; sub colTo{r3}, colTo{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r3}
        mov [r12], dl
_if_37_end:
        ; addrof memVarAddr{r9}, rowFrom
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowFrom{r1}
        mov [r12], dil
        ; move colFrom{r2}, colFrom{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colFrom{r0}
        mov [r12], al
        ; call index{r0} = rowColumnToCell@u8@u8[rowFrom{r1}, colFrom{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r9}, rowFrom
        lea r12, [rsp+34]
        ; load rowFrom{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; 224:2 for r <= rowTo
        ; move r{r2}, r{r1}
        mov sil, dil
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; load colFrom{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; load colTo{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _for_38
_for_38_body:
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; load colFrom{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colFrom{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], rowTo{r4}
        mov [r12], cl
        ; move r{r1}, r{r2}
        mov dil, sil
        ; move c{r3}, colFrom{r2}
        mov dl, sil
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colFrom{r2}
        mov [r12], sil
        ; 225:3 for c <= colTo
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; move c{r2}, c{r3}
        mov sil, dl
        jmp _for_39
_for_39_body:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colTo{r1}
        mov [r12], dil
        ; move c{r3}, c{r2}
        mov dl, sil
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; load r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r{r1} notequals row{r8}: if_40_end, and_41
        cmp dil, bl
        jne _if_40_end
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch c{r3} equals column{r2}: maybeRevealAround@u8@u8.no_critical_edge_29, maybeRevealAround@u8@u8.no_critical_edge_30
        cmp dl, sil
        je _maybeRevealAround@u8@u8.no_critical_edge_29
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        jmp _maybeRevealAround@u8@u8.no_critical_edge_30
_maybeRevealAround@u8@u8.no_critical_edge_29:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, index
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], index{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        jmp _for_39_continue
_maybeRevealAround@u8@u8.no_critical_edge_30:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
_if_40_end:
        ; cast t.13{r4}(i64), index{r0}(i16)
        movsx rcx, ax
        ; addrof t.12{r5}, [field]
        lea r8, [var_1]
        ; add t.12{r5}, t.12{r5}, t.13{r4}
        add r8, rcx
        ; load cell{r4}, [t.12{r5}]
        mov cl, [r8]
        ; 231:4 if cell & 2 != 0
        ; move t.14{r5}, cell{r4}
        mov r8b, cl
        ; and t.14{r5}, t.14{r5}, 2
        and r8b, 2
        ; branch t.14{r5} equals 0: if_42_end, maybeRevealAround@u8@u8.no_critical_edge_28
        cmp r8b, 0
        je _if_42_end
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, index
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], index{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        jmp _for_39_continue
_if_42_end:
        ; or t.15{r4}, t.15{r4}, 2
        or cl, 2
        ; cast t.17{r5}(i64), index{r0}(i16)
        movsx r8, ax
        ; addrof memVarAddr{r9}, index
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], index{r0}
        mov [r12], ax
        ; addrof t.16{r0}, [field]
        lea rax, [var_1]
        ; add t.16{r0}, t.16{r0}, t.17{r5}
        add rax, r8
        ; store [t.16{r0}], t.15{r4}
        mov [rax], cl
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], r{r1}
        mov [r12], dil
        ; move c{r2}, c{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dl
        ; call maybeRevealAround@u8@u8[r{r1}, c{r2}]
        call _maybeRevealAround@u8@u8
_for_39_continue:
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+41]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c{r2}, c{r2}, 1
        add sil, 1
        ; addrof memVarAddr{r9}, index
        lea r12, [rsp+38]
        ; load index{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add index{r0}, index{r0}, 1
        add ax, 1
_for_39:
        ; addrof memVarAddr{r9}, colTo
        lea r12, [rsp+37]
        ; load colTo{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch c{r2} lteq colTo{r1}: for_39_body, for_39_break
        cmp sil, dil
        jbe _for_39_body
        ; move t.19{r2}, colTo{r1}
        mov sil, dil
        ; addrof memVarAddr{r9}, colFrom
        lea r12, [rsp+36]
        ; load colFrom{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; sub t.19{r2}, t.19{r2}, colFrom{r3}
        sub sil, dl
        ; add t.18{r2}, t.18{r2}, 1
        add sil, 1
        ; cast colCount{r2}(i16), t.18{r2}(u8)
        movzx si, sil
        ; sub t.20{r0}, t.20{r0}, colCount{r2}
        sub ax, si
        ; add index{r0}, index{r0}, 17
        add ax, 17
        ; addrof memVarAddr{r9}, r
        lea r12, [rsp+40]
        ; load r{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add r{r2}, r{r2}, 1
        add sil, 1
_for_38:
        ; addrof memVarAddr{r9}, rowTo
        lea r12, [rsp+35]
        ; load rowTo{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; branch r{r2} lteq rowTo{r4}: for_38_body, maybeRevealAround@u8@u8_ret
        cmp sil, cl
        jbe _for_38_body
_maybeRevealAround@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var curr_c
        ;   rsp+33: var curr_r
        ;   rsp+34: var chr
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const t.__random__{r8}, 0
        mov ebx, 0
        ; addrof a.__random__{r0}, __random__
        lea rax, [var_0]
        ; store [a.__random__{r0}], t.__random__{r8}
        mov [rax], ebx
        ; end initialize global variables
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
        ; const t.8{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.8{r1}]
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
        ; 253:2 while true
        jmp _while_43
_if_44_then:
        ; 255:4 if printLeft([])
        ; call t.9{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.9{r0} notequals 0: if_45_then, if_44_end
        cmp al, 0
        jne _if_45_then
_if_44_end:
        ; const t.11{r3}, 1
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
        ; call showCursor@u8@u8@bool[curr_r{r1}, curr_c{r2}, t.11{r3}]
        call _showCursor@u8@u8@bool
        ; call chr{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; const t.12{r3}, 0
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
        ; call showCursor@u8@u8@bool[curr_r{r1}, curr_c{r2}, t.12{r3}]
        call _showCursor@u8@u8@bool
        ; 264:3 if chr == 27
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; branch chr{r0} equals 27: main_ret, if_46_end
        cmp ax, 27
        je _main_ret
        ; branch chr{r0} equals 13: if_47_then, if_47_else
        cmp ax, 13
        je _if_47_then
        ; branch chr{r0} notequals -8120: if_51_else, if_51_then
        cmp ax, -8120
        jne _if_51_else
        jmp _if_51_then
_if_47_then:
        ; branch needsInitialize{r8} equals 0: main.no_critical_edge_39, if_48_then
        cmp bl, 0
        je _main.no_critical_edge_39
        jmp _if_48_then
_if_51_else:
        ; branch chr{r0} notequals -8112: if_53_else, if_53_then
        cmp ax, -8112
        jne _if_53_else
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        jmp _if_53_then
_if_51_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r{r1} lteq 0: main.no_critical_edge_38, if_52_then
        cmp dil, 0
        jbe _main.no_critical_edge_38
        jmp _if_52_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_48_end
_if_48_then:
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
        jmp _if_48_end
_if_53_else:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals -8117: if_55_else, if_55_then
        cmp ax, -8117
        jne _if_55_else
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        jmp _if_55_then
_if_53_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r{r1} gteq 19: main.no_critical_edge_37, if_54_then
        cmp dil, 19
        jae _main.no_critical_edge_37
        jmp _if_54_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_52_then:
        ; sub curr_r{r1}, curr_r{r1}, 1
        sub dil, 1
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_48_end:
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
        ; call index{r0} = rowColumnToCell@u8@u8[curr_r{r1}, curr_c{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.14{r3}(i64), index{r0}(i16)
        movsx rdx, ax
        ; addrof t.13{r4}, [field]
        lea rcx, [var_1]
        ; add t.13{r4}, t.13{r4}, t.14{r3}
        add rcx, rdx
        ; load cell{r3}, [t.13{r4}]
        mov dl, [rcx]
        ; 275:4 if cell & 2 == 0
        ; move t.15{r4}, cell{r3}
        mov cl, dl
        ; and t.15{r4}, t.15{r4}, 2
        and cl, 2
        ; branch t.15{r4} notequals 0: main.no_critical_edge_40, if_49_then
        cmp cl, 0
        jne _main.no_critical_edge_40
        jmp _if_49_then
_if_55_else:
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; load chr{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr{r0}
        mov [r12], ax
        ; branch chr{r0} notequals -8115: if_57_else, if_57_then
        cmp ax, -8115
        jne _if_57_else
        jmp _if_57_then
_if_55_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch curr_c{r2} lteq 0: main.no_critical_edge_36, if_56_then
        cmp sil, 0
        jbe _main.no_critical_edge_36
        jmp _if_56_then
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
        jmp _while_43
_if_54_then:
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
        jmp _while_43
_main.no_critical_edge_40:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_49_end
_if_49_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move t.16{r4}, cell{r3}
        mov cl, dl
        ; or t.16{r4}, t.16{r4}, 2
        or cl, 2
        ; cast t.18{r0}(i64), index{r0}(i16)
        movsx rax, ax
        ; addrof t.17{r5}, [field]
        lea r8, [var_1]
        ; add t.17{r5}, t.17{r5}, t.18{r0}
        add r8, rax
        ; store [t.17{r5}], t.16{r4}
        mov [r8], cl
        jmp _if_49_end
_if_57_else:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch chr{r0} notequals 32: main.no_critical_edge_32, if_59_then
        cmp ax, 32
        jne _main.no_critical_edge_32
        jmp _if_59_then
_if_57_then:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_c{r2} gteq 16: main.no_critical_edge_35, if_58_then
        cmp sil, 16
        jae _main.no_critical_edge_35
        jmp _if_58_then
_main.no_critical_edge_36:
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
        jmp _while_43
_if_56_then:
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; load curr_r{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; sub curr_c{r2}, curr_c{r2}, 1
        sub sil, 1
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_49_end:
        ; 278:4 if cell & 1 != 0
        ; move t.19{r0}, cell{r3}
        mov al, dl
        ; and t.19{r0}, t.19{r0}, 1
        and al, 1
        ; branch t.19{r0} equals 0: if_50_end, if_50_then
        cmp al, 0
        je _if_50_end
        jmp _if_50_then
_main.no_critical_edge_32:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_59_then:
        ; branch needsInitialize{r8} notequals 0: main.no_critical_edge_33, if_60_then
        cmp bl, 0
        jne _main.no_critical_edge_33
        jmp _if_60_then
_main.no_critical_edge_35:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_58_then:
        ; add curr_c{r2}, curr_c{r2}, 1
        add sil, 1
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_50_end:
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
        jmp _while_43
_main.no_critical_edge_33:
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r{r1}
        mov [r12], dil
        jmp _while_43
_if_60_then:
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
        ; call index{r0} = rowColumnToCell@u8@u8[curr_r{r1}, curr_c{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.22{r4}(i64), index{r0}(i16)
        movsx rcx, ax
        ; addrof t.21{r5}, [field]
        lea r8, [var_1]
        ; add t.21{r5}, t.21{r5}, t.22{r4}
        add r8, rcx
        ; load cell{r1}, [t.21{r5}]
        mov dil, [r8]
        ; 314:5 if cell & 2 == 0
        ; move t.23{r4}, cell{r1}
        mov cl, dil
        ; and t.23{r4}, t.23{r4}, 2
        and cl, 2
        ; branch t.23{r4} notequals 0: while_43, if_61_then
        cmp cl, 0
        jne _while_43
        ; xor cell{r1}, cell{r1}, 4
        xor dil, 4
        ; cast t.25{r0}(i64), index{r0}(i16)
        movsx rax, ax
        ; addrof t.24{r4}, [field]
        lea rcx, [var_1]
        ; add t.24{r4}, t.24{r4}, t.25{r0}
        add rcx, rax
        ; store [t.24{r4}], cell{r1}
        mov [rcx], dil
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
_while_43:
        ; branch needsInitialize{r8} notequals 0: if_44_end, if_44_then
        cmp bl, 0
        jne _if_44_end
        jmp _if_44_then
_if_45_then:
        ; const t.10{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.10{r1}]
        call _printString@@u8
        jmp _main_ret
_if_50_then:
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
        ; addrof memVarAddr{r9}, curr_c
        lea r12, [rsp+32]
        ; load curr_c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call printCellAt@u8@u8[curr_r{r1}, curr_c{r2}]
        call _printCellAt@u8@u8
        ; const t.20{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.20{r1}]
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

