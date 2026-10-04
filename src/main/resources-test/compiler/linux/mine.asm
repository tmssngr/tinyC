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

        ; i16 rowColumnToCell@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r.1{r1}(i16), row{r1}(u8)
        movzx di, dil
        ; cast c.1{r2}(i16), column{r2}(u8)
        movzx si, sil
        ; 26:19 return r * 40 + c
        ; mul t.5.1{r1}, 40
        movsx rdi, di
        imul  rdi, 40
        ; move t.4.1{r0}, t.5.1{r1}
        mov ax, di
        ; add t.4.1{r0}, c.1{r2}
        add ax, si
        add rsp, 8
        ret

        ; u8 getBombCountAround@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_getBombCountAround@u8@u8:
        sub rsp, 8
        ; call index.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; 31:22 return [...] & 15
        ; cast t.6.1{r1}(i64), index.1{r0}(i16)
        movsx rdi, ax
        ; addrof t.5.1{r2}, field
        lea rsi, [var_1]
        ; add t.5.2{r2}, t.6.1{r1}
        add rsi, rdi
        ; load t.4.1{r1}, [t.5.2{r2}]
        mov dil, [rsi]
        ; move t.3.1{r0}, t.4.1{r1}
        mov al, dil
        ; and t.3.1{r0}, 15
        and al, 15
        add rsp, 8
        ret

        ; i16 columnToX@u8
        ;   rsp+0: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r1}(i16), column{r1}(u8)
        movzx di, dil
        ; 36:2 if false
        ; const t.2.1{r2}, 0
        mov sil, 0
        ; branch t.2.1{r2} notequals 0: if_4_then
        cmp sil, 0
        jne _if_4_then
        ; 40:17 return c + 1 << 1
        ; add t.4.1{r1}, 1
        add di, 1
        ; move t.3.1{r0}, t.4.1{r1}
        mov ax, di
        ; shiftleft t.3.1{r0}, 1
        sal ax, 1
        jmp _columnToX@u8_ret
_if_4_then:
        ; 37:10 return c
        ; move c.1{r0}, c.1{r1}
        mov ax, di
_columnToX@u8_ret:
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
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; call t.5.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r4}, field
        lea rcx, [var_1]
        ; add t.3.2{r4}, t.4.1{r0}
        add rcx, rax
        ; load cell.1{r1}, [t.3.2{r4}]
        mov dil, [rcx]
        ; move row{r2}, row{r8}
        mov sil, bl
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call printCellAt@u8@u8@u8[cell.1{r1}, row{r2}, column{r3}]
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
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.4.1{r1}(i16), row{r2}(u8)
        movzx di, sil
        ; move x.1{r2}, x.1{r0}
        mov si, ax
        ; call setCursor@i16@i16[t.4.1{r1}, x.1{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r8}
        mov dil, bl
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
        ; const chr.1{r8}, 46
        mov bl, 46
        ; 56:2 if cell & 32 != 0
        ; move t.5.1{r9}, cell{r1}
        mov r12b, dil
        ; and t.5.1{r9}, 32
        and r12b, 32
        ; branch t.5.1{r9} notequals 0: if_5_then
        cmp r12b, 0
        jne _if_5_then
        ; 70:7 if cell & 64 != 0
        ; move t.7.1{r9}, cell{r1}
        mov r12b, dil
        ; and t.7.1{r9}, 64
        and r12b, 64
        ; branch t.7.1{r9} equals 0: if_5_end, if_8_then
        cmp r12b, 0
        je _if_5_end
        jmp _if_8_then
_if_5_then:
        ; 57:3 if cell & 128 != 0
        ; move t.6.1{r8}, cell{r1}
        mov bl, dil
        ; and t.6.1{r8}, 128
        and bl, 128
        ; branch t.6.1{r8} equals 0: if_6_else, if_6_then
        cmp bl, 0
        je _if_6_else
        jmp _if_6_then
_if_8_then:
        ; const chr.3{r8}, 35
        mov bl, 35
        jmp _if_5_end
_if_6_else:
        ; move row{r1}, row{r2}
        mov dil, sil
        ; move column{r2}, column{r3}
        mov sil, dl
        ; call count.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; 62:4 if count > 0
        ; branch count.1{r0} lteq 0: if_7_else, if_7_then
        cmp al, 0
        jbe _if_7_else
        jmp _if_7_then
_if_6_then:
        ; const chr.4{r8}, 42
        mov bl, 42
        jmp _if_5_end
_if_7_else:
        ; const chr.5{r8}, 32
        mov bl, 32
        jmp _if_5_end
_if_7_then:
        ; move chr.6{r8}, count.1{r0}
        mov bl, al
        ; add chr.6{r8}, 48
        add bl, 48
_if_5_end:
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

        ; void initializeScreen
_initializeScreen:
        sub rsp, 8
        ; call printField[]
        call _printField
        add rsp, 8
        ret

        ; void printField
        ;   rsp+32: var column.2
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
        ; const row.1{r8}, 0
        mov bl, 0
        ; 89:2 for row < 20
        jmp _for_9
_for_9_body:
        ; cast t.3.1{r1}(i16), row.2{r8}(u8)
        movzx di, bl
        ; const arg.1.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[t.3.1{r1}, arg.1.1{r2}]
        call _setCursor@i16@i16
        ; 91:3 if true
        ; const t.4.1{r0}, 1
        mov al, 1
        ; branch t.4.1{r0} equals 0: if_10_end
        cmp al, 0
        je _if_10_end
        ; const arg.2.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
_if_10_end:
        ; const column.1{r0}, 0
        mov al, 0
        ; 94:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], sil
        jmp _for_11
_for_11_body:
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], sil
        ; 95:4 if true
        ; const t.5.1{r0}, 1
        mov al, 1
        ; branch t.5.1{r0} equals 0: if_12_end
        cmp al, 0
        je _if_12_end
        ; const arg.3.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
_if_12_end:
        ; move row.2{r1}, row.2{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; load column.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call t.8.1{r0} = rowColumnToCell@u8@u8[row.2{r1}, column.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.7.1{r0}(i64), t.8.1{r0}(i16)
        movsx rax, ax
        ; addrof t.6.1{r4}, field
        lea rcx, [var_1]
        ; add t.6.2{r4}, t.7.1{r0}
        add rcx, rax
        ; load cell.1{r1}, [t.6.2{r4}]
        mov dil, [rcx]
        ; move row.2{r2}, row.2{r8}
        mov sil, bl
        ; load column.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call printCell@u8@u8@u8[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@u8@u8
        ; load column.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move column.4{r0}, column.2{r2}
        mov al, sil
        ; add column.4{r0}, 1
        add al, 1
        ; move column.2{r2}, column.4{r0}
        mov sil, al
_for_11:
        ; branch column.2{r2} lt 40: for_11_body
        cmp sil, 40
        jb _for_11_body
        ; 101:3 if true
        ; const t.9.1{r0}, 1
        mov al, 1
        ; branch t.9.1{r0} equals 0: for_9_continue
        cmp al, 0
        je _for_9_continue
        ; const t.10.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
_for_9_continue:
        ; move row.7{r0}, row.2{r8}
        mov al, bl
        ; add row.7{r0}, 1
        add al, 1
        ; move row.2{r8}, row.7{r0}
        mov bl, al
_for_9:
        ; branch row.2{r8} lt 20: for_9_body
        cmp bl, 20
        jb _for_9_body
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
        ;   rsp+36: var x.1
        ;   rsp+38: var chr.2
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
        ; 108:2 if false
        ; const t.6.1{r0}, 0
        mov al, 0
        ; branch t.6.1{r0} notequals 0: if_14_then
        cmp al, 0
        jne _if_14_then
        ; move column{r1}, column{r2}
        mov dil, sil
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.8.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; move t.9.1{r2}, x.1{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, x.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], x.1{r0}
        mov [r12], ax
        ; sub t.9.1{r2}, 1
        sub si, 1
        ; call setCursor@i16@i16[t.8.1{r1}, t.9.1{r2}]
        call _setCursor@i16@i16
        ; const chr.1{r0}, 32
        mov al, 32
        ; 119:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool.no_critical_edge_10, if_16_then
        cmp dl, 0
        je _showCursor@u8@u8@bool.no_critical_edge_10
        jmp _if_16_then
_if_14_then:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} equals 0: showCursor@u8@u8@bool_ret, if_15_then
        cmp dl, 0
        je _showCursor@u8@u8@bool_ret
        jmp _if_15_then
_showCursor@u8@u8@bool.no_critical_edge_10:
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; move chr.2{r1}, chr.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr.2{r1}
        mov [r12], dil
        jmp _if_16_end
_if_16_then:
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; const chr.3{r0}, 91
        mov al, 91
        ; move chr.2{r1}, chr.3{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr.2{r1}
        mov [r12], dil
        jmp _if_16_end
_if_15_then:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move column{r1}, column{r2}
        mov dil, sil
        ; call x.3{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.7.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; move x.3{r2}, x.3{r0}
        mov si, ax
        ; call setCursor@i16@i16[t.7.1{r1}, x.3{r2}]
        call _setCursor@i16@i16
        jmp _showCursor@u8@u8@bool_ret
_if_16_end:
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; load chr.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; cast t.10.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; addrof memVarAddr{r9}, x.1
        lea r12, [rsp+36]
        ; load x.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.11.1{r2}, x.1{r0}
        mov si, ax
        ; add t.11.1{r2}, 1
        add si, 1
        ; call setCursor@i16@i16[t.10.1{r1}, t.11.1{r2}]
        call _setCursor@i16@i16
        ; 125:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_17_then
        cmp dl, 0
        jne _if_17_then
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; load chr.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_17_end
_if_17_then:
        ; const chr.5{r8}, 93
        mov bl, 93
        ; move chr.4{r1}, chr.5{r8}
        mov dil, bl
_if_17_end:
        ; call printChar@u8[chr.4{r1}]
        call _printChar@u8
_showCursor@u8@u8@bool_ret:
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
        jmp _for_18
_for_18_body:
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
_for_18:
        ; branch i.1{r8} gt 0: for_18_body
        cmp bx, 0
        jg _for_18_body
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
        ; 139:2 if value < 0
        ; branch value{r1} gteq 0: while_20
        cmp di, 0
        jge _while_20
        ; const count.3{r2}, 1
        mov sil, 1
        ; neg value.2{r1}, value{r1}
        neg rdi
_while_20:
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
        ; 147:3 if value == 0
        ; branch value.4{r1} notequals 0: while_20
        cmp di, 0
        jne _while_20
        ; 152:9 return count
        ; move count.5{r0}, count.5{r2}
        mov al, sil
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+32: var r.2
        ;   rsp+33: var c.2
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
        mov al, 0
        ; 157:2 for r < 20
        ; move r.2{r1}, r.1{r0}
        mov dil, al
        jmp _for_22
_for_22_body:
        ; const c.1{r0}, 0
        mov al, 0
        ; 158:3 for c < 40
        ; move c.2{r2}, c.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_23
_for_23_body:
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; call t.6.1{r0} = rowColumnToCell@u8@u8[r.2{r1}, c.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5.1{r1}(i64), t.6.1{r0}(i16)
        movsx rdi, ax
        ; addrof t.4.1{r2}, field
        lea rsi, [var_1]
        ; add t.4.2{r2}, t.5.1{r1}
        add rsi, rdi
        ; load cell.1{r1}, [t.4.2{r2}]
        mov dil, [rsi]
        ; 160:4 if cell & 96 == 0
        ; and t.7.1{r1}, 96
        and dil, 96
        ; branch t.7.1{r1} equals 0: if_24_then
        cmp dil, 0
        je _if_24_then
        ; move count.4{r1}, count.3{r8}
        mov di, bx
        jmp _for_23_continue
_if_24_then:
        ; move count.5{r1}, count.3{r8}
        mov di, bx
        ; add count.5{r1}, 1
        add di, 1
_for_23_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+33]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add c.4{r2}, 1
        add sil, 1
        ; move count.3{r8}, count.4{r1}
        mov bx, di
_for_23:
        ; branch c.2{r2} lt 40: for_23_body
        cmp sil, 40
        jb _for_23_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+32]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add r.4{r1}, 1
        add dil, 1
_for_22:
        ; branch r.2{r1} lt 20: for_22_body
        cmp dil, 20
        jb _for_22_body
        ; 165:9 return count
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
        ; const arg.2.0{r1}, 72
        mov di, 72
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
        ; 176:15 return count == 0
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
        ; branch a{r1} lt 0: if_25_then
        cmp di, 0
        jl _if_25_then
        ; 183:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_25_then:
        ; 181:10 return -a
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
        ; const index.1{r0}, 0
        mov ax, 0
        ; const i.1{r1}, 800
        mov di, 800
        ; 188:2 for i > 0
        jmp _for_26
_for_26_body:
        ; const t.2.1{r2}, 0
        mov sil, 0
        ; cast t.4.1{r3}(i64), index.2{r0}(i16)
        movsx rdx, ax
        ; addrof t.3.1{r4}, field
        lea rcx, [var_1]
        ; add t.3.2{r4}, t.4.1{r3}
        add rcx, rdx
        ; store [t.3.2{r4}], t.2.1{r2}
        mov [rcx], sil
        ; sub i.3{r1}, 1
        sub di, 1
        ; add index.3{r0}, 1
        add ax, 1
_for_26:
        ; branch i.2{r1} gt 0: for_26_body
        cmp di, 0
        jg _for_26_body
        add rsp, 8
        ret

        ; void initField@u8@u8
        ;   rsp+32: arg curr_r
        ;   rsp+33: arg curr_c
        ;   rsp+34: var c.1
        ;   rsp+36: var bombs.2
        ;   rsp+38: var row.1
        ;   rsp+40: var column.1
_initField@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; cast r.1{r8}(i16), curr_r{r1}(u8)
        movzx bx, dil
        ; cast c.1{r0}(i16), curr_c{r2}(u8)
        movzx ax, sil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c.1{r0}
        mov [r12], ax
        ; const bombs.1{r0}, 72
        mov ax, 72
        ; 196:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        jmp _for_27
_for_27_body:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        ; call t.7.1{r0} = random16[] -> i16
        call _random16
        ; move row.1{r1}, t.7.1{r0}
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
        ; call t.8.1{r0} = random16[] -> i16
        call _random16
        ; move column.1{r2}, t.8.1{r0}
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
        ; 199:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=199:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=199:20], location=199:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=200:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=200:20], location=200:18]]) > 1
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.10.1{r1}, row.1{r0}
        mov di, ax
        ; sub t.10.1{r1}, r.1{r8}
        sub di, bx
        ; call t.9.1{r0} = abs@i16[t.10.1{r1}] -> i16
        call _abs@i16
        ; branch t.9.1{r0} gt 1: if_28_then
        cmp ax, 1
        jg _if_28_then
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12.1{r1}, column.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.12.1{r1}, c.1{r0}
        sub di, ax
        ; call t.11.1{r0} = abs@i16[t.12.1{r1}] -> i16
        call _abs@i16
        ; branch t.11.1{r0} lteq 1: for_27_continue, if_28_then
        cmp ax, 1
        jle _for_27_continue
_if_28_then:
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+38]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.13.1{r1}(u8), row.1{r0}(i16)
        mov dil, al
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+40]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.14.1{r2}(u8), column.1{r0}(i16)
        mov sil, al
        ; call setBomb@u8@u8[t.13.1{r1}, t.14.1{r2}]
        call _setBomb@u8@u8
_for_27_continue:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+36]
        ; load bombs.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub bombs.5{r0}, 1
        sub ax, 1
_for_27:
        ; branch bombs.2{r0} gt 0: for_27_body
        cmp ax, 0
        jg _for_27_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void setBomb@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
_setBomb@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; call index.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; 208:2 if [...] == 128
        ; cast t.14.1{r1}(i64), index.1{r0}(i16)
        movsx rdi, ax
        ; addrof t.13.1{r2}, field
        lea rsi, [var_1]
        ; add t.13.2{r2}, t.14.1{r1}
        add rsi, rdi
        ; load t.12.1{r1}, [t.13.2{r2}]
        mov dil, [rsi]
        ; branch t.12.1{r1} equals 128: setBomb@u8@u8_ret
        cmp dil, 128
        je _setBomb@u8@u8_ret
        ; const t.15.1{r1}, 128
        mov dil, 128
        ; cast t.17.1{r2}(i64), index.1{r0}(i16)
        movsx rsi, ax
        ; addrof t.16.1{r3}, field
        lea rdx, [var_1]
        ; add t.16.2{r3}, t.17.1{r2}
        add rdx, rsi
        ; store [t.16.2{r3}], t.15.1{r1}
        mov [rdx], dil
        ; move rowFrom.1{r1}, row{r8}
        mov dil, bl
        ; 214:2 if rowFrom > 0
        ; branch rowFrom.1{r1} lteq 0: if_31_end
        cmp dil, 0
        jbe _if_31_end
        ; sub rowFrom.3{r1}, 1
        sub dil, 1
        ; sub index.3{r0}, 40
        sub ax, 40
_if_31_end:
        ; move rowTo.1{r2}, row{r8}
        mov sil, bl
        ; add rowTo.1{r2}, 1
        add sil, 1
        ; 219:2 if rowTo >= 20
        ; branch rowTo.1{r2} lt 20: if_32_end
        cmp sil, 20
        jb _if_32_end
        ; sub rowTo.3{r2}, 1
        sub sil, 1
_if_32_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move colFrom.1{r4}, column{r3}
        mov cl, dl
        ; 224:2 if colFrom > 0
        ; branch colFrom.1{r4} lteq 0: if_33_end
        cmp cl, 0
        jbe _if_33_end
        ; sub colFrom.3{r4}, 1
        sub cl, 1
        ; sub index.6{r0}, 1
        sub ax, 1
_if_33_end:
        ; move colTo.1{r5}, column{r3}
        mov r8b, dl
        ; add colTo.1{r5}, 1
        add r8b, 1
        ; 229:2 if colTo >= 40
        ; branch colTo.1{r5} lt 40: if_34_end
        cmp r8b, 40
        jb _if_34_end
        ; sub colTo.3{r5}, 1
        sub r8b, 1
_if_34_end:
        ; 234:2 for r <= rowTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row{r8}
        mov [r12], bl
        jmp _for_35
_for_35_body:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; load row{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; move c.1{r6}, colFrom.2{r4}
        mov r9b, cl
        ; 235:3 for c <= colTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        jmp _for_36
_for_36_body:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; load row{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; branch r.2{r1} notequals row{r8}: if_37_end
        cmp dil, bl
        jne _if_37_end
        ; branch c.2{r6} notequals column{r3}: if_37_end
        cmp r9b, dl
        jne _if_37_end
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        jmp _for_36_continue
_if_37_end:
        ; cast t.19.1{r7}(i64), index.9{r0}(i16)
        movsx r10, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r3}
        mov [r12], dl
        ; addrof t.18.1{r3}, field
        lea rdx, [var_1]
        ; add t.18.2{r3}, t.19.1{r7}
        add rdx, r10
        ; load cell.1{r3}, [t.18.2{r3}]
        mov dl, [rdx]
        ; 241:4 if cell & 128 == 0
        ; move t.20.1{r7}, cell.1{r3}
        mov r10b, dl
        ; and t.20.1{r7}, 128
        and r10b, 128
        ; branch t.20.1{r7} equals 0: if_39_then
        cmp r10b, 0
        je _if_39_then
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row{r8}
        mov [r12], bl
        jmp _for_36_continue
_if_39_then:
        ; and count.2{r3}, 15
        and dl, 15
        ; add count.3{r3}, 1
        add dl, 1
        ; cast t.22.1{r7}(i64), index.9{r0}(i16)
        movsx r10, ax
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row{r8}
        mov [r12], bl
        ; addrof t.21.1{r8}, field
        lea rbx, [var_1]
        ; add t.21.2{r8}, t.22.1{r7}
        add rbx, r10
        ; store [t.21.2{r8}], count.3{r3}
        mov [rbx], dl
_for_36_continue:
        ; move c.5{r3}, c.2{r6}
        mov dl, r9b
        ; add c.5{r3}, 1
        add dl, 1
        ; add index.13{r0}, 1
        add ax, 1
        ; move c.2{r6}, c.5{r3}
        mov r9b, dl
_for_36:
        ; branch c.2{r6} lteq colTo.2{r5}: for_36_body
        cmp r9b, r8b
        jbe _for_36_body
        ; cast t.26.1{r3}(i16), colTo.2{r5}(u8)
        movzx dx, r8b
        ; sub t.25.1{r0}, t.26.1{r3}
        sub ax, dx
        ; cast t.27.1{r3}(i16), colFrom.2{r4}(u8)
        movzx dx, cl
        ; add t.24.1{r0}, t.27.1{r3}
        add ax, dx
        ; add t.23.1{r0}, 40
        add ax, 40
        ; sub index.10{r0}, 1
        sub ax, 1
        ; add r.4{r1}, 1
        add dil, 1
_for_35:
        ; branch r.2{r1} lteq rowTo.2{r2}: for_35_body, setBomb@u8@u8_ret
        cmp dil, sil
        jbe _for_35_body
_setBomb@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void maybeRevealAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var r.2
        ;   rsp+36: var index.3
        ;   rsp+38: var c.2
        ;   rsp+39: var rowFrom.2
        ;   rsp+40: var rowTo.2
        ;   rsp+41: var colFrom.2
        ;   rsp+42: var colTo.2
        ;   rsp+43: var neighborRow.2
        ;   rsp+44: var neighborIndex.3
        ;   rsp+46: var neighborColumn.2
_maybeRevealAround@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], sil
        ; call printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; 253:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=253:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=253:30]]) != 0
        ; move row{r1}, row{r8}
        mov dil, bl
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call t.15.1{r0} = getBombCountAround@u8@u8[row{r1}, column{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.15.1{r0} notequals 0: maybeRevealAround@u8@u8_ret
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; const changed.1{r8}, 1
        mov bl, 1
        ; 258:2 while changed
        jmp _while_41
_while_41_body:
        ; const changed.3{r8}, 0
        mov bl, 0
        ; const index.1{r0}, 0
        mov ax, 0
        ; const r.1{r3}, 0
        mov dl, 0
        ; 261:3 for r < 20
        ; move r.2{r1}, r.1{r3}
        mov dil, dl
        ; move index.2{r2}, index.2{r0}
        mov si, ax
        ; move r.2{r0}, r.2{r1}
        mov al, dil
        ; move index.2{r1}, index.2{r2}
        mov di, si
        jmp _for_42
_for_42_body:
        ; move index.2{r2}, index.2{r1}
        mov si, di
        ; move r.2{r1}, r.2{r0}
        mov dil, al
        ; move index.2{r0}, index.2{r2}
        mov ax, si
        ; const c.1{r3}, 0
        mov dl, 0
        ; 262:4 for c < 40
        ; move c.2{r2}, c.1{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; move index.3{r1}, index.3{r0}
        mov di, ax
        jmp _for_43
_for_43_body:
        ; move index.3{r0}, index.3{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.17.1{r3}(i64), index.3{r0}(i16)
        movsx rdx, ax
        ; addrof memVarAddr{r9}, index.3
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.3{r0}
        mov [r12], ax
        ; addrof t.16.1{r0}, field
        lea rax, [var_1]
        ; add t.16.2{r0}, t.17.1{r3}
        add rax, rdx
        ; load cell.1{r0}, [t.16.2{r0}]
        mov al, [rax]
        ; 264:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.18.1{r3}, cell.1{r0}
        mov dl, al
        ; and t.18.1{r3}, 32
        and dl, 32
        ; branch t.18.1{r3} notequals 0: or_45
        cmp dl, 0
        jne _or_45
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        jmp _for_43_continue
_or_45:
        ; and t.19.1{r0}, 128
        and al, 128
        ; branch t.19.1{r0} equals 0: if_44_end
        cmp al, 0
        je _if_44_end
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_43_continue
_if_44_end:
        ; 267:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=267:28], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=267:31]]) != 0
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; call t.20.1{r0} = getBombCountAround@u8@u8[r.2{r1}, c.2{r2}] -> u8
        call _getBombCountAround@u8@u8
        ; branch t.20.1{r0} notequals 0: for_43_continue
        cmp al, 0
        jne _for_43_continue
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move rowFrom.1{r0}, r.2{r1}
        mov al, dil
        ; 272:5 if rowFrom > 0
        ; branch rowFrom.1{r0} lteq 0: if_47_end
        cmp al, 0
        jbe _if_47_end
        ; sub rowFrom.3{r0}, 1
        sub al, 1
_if_47_end:
        ; move rowTo.1{r3}, r.2{r1}
        mov dl, dil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; add rowTo.1{r3}, 1
        add dl, 1
        ; 276:5 if rowTo >= 20
        ; branch rowTo.1{r3} gteq 20: if_48_then
        cmp dl, 20
        jae _if_48_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp _if_48_end
_if_48_then:
        ; sub rowTo.3{r3}, 1
        sub dl, 1
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
_if_48_end:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move colFrom.1{r3}, c.2{r2}
        mov dl, sil
        ; 281:5 if colFrom > 0
        ; branch colFrom.1{r3} lteq 0: if_49_end
        cmp dl, 0
        jbe _if_49_end
        ; sub colFrom.3{r3}, 1
        sub dl, 1
_if_49_end:
        ; move colTo.1{r4}, c.2{r2}
        mov cl, sil
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; add colTo.1{r4}, 1
        add cl, 1
        ; 285:5 if colTo >= 40
        ; branch colTo.1{r4} gteq 40: if_50_then
        cmp cl, 40
        jae _if_50_then
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], colTo.2{r4}
        mov [r12], cl
        jmp _if_50_end
_if_50_then:
        ; sub colTo.3{r4}, 1
        sub cl, 1
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], colTo.2{r4}
        mov [r12], cl
_if_50_end:
        ; move rowFrom.2{r1}, rowFrom.2{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, rowFrom.2
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], rowFrom.2{r0}
        mov [r12], al
        ; move colFrom.2{r2}, colFrom.2{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], colFrom.2{r3}
        mov [r12], dl
        ; call neighborIndex.1{r0} = rowColumnToCell@u8@u8[rowFrom.2{r1}, colFrom.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; addrof memVarAddr{r9}, rowFrom.2
        lea r12, [rsp+39]
        ; load rowFrom.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move neighborRow.1{r4}, rowFrom.2{r1}
        mov cl, dil
        ; 289:5 for neighborRow <= rowTo
        ; move neighborRow.2{r2}, neighborRow.1{r4}
        mov sil, cl
        ; move neighborIndex.2{r1}, neighborIndex.2{r0}
        mov di, ax
        ; move neighborRow.2{r3}, neighborRow.2{r2}
        mov dl, sil
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+41]
        ; load colFrom.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+42]
        ; load colTo.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_51
_for_51_body:
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], colFrom.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], colTo.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], rowTo.2{r4}
        mov [r12], cl
        ; move neighborIndex.2{r0}, neighborIndex.2{r1}
        mov ax, di
        ; move neighborRow.2{r2}, neighborRow.2{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+41]
        ; load colFrom.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move neighborColumn.1{r5}, colFrom.2{r4}
        mov r8b, cl
        ; 290:6 for neighborColumn <= colTo
        ; move neighborColumn.2{r3}, neighborColumn.1{r5}
        mov dl, r8b
        ; addrof memVarAddr{r9}, neighborRow.2
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], neighborRow.2{r2}
        mov [r12], sil
        jmp _for_52
_for_52_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], colTo.2{r0}
        mov [r12], al
        ; move neighborIndex.3{r0}, neighborIndex.3{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, neighborRow.2
        lea r12, [rsp+43]
        ; load neighborRow.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.22.1{r4}(i64), neighborIndex.3{r0}(i16)
        movsx rcx, ax
        ; addrof t.21.1{r5}, field
        lea r8, [var_1]
        ; add t.21.2{r5}, t.22.1{r4}
        add r8, rcx
        ; load neighborCell.1{r4}, [t.21.2{r5}]
        mov cl, [r8]
        ; 292:7 if neighborCell & 32 != 0
        ; move t.23.1{r5}, neighborCell.1{r4}
        mov r8b, cl
        ; and t.23.1{r5}, 32
        and r8b, 32
        ; branch t.23.1{r5} equals 0: if_53_end
        cmp r8b, 0
        je _if_53_end
        ; addrof memVarAddr{r9}, neighborColumn.2
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], neighborColumn.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, neighborIndex.3
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], neighborIndex.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, neighborRow.2
        lea r12, [rsp+43]
        jmp _for_52_continue
_if_53_end:
        ; move t.24.1{r8}, neighborCell.1{r4}
        mov bl, cl
        ; or t.24.1{r8}, 32
        or bl, 32
        ; cast t.26.1{r4}(i64), neighborIndex.3{r0}(i16)
        movsx rcx, ax
        ; addrof t.25.1{r5}, field
        lea r8, [var_1]
        ; add t.25.2{r5}, t.26.1{r4}
        add r8, rcx
        ; store [t.25.2{r5}], t.24.1{r8}
        mov [r8], bl
        ; move t.29.1{r8}, t.29.1{r4}
        mov rbx, rcx
        ; addrof memVarAddr{r9}, neighborIndex.3
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], neighborIndex.3{r0}
        mov [r12], ax
        ; addrof t.28.1{r0}, field
        lea rax, [var_1]
        ; move t.28.2{r0}, t.28.2{r5}
        mov rax, r8
        ; load t.27.1{r1}, [t.28.2{r0}]
        mov dil, [rax]
        ; addrof memVarAddr{r9}, neighborRow.2
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], neighborRow.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, neighborColumn.2
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], neighborColumn.2{r3}
        mov [r12], dl
        ; call printCellAt@u8@u8@u8[t.27.1{r1}, neighborRow.2{r2}, neighborColumn.2{r3}]
        call _printCellAt@u8@u8@u8
        ; const changed.14{r0}, 1
        mov al, 1
        ; move changed.13{r8}, changed.14{r0}
        mov bl, al
_for_52_continue:
        ; addrof memVarAddr{r9}, neighborColumn.2
        lea r12, [rsp+46]
        ; load neighborColumn.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move neighborColumn.4{r0}, neighborColumn.2{r3}
        mov al, dl
        ; add neighborColumn.4{r0}, 1
        add al, 1
        ; addrof memVarAddr{r9}, neighborIndex.3
        lea r12, [rsp+44]
        ; load neighborIndex.3{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add neighborIndex.6{r1}, 1
        add di, 1
        ; move neighborColumn.2{r3}, neighborColumn.4{r0}
        mov dl, al
_for_52:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+42]
        ; load colTo.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; branch neighborColumn.2{r3} lteq colTo.2{r0}: for_52_body
        cmp dl, al
        jbe _for_52_body
        ; cast t.33.1{r2}(i16), colTo.2{r0}(u8)
        movzx si, al
        ; sub t.32.1{r1}, t.33.1{r2}
        sub di, si
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+41]
        ; load colFrom.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.34.1{r3}(i16), colFrom.2{r2}(u8)
        movzx dx, sil
        ; add t.31.1{r1}, t.34.1{r3}
        add di, dx
        ; add t.30.1{r1}, 40
        add di, 40
        ; sub neighborIndex.4{r1}, 1
        sub di, 1
        ; addrof memVarAddr{r9}, neighborRow.2
        lea r12, [rsp+43]
        ; load neighborRow.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; add neighborRow.4{r3}, 1
        add dl, 1
_for_51:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+40]
        ; load rowTo.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; branch neighborRow.2{r3} lteq rowTo.2{r4}: for_51_body, for_43_continue
        cmp dl, cl
        jbe _for_51_body
_for_43_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.4{r0}, c.2{r2}
        mov al, sil
        ; add c.4{r0}, 1
        add al, 1
        ; addrof memVarAddr{r9}, index.3
        lea r12, [rsp+36]
        ; load index.3{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add index.5{r1}, 1
        add di, 1
        ; move c.2{r2}, c.4{r0}
        mov sil, al
_for_43:
        ; branch c.2{r2} lt 40: for_43_body
        cmp sil, 40
        jb _for_43_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add r.4{r0}, 1
        add al, 1
_for_42:
        ; branch r.2{r0} lt 20: for_42_body, while_41
        cmp al, 20
        jb _for_42_body
_while_41:
        ; branch changed.2{r8} notequals 0: while_41_body, maybeRevealAround@u8@u8_ret
        cmp bl, 0
        jne _while_41_body
_maybeRevealAround@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var curr_c.2
        ;   rsp+33: var curr_r.2
        ;   rsp+34: var chr.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const t.8.1{r8}, 0
        mov ebx, 0
        ; addrof a.9.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.9.1{r0}], t.8.1{r8}
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
        ; call initializeScreen[]
        call _initializeScreen
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const t.10.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        ; const curr_c.1{r0}, 20
        mov al, 20
        ; const curr_r.1{r1}, 10
        mov dil, 10
        ; 316:2 while true
        ; move curr_c.2{r2}, curr_c.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_55_then:
        ; 318:4 if printLeft([])
        ; call t.11.1{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.11.1{r0} notequals 0: if_56_then, if_55_end
        cmp al, 0
        jne _if_56_then
_if_55_end:
        ; const t.13.1{r3}, 1
        mov dl, 1
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call showCursor@u8@u8@bool[curr_r.2{r1}, curr_c.2{r2}, t.13.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; const t.14.1{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call showCursor@u8@u8@bool[curr_r.2{r1}, curr_c.2{r2}, t.14.1{r3}]
        call _showCursor@u8@u8@bool
        ; 327:3 if chr == 27
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; load chr.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 13: if_58_then
        cmp ax, 13
        je _if_58_then
        ; branch chr.1{r0} notequals -8120: if_62_else, if_62_then
        cmp ax, -8120
        jne _if_62_else
        jmp _if_62_then
_if_58_then:
        ; branch needsInitialize.2{r8} equals 0: main.no_critical_edge_39, if_59_then
        cmp bl, 0
        je _main.no_critical_edge_39
        jmp _if_59_then
_if_62_else:
        ; branch chr.1{r0} notequals -8112: if_64_else, if_64_then
        cmp ax, -8112
        jne _if_64_else
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        jmp _if_64_then
_if_62_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r.2{r1} lteq 0: main.no_critical_edge_38, if_63_then
        cmp dil, 0
        jbe _main.no_critical_edge_38
        jmp _if_63_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        jmp _if_59_end
_if_59_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; const needsInitialize.5{r8}, 0
        mov bl, 0
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call initField@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _initField@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_59_end
_if_64_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_66_else, if_66_then
        cmp ax, -8117
        jne _if_66_else
        jmp _if_66_then
_if_64_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_r.2{r1} gteq 19: main.no_critical_edge_37, if_65_then
        cmp dil, 19
        jae _main.no_critical_edge_37
        jmp _if_65_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_63_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move curr_r.5{r0}, curr_r.2{r1}
        mov al, dil
        ; sub curr_r.5{r0}, 1
        sub al, 1
        ; move curr_r.2{r1}, curr_r.5{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_59_end:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; call index.1{r0} = rowColumnToCell@u8@u8[curr_r.2{r1}, curr_c.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.16.1{r3}(i64), index.1{r0}(i16)
        movsx rdx, ax
        ; addrof t.15.1{r4}, field
        lea rcx, [var_1]
        ; add t.15.2{r4}, t.16.1{r3}
        add rcx, rdx
        ; load cell.1{r3}, [t.15.2{r4}]
        mov dl, [rcx]
        ; 338:4 if cell & 32 == 0
        ; move t.17.1{r4}, cell.1{r3}
        mov cl, dl
        ; and t.17.1{r4}, 32
        and cl, 32
        ; branch t.17.1{r4} notequals 0: main.no_critical_edge_40, if_60_then
        cmp cl, 0
        jne _main.no_critical_edge_40
        jmp _if_60_then
_if_66_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_68_else, if_68_then
        cmp ax, -8115
        jne _if_68_else
        jmp _if_68_then
_if_66_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch curr_c.2{r2} lteq 0: main.no_critical_edge_36, if_67_then
        cmp sil, 0
        jbe _main.no_critical_edge_36
        jmp _if_67_then
_main.no_critical_edge_37:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_54
_if_65_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move curr_r.6{r0}, curr_r.2{r1}
        mov al, dil
        ; add curr_r.6{r0}, 1
        add al, 1
        ; move curr_r.2{r1}, curr_r.6{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_main.no_critical_edge_40:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_60_end
_if_60_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move t.18.1{r4}, cell.1{r3}
        mov cl, dl
        ; or t.18.1{r4}, 32
        or cl, 32
        ; cast t.20.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.19.1{r5}, field
        lea r8, [var_1]
        ; add t.19.2{r5}, t.20.1{r0}
        add r8, rax
        ; store [t.19.2{r5}], t.18.1{r4}
        mov [r8], cl
        jmp _if_60_end
_if_68_else:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch chr.1{r0} notequals 32: main.no_critical_edge_32, if_70_then
        cmp ax, 32
        jne _main.no_critical_edge_32
        jmp _if_70_then
_if_68_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch curr_c.2{r2} gteq 39: main.no_critical_edge_35, if_69_then
        cmp sil, 39
        jae _main.no_critical_edge_35
        jmp _if_69_then
_main.no_critical_edge_36:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_54
_if_67_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move curr_c.6{r0}, curr_c.2{r2}
        mov al, sil
        ; sub curr_c.6{r0}, 1
        sub al, 1
        ; move curr_c.2{r2}, curr_c.6{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_54
_if_60_end:
        ; 341:4 if cell & 128 != 0
        ; move t.21.1{r0}, cell.1{r3}
        mov al, dl
        ; and t.21.1{r0}, 128
        and al, 128
        ; branch t.21.1{r0} equals 0: if_61_end, if_61_then
        cmp al, 0
        je _if_61_end
        jmp _if_61_then
_main.no_critical_edge_32:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_70_then:
        ; branch needsInitialize.2{r8} notequals 0: main.no_critical_edge_33, if_71_then
        cmp bl, 0
        jne _main.no_critical_edge_33
        jmp _if_71_then
_main.no_critical_edge_35:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_69_then:
        ; move curr_c.7{r0}, curr_c.2{r2}
        mov al, sil
        ; add curr_c.7{r0}, 1
        add al, 1
        ; move curr_c.2{r2}, curr_c.7{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_61_end:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; call maybeRevealAround@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _maybeRevealAround@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_54
_main.no_critical_edge_33:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        jmp _while_54
_if_71_then:
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; call index.2{r0} = rowColumnToCell@u8@u8[curr_r.2{r1}, curr_c.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.24.1{r4}(i64), index.2{r0}(i16)
        movsx rcx, ax
        ; addrof t.23.1{r5}, field
        lea r8, [var_1]
        ; add t.23.2{r5}, t.24.1{r4}
        add r8, rcx
        ; load cell.3{r4}, [t.23.2{r5}]
        mov cl, [r8]
        ; 377:5 if cell & 32 == 0
        ; move t.25.1{r5}, cell.3{r4}
        mov r8b, cl
        ; and t.25.1{r5}, 32
        and r8b, 32
        ; branch t.25.1{r5} equals 0: if_72_then
        cmp r8b, 0
        je _if_72_then
        ; load curr_c.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        jmp _while_54
_if_72_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; load curr_c.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move cell.4{r1}, cell.3{r4}
        mov dil, cl
        ; xor cell.4{r1}, 64
        xor dil, 64
        ; cast t.27.1{r0}(i64), index.2{r0}(i16)
        movsx rax, ax
        ; addrof t.26.1{r4}, field
        lea rcx, [var_1]
        ; add t.26.2{r4}, t.27.1{r0}
        add rcx, rax
        ; store [t.26.2{r4}], cell.4{r1}
        mov [rcx], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; call printCellAt@u8@u8@u8[cell.4{r1}, curr_r.2{r2}, curr_c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load curr_c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; load curr_r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
_while_54:
        ; branch needsInitialize.2{r8} notequals 0: if_55_end, if_55_then
        cmp bl, 0
        jne _if_55_end
        jmp _if_55_then
_if_56_then:
        ; const t.12.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.12.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_61_then:
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], curr_c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, curr_r.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], curr_r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, curr_c.2
        lea r12, [rsp+32]
        ; call printCellAt@u8@u8[curr_r.2{r1}, curr_c.2{r2}]
        call _printCellAt@u8@u8
        ; const t.22.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.22.1{r1}]
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
        ; variable 1: field[] (u8*/6400)
        var_1 rb 6400

segment readable
        string_0 db ' |', 0x00
        string_1 db 'Left:', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

