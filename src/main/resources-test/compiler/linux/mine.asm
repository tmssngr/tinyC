format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
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

        ; i64 strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rsi, 0
        ; 73:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rsi
        jmp _for_1
_for_1_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_1:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_1_body
        cmp sil, 0
        jne _for_1_body
        ; 76:9 return length
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
        ; 20:25 return (i16) & 32767
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
        ; 33:19 return r * 40 + c
        ; mul t.5.1{r1}, 40
        movsx rdi, di
        imul  rdi, 40
        ; move t.4.1{r0}, t.5.1{r1}
        mov ax, di
        ; add t.4.1{r0}, c.1{r2}
        add ax, si
        add rsp, 8
        ret

        ; i16 columnToX@u8
        ;   rsp+0: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r1}(i16), column{r1}(u8)
        movzx di, dil
        ; 42:17 return c + 1 << 1
        ; add t.3.1{r1}, 1
        add di, 1
        ; move t.2.1{r0}, t.3.1{r1}
        mov ax, di
        ; shiftleft t.2.1{r0}, 1
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
        ;   rsp+24: arg cell
        ;   rsp+25: arg row
        ;   rsp+26: arg column
_printCell@u8@u8@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const chr.1{r8}, 46
        mov bl, 46
        ; 58:2 if cell & 32 != 0
        ; move t.6.1{r0}, cell{r1}
        mov al, dil
        ; and t.6.1{r0}, 32
        and al, 32
        ; branch t.6.1{r0} notequals 0: if_2_then
        cmp al, 0
        jne _if_2_then
        ; 73:7 if cell & 64 != 0
        ; move t.11.1{r0}, cell{r1}
        mov al, dil
        ; and t.11.1{r0}, 64
        and al, 64
        ; branch t.11.1{r0} equals 0: if_2_end, if_5_then
        cmp al, 0
        je _if_2_end
        jmp _if_5_then
_if_2_then:
        ; 59:3 if cell & 128 != 0
        ; move t.7.1{r8}, cell{r1}
        mov bl, dil
        ; and t.7.1{r8}, 128
        and bl, 128
        ; branch t.7.1{r8} equals 0: if_3_else, if_3_then
        cmp bl, 0
        je _if_3_else
        jmp _if_3_then
_if_5_then:
        ; const chr.3{r8}, 35
        mov bl, 35
        jmp _if_2_end
_if_3_else:
        ; move row{r1}, row{r2}
        mov dil, sil
        ; move column{r2}, column{r3}
        mov sil, dl
        ; call index.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.10.1{r8}(i64), index.1{r0}(i16)
        movsx rbx, ax
        ; addrof t.9.1{r0}, field
        lea rax, [var_1]
        ; add t.9.2{r0}, t.10.1{r8}
        add rax, rbx
        ; load t.8.1{r8}, [t.9.2{r0}]
        mov bl, [rax]
        ; and count.1{r8}, 15
        and bl, 15
        ; 65:4 if count > 0
        ; branch count.1{r8} lteq 0: if_4_else, if_4_then
        cmp bl, 0
        jbe _if_4_else
        jmp _if_4_then
_if_3_then:
        ; const chr.4{r8}, 42
        mov bl, 42
        jmp _if_2_end
_if_4_else:
        ; const chr.5{r8}, 32
        mov bl, 32
        jmp _if_2_end
_if_4_then:
        ; add chr.6{r8}, 48
        add bl, 48
_if_2_end:
        ; move chr.2{r1}, chr.2{r8}
        mov dil, bl
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
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
        ; 92:2 for row < 20
        jmp _for_6
_for_6_body:
        ; cast t.3.1{r1}(i16), row.2{r8}(u8)
        movzx di, bl
        ; const arg.1.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[t.3.1{r1}, arg.1.1{r2}]
        call _setCursor@i16@i16
        ; const arg.2.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; const column.1{r0}, 0
        mov al, 0
        ; 97:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], sil
        jmp _for_7
_for_7_body:
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], sil
        ; const arg.3.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; move row.2{r1}, row.2{r8}
        mov dil, bl
        ; load column.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call t.6.1{r0} = rowColumnToCell@u8@u8[row.2{r1}, column.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5.1{r0}(i64), t.6.1{r0}(i16)
        movsx rax, ax
        ; addrof t.4.1{r4}, field
        lea rcx, [var_1]
        ; add t.4.2{r4}, t.5.1{r0}
        add rcx, rax
        ; load cell.1{r1}, [t.4.2{r4}]
        mov dil, [rcx]
        ; move row.2{r2}, row.2{r8}
        mov sil, bl
        ; load column.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call printCell@u8@u8@u8[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@u8@u8
        ; load column.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move column.3{r0}, column.2{r2}
        mov al, sil
        ; add column.3{r0}, 1
        add al, 1
        ; move column.2{r2}, column.3{r0}
        mov sil, al
_for_7:
        ; branch column.2{r2} lt 40: for_7_body
        cmp sil, 40
        jb _for_7_body
        ; const t.7.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; move row.4{r0}, row.2{r8}
        mov al, bl
        ; add row.4{r0}, 1
        add al, 1
        ; move row.2{r8}, row.4{r0}
        mov bl, al
_for_6:
        ; branch row.2{r8} lt 20: for_6_body
        cmp bl, 20
        jb _for_6_body
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
        ; move column{r1}, column{r2}
        mov dil, sil
        ; call x.1{r0} = columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; cast t.6.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; move t.7.1{r2}, x.1{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, x.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], x.1{r0}
        mov [r12], ax
        ; sub t.7.1{r2}, 1
        sub si, 1
        ; call setCursor@i16@i16[t.6.1{r1}, t.7.1{r2}]
        call _setCursor@i16@i16
        ; const chr.1{r0}, 32
        mov al, 32
        ; 122:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_8_then
        cmp dl, 0
        jne _if_8_then
        ; move chr.2{r1}, chr.1{r0}
        mov dil, al
        jmp _if_8_end
_if_8_then:
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], show{r3}
        mov [r12], dl
        ; const chr.3{r0}, 91
        mov al, 91
        ; move chr.2{r1}, chr.3{r0}
        mov dil, al
_if_8_end:
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr.2{r1}
        mov [r12], dil
        ; call printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; cast t.8.1{r1}(i16), row{r8}(u8)
        movzx di, bl
        ; addrof memVarAddr{r9}, x.1
        lea r12, [rsp+36]
        ; load x.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.9.1{r2}, x.1{r0}
        mov si, ax
        ; add t.9.1{r2}, 1
        add si, 1
        ; call setCursor@i16@i16[t.8.1{r1}, t.9.1{r2}]
        call _setCursor@i16@i16
        ; 128:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_9_then
        cmp dl, 0
        jne _if_9_then
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; load chr.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_9_end
_if_9_then:
        ; const chr.5{r8}, 93
        mov bl, 93
        ; move chr.4{r1}, chr.5{r8}
        mov dil, bl
_if_9_end:
        ; call printChar@u8[chr.4{r1}]
        call _printChar@u8
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
        ; branch a{r1} lt 0: if_10_then
        cmp di, 0
        jl _if_10_then
        ; 186:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
_if_10_then:
        ; 184:10 return -a
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
        ; 191:2 for i > 0
        jmp _for_11
_for_11_body:
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
_for_11:
        ; branch i.2{r1} gt 0: for_11_body
        cmp di, 0
        jg _for_11_body
        add rsp, 8
        ret

        ; i16 initField@u8@u8
        ;   rsp+32: arg curr_r
        ;   rsp+33: arg curr_c
        ;   rsp+34: var c.1
        ;   rsp+36: var bombCount.2
        ;   rsp+38: var bombs.2
        ;   rsp+40: var row.1
        ;   rsp+42: var column.1
        ;   rsp+44: var bombCount.4
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
        ; const bombCount.1{r0}, 0
        mov ax, 0
        ; const bombs.1{r1}, 72
        mov di, 72
        ; 200:2 for bombs > 0
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombCount.2{r0}
        mov [r12], ax
        ; move bombs.2{r0}, bombs.1{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombs.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+38]
        ; move bombs.2{r2}, bombs.2{r1}
        mov si, di
        jmp _for_12
_for_12_body:
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombCount.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombs.2{r2}
        mov [r12], si
        ; call t.8.1{r0} = random16[] -> i16
        call _random16
        ; mod row.1{r3}, row.1{r0}, 20
        movsx rax, ax
        cqo
        mov rcx, 20
        idiv rcx
        ; move row.1{r1}, row.1{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], row.1{r1}
        mov [r12], di
        ; call t.9.1{r0} = random16[] -> i16
        call _random16
        ; mod column.1{r3}, column.1{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move column.1{r2}, column.1{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], column.1{r2}
        mov [r12], si
        ; 203:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=203:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=203:20], location=203:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=204:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=204:20], location=204:18]]) > 1
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+40]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.11.1{r1}, row.1{r0}
        mov di, ax
        ; sub t.11.1{r1}, r.1{r8}
        sub di, bx
        ; call t.10.1{r0} = abs@i16[t.11.1{r1}] -> i16
        call _abs@i16
        ; branch t.10.1{r0} gt 1: if_13_then
        cmp ax, 1
        jg _if_13_then
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+42]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.13.1{r1}, column.1{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; sub t.13.1{r1}, c.1{r0}
        sub di, ax
        ; call t.12.1{r0} = abs@i16[t.13.1{r1}] -> i16
        call _abs@i16
        ; branch t.12.1{r0} gt 1: if_13_then
        cmp ax, 1
        jg _if_13_then
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, bombCount.4
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], bombCount.4{r0}
        mov [r12], ax
        ; move bombCount.4{r1}, bombCount.4{r0}
        mov di, ax
        jmp _for_12_continue
_if_13_then:
        ; 205:4 if setBomb@u8@u8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=205:15], type=u8, location=205:22], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=205:26], type=u8, location=205:36]])
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+40]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.15.1{r1}(u8), row.1{r0}(i16)
        mov dil, al
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+42]
        ; load column.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.16.1{r2}(u8), column.1{r0}(i16)
        mov sil, al
        ; call t.14.1{r0} = setBomb@u8@u8[t.15.1{r1}, t.16.1{r2}] -> bool
        call _setBomb@u8@u8
        ; branch t.14.1{r0} notequals 0: if_15_then
        cmp al, 0
        jne _if_15_then
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move bombCount.4{r1}, bombCount.2{r0}
        mov di, ax
        jmp _for_12_continue
_if_15_then:
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move bombCount.5{r1}, bombCount.2{r0}
        mov di, ax
        ; add bombCount.5{r1}, 1
        add di, 1
_for_12_continue:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+38]
        ; load bombs.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; sub bombs.5{r2}, 1
        sub si, 1
        ; move bombCount.2{r0}, bombCount.4{r1}
        mov ax, di
_for_12:
        ; branch bombs.2{r2} gt 0: for_12_body
        cmp si, 0
        jg _for_12_body
        ; 210:9 return bombCount
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; bool setBomb@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowTo.2
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
        ; move index.1{r1}, index.1{r0}
        mov di, ax
        ; 215:2 if [...] == 128
        ; cast t.14.1{r2}(i64), index.1{r1}(i16)
        movsx rsi, di
        ; addrof t.13.1{r3}, field
        lea rdx, [var_1]
        ; add t.13.2{r3}, t.14.1{r2}
        add rdx, rsi
        ; load t.12.1{r2}, [t.13.2{r3}]
        mov sil, [rdx]
        ; branch t.12.1{r2} equals 128: if_16_then
        cmp sil, 128
        je _if_16_then
        ; const t.15.1{r2}, 128
        mov sil, 128
        ; cast t.17.1{r3}(i64), index.1{r1}(i16)
        movsx rdx, di
        ; addrof t.16.1{r4}, field
        lea rcx, [var_1]
        ; add t.16.2{r4}, t.17.1{r3}
        add rcx, rdx
        ; store [t.16.2{r4}], t.15.1{r2}
        mov [rcx], sil
        ; move rowFrom.1{r2}, row{r8}
        mov sil, bl
        ; 221:2 if rowFrom > 0
        ; branch rowFrom.1{r2} lteq 0: if_17_end, if_17_then
        cmp sil, 0
        jbe _if_17_end
        jmp _if_17_then
_if_16_then:
        ; const {r0}, 0
        mov al, 0
        jmp _setBomb@u8@u8_ret
_if_17_then:
        ; sub rowFrom.3{r2}, 1
        sub sil, 1
        ; sub index.3{r1}, 40
        sub di, 40
_if_17_end:
        ; move rowTo.1{r3}, row{r8}
        mov dl, bl
        ; add rowTo.1{r3}, 1
        add dl, 1
        ; 226:2 if rowTo >= 20
        ; branch rowTo.1{r3} lt 20: if_18_end
        cmp dl, 20
        jb _if_18_end
        ; sub rowTo.3{r3}, 1
        sub dl, 1
_if_18_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move colFrom.1{r5}, column{r4}
        mov r8b, cl
        ; 231:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_19_end
        cmp r8b, 0
        jbe _if_19_end
        ; sub colFrom.3{r5}, 1
        sub r8b, 1
        ; sub index.6{r1}, 1
        sub di, 1
_if_19_end:
        ; move colTo.1{r6}, column{r4}
        mov r9b, cl
        ; add colTo.1{r6}, 1
        add r9b, 1
        ; 236:2 if colTo >= 40
        ; branch colTo.1{r6} lt 40: if_20_end
        cmp r9b, 40
        jb _if_20_end
        ; sub colTo.3{r6}, 1
        sub r9b, 1
_if_20_end:
        ; 241:2 for r <= rowTo
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row{r8}
        mov [r12], bl
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp _for_21
_for_21_body:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; load row{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; move c.1{r7}, colFrom.2{r5}
        mov r10b, r8b
        ; 242:3 for c <= colTo
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp _for_22
_for_22_body:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; load row{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; load rowTo.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch r.2{r2} notequals row{r8}: if_23_end
        cmp sil, bl
        jne _if_23_end
        ; branch c.2{r7} notequals column{r4}: if_23_end
        cmp r10b, cl
        jne _if_23_end
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        jmp _for_22_continue
_if_23_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r4}
        mov [r12], cl
        ; cast t.19.1{r4}(i64), index.9{r1}(i16)
        movsx rcx, di
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row{r8}
        mov [r12], bl
        ; addrof t.18.1{r8}, field
        lea rbx, [var_1]
        ; add t.18.2{r8}, t.19.1{r4}
        add rbx, rcx
        ; load cell.1{r4}, [t.18.2{r8}]
        mov cl, [rbx]
        ; 248:4 if cell & 128 == 0
        ; move t.20.1{r8}, cell.1{r4}
        mov bl, cl
        ; and t.20.1{r8}, 128
        and bl, 128
        ; branch t.20.1{r8} equals 0: if_25_then
        cmp bl, 0
        je _if_25_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp _for_22_continue
_if_25_then:
        ; and count.2{r4}, 15
        and cl, 15
        ; add count.3{r4}, 1
        add cl, 1
        ; cast t.22.1{r8}(i64), index.9{r1}(i16)
        movsx rbx, di
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        ; addrof t.21.1{r3}, field
        lea rdx, [var_1]
        ; add t.21.2{r3}, t.22.1{r8}
        add rdx, rbx
        ; store [t.21.2{r3}], count.3{r4}
        mov [rdx], cl
_for_22_continue:
        ; move c.5{r3}, c.2{r7}
        mov dl, r10b
        ; add c.5{r3}, 1
        add dl, 1
        ; add index.13{r1}, 1
        add di, 1
        ; move c.2{r7}, c.5{r3}
        mov r10b, dl
_for_22:
        ; branch c.2{r7} lteq colTo.2{r6}: for_22_body
        cmp r10b, r9b
        jbe _for_22_body
        ; cast t.26.1{r3}(i16), colTo.2{r6}(u8)
        movzx dx, r9b
        ; sub t.25.1{r1}, t.26.1{r3}
        sub di, dx
        ; cast t.27.1{r3}(i16), colFrom.2{r5}(u8)
        movzx dx, r8b
        ; add t.24.1{r1}, t.27.1{r3}
        add di, dx
        ; add t.23.1{r1}, 40
        add di, 40
        ; sub index.10{r1}, 1
        sub di, 1
        ; add r.4{r2}, 1
        add sil, 1
_for_21:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; load rowTo.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch r.2{r2} lteq rowTo.2{r3}: for_21_body
        cmp sil, dl
        jbe _for_21_body
        ; const {r0}, 1
        mov al, 1
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
        ;   rsp+36: var index.5
        ;   rsp+38: var c.2
        ;   rsp+39: var r.7
        ;   rsp+40: var index.7
        ;   rsp+42: var c.4
        ;   rsp+43: var c.7
        ;   rsp+44: var index.10
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
        ; move row{r1}, row{r8}
        mov dil, bl
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call index.1{r0} = rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; 262:2 if [...] & 15 != 0
        ; cast t.15.1{r4}(i64), index.1{r0}(i16)
        movsx rcx, ax
        ; addrof t.14.1{r5}, field
        lea r8, [var_1]
        ; add t.14.2{r5}, t.15.1{r4}
        add r8, rcx
        ; load t.13.1{r4}, [t.14.2{r5}]
        mov cl, [r8]
        ; and t.12.1{r4}, 15
        and cl, 15
        ; branch t.12.1{r4} notequals 0: maybeRevealAround@u8@u8_ret
        cmp cl, 0
        jne _maybeRevealAround@u8@u8_ret
        ; const t.17.1{r4}, 0
        mov rcx, 0
        ; addrof t.16.1{r5}, revealStackRows
        lea r8, [var_2]
        ; add t.16.2{r5}, t.17.1{r4}
        add r8, rcx
        ; store [t.16.2{r5}], row{r8}
        mov [r8], bl
        ; const t.19.1{r8}, 0
        mov rbx, 0
        ; addrof t.18.1{r4}, revealStackColumns
        lea rcx, [var_3]
        ; add t.18.2{r4}, t.19.1{r8}
        add rcx, rbx
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; store [t.18.2{r4}], column{r2}
        mov [rcx], sil
        ; addrof a.20.1{r8}, revealStackIndices
        lea rbx, [var_4]
        ; store [a.20.1{r8}], index.1{r0}
        mov [rbx], ax
        ; add t.21.1{r8}, 2
        add rbx, 2
        ; addrof a.23.1{r0}, revealStackIndexTop
        lea rax, [var_5]
        ; store [a.23.1{r0}], t.21.1{r8}
        mov [rax], rbx
        ; const t.24.1{r8}, 1
        mov bl, 1
        ; addrof a.25.1{r0}, revealStackSize
        lea rax, [var_6]
        ; store [a.25.1{r0}], t.24.1{r8}
        mov [rax], bl
        ; 271:2 while revealStackSize > 0
        jmp _while_27
_while_27_body:
        ; addrof a.28.1{r8}, revealStackSize
        lea rbx, [var_6]
        ; load t.29.1{r8}, [a.28.1{r8}]
        mov bl, [rbx]
        ; sub stackSize.1{r8}, 1
        sub bl, 1
        ; move t.30.1{r0}, stackSize.1{r8}
        mov al, bl
        ; addrof a.31.1{r4}, revealStackSize
        lea rcx, [var_6]
        ; store [a.31.1{r4}], t.30.1{r0}
        mov [rcx], al
        ; cast t.33.1{r0}(i64), stackSize.1{r8}(u8)
        movzx rax, bl
        ; addrof t.32.1{r4}, revealStackRows
        lea rcx, [var_2]
        ; add t.32.2{r4}, t.33.1{r0}
        add rcx, rax
        ; load row.1{r1}, [t.32.2{r4}]
        mov dil, [rcx]
        ; move t.35.1{r8}, t.35.1{r0}
        mov rbx, rax
        ; addrof t.34.1{r0}, revealStackColumns
        lea rax, [var_3]
        ; add t.34.2{r0}, t.35.1{r8}
        add rax, rbx
        ; load column.1{r2}, [t.34.2{r0}]
        mov sil, [rax]
        ; addrof a.36.1{r8}, revealStackIndexTop
        lea rbx, [var_5]
        ; load t.37.1{r8}, [a.36.1{r8}]
        mov rbx, [rbx]
        ; add stackIndex.1{r8}, -2
        add rbx, -2
        ; move t.38.1{r0}, stackIndex.1{r8}
        mov rax, rbx
        ; addrof a.39.1{r4}, revealStackIndexTop
        lea rcx, [var_5]
        ; store [a.39.1{r4}], t.38.1{r0}
        mov [rcx], rax
        ; load index.2{r3}, [stackIndex.1{r8}]
        mov dx, [rbx]
        ; call _ = revealNeighbors@u8@u8@i16[row.1{r1}, column.1{r2}, index.2{r3}] -> bool
        call _revealNeighbors@u8@u8@i16
        ; 280:3 if revealStackSize == 255
        ; addrof a.40.1{r8}, revealStackSize
        lea rbx, [var_6]
        ; load t.41.1{r8}, [a.40.1{r8}]
        mov bl, [rbx]
        ; branch t.41.1{r8} equals 255: while_27_break, while_27
        cmp bl, 255
        je _while_27_break
_while_27:
        ; addrof a.26.1{r8}, revealStackSize
        lea rbx, [var_6]
        ; load t.27.1{r8}, [a.26.1{r8}]
        mov bl, [rbx]
        ; branch t.27.1{r8} gt 0: while_27_body, while_27_break
        cmp bl, 0
        ja _while_27_body
_while_27_break:
        ; 284:2 if revealStackSize != 255
        ; addrof a.42.1{r8}, revealStackSize
        lea rbx, [var_6]
        ; load t.43.1{r8}, [a.42.1{r8}]
        mov bl, [rbx]
        ; branch t.43.1{r8} notequals 255: maybeRevealAround@u8@u8_ret
        cmp bl, 255
        jne _maybeRevealAround@u8@u8_ret
        ; const changed.1{r8}, 1
        mov bl, 1
        ; 289:2 while changed
        jmp _while_30
_while_30_body:
        ; const changed.3{r8}, 0
        mov bl, 0
        ; const index.3{r0}, 0
        mov ax, 0
        ; const r.1{r4}, 0
        mov cl, 0
        ; 293:3 for r < 20
        ; move r.2{r1}, r.1{r4}
        mov dil, cl
        ; move index.4{r4}, index.4{r0}
        mov cx, ax
        jmp _for_31
_for_31_body:
        ; move index.4{r0}, index.4{r4}
        mov ax, cx
        ; const c.1{r4}, 0
        mov cl, 0
        ; 294:4 for c < 40
        ; move index.5{r3}, index.4{r0}
        mov dx, ax
        ; move c.2{r2}, c.1{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_32
_for_32_body:
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.45.1{r0}(i64), index.5{r3}(i16)
        movsx rax, dx
        ; addrof t.44.1{r4}, field
        lea rcx, [var_1]
        ; add t.44.2{r4}, t.45.1{r0}
        add rcx, rax
        ; load cell.1{r0}, [t.44.2{r4}]
        mov al, [rcx]
        ; 296:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.46.1{r4}, cell.1{r0}
        mov cl, al
        ; and t.46.1{r4}, 32
        and cl, 32
        ; branch t.46.1{r4} notequals 0: or_34
        cmp cl, 0
        jne _or_34
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, index.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.5{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        jmp _for_32_continue
_or_34:
        ; and t.47.1{r0}, 128
        and al, 128
        ; branch t.47.1{r0} equals 0: if_33_end
        cmp al, 0
        je _if_33_end
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, index.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.5{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_32_continue
_if_33_end:
        ; 299:5 if [...] & 15 != 0
        ; cast t.51.1{r0}(i64), index.5{r3}(i16)
        movsx rax, dx
        ; addrof t.50.1{r4}, field
        lea rcx, [var_1]
        ; add t.50.2{r4}, t.51.1{r0}
        add rcx, rax
        ; load t.49.1{r0}, [t.50.2{r4}]
        mov al, [rcx]
        ; and t.48.1{r0}, 15
        and al, 15
        ; branch t.48.1{r0} equals 0: if_35_end
        cmp al, 0
        je _if_35_end
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, index.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.5{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        jmp _for_32_continue
_if_35_end:
        ; 303:5 if revealNeighbors@u8@u8@i16([ExprVarAccess[varName=r, index=6, scope=function, type=u8, varIsArray=false, location=303:24], ExprVarAccess[varName=c, index=7, scope=function, type=u8, varIsArray=false, location=303:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=303:30]])
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, index.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.5{r3}
        mov [r12], dx
        ; call t.52.1{r0} = revealNeighbors@u8@u8@i16[r.2{r1}, c.2{r2}, index.5{r3}] -> bool
        call _revealNeighbors@u8@u8@i16
        ; branch t.52.1{r0} equals 0: for_32_continue
        cmp al, 0
        je _for_32_continue
        ; const changed.9{r8}, 1
        mov bl, 1
_for_32_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.6{r0}, c.2{r2}
        mov al, sil
        ; add c.6{r0}, 1
        add al, 1
        ; addrof memVarAddr{r9}, index.5
        lea r12, [rsp+36]
        ; load index.5{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; move index.9{r4}, index.5{r3}
        mov cx, dx
        ; add index.9{r4}, 1
        add cx, 1
        ; move index.5{r3}, index.9{r4}
        mov dx, cx
        ; move c.2{r2}, c.6{r0}
        mov sil, al
_for_32:
        ; branch c.2{r2} lt 40: for_32_body
        cmp sil, 40
        jb _for_32_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move r.6{r0}, r.2{r1}
        mov al, dil
        ; add r.6{r0}, 1
        add al, 1
        ; move index.4{r4}, index.5{r3}
        mov cx, dx
        ; move r.2{r1}, r.6{r0}
        mov dil, al
_for_31:
        ; branch r.2{r1} lt 20: for_31_body
        cmp dil, 20
        jb _for_31_body
        ; branch changed.4{r8} equals 0: maybeRevealAround@u8@u8_ret
        cmp bl, 0
        je _maybeRevealAround@u8@u8_ret
        ; const r.4{r0}, 20
        mov al, 20
        ; 314:3 while true
        ; move r.5{r1}, r.5{r0}
        mov dil, al
        ; move index.6{r0}, index.6{r4}
        mov ax, cx
        jmp _while_38
_if_39_end:
        ; move index.6{r4}, index.6{r0}
        mov cx, ax
        ; sub r.7{r1}, 1
        sub dil, 1
        ; const c.3{r0}, 40
        mov al, 40
        ; 321:4 while true
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r1}
        mov [r12], dil
        ; move c.4{r1}, c.4{r0}
        mov dil, al
        ; move index.7{r0}, index.7{r4}
        mov ax, cx
        jmp _while_40
_if_41_end:
        ; move index.7{r4}, index.7{r0}
        mov cx, ax
        ; move c.4{r0}, c.4{r1}
        mov al, dil
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; load r.7{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move c.7{r2}, c.4{r0}
        mov sil, al
        ; sub c.7{r2}, 1
        sub sil, 1
        ; move index.10{r3}, index.7{r4}
        mov dx, cx
        ; sub index.10{r3}, 1
        sub dx, 1
        ; cast t.54.1{r0}(i64), index.10{r3}(i16)
        movsx rax, dx
        ; addrof t.53.1{r4}, field
        lea rcx, [var_1]
        ; add t.53.2{r4}, t.54.1{r0}
        add rcx, rax
        ; load cell.2{r0}, [t.53.2{r4}]
        mov al, [rcx]
        ; 328:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.55.1{r4}, cell.2{r0}
        mov cl, al
        ; and t.55.1{r4}, 32
        and cl, 32
        ; branch t.55.1{r4} notequals 0: or_43
        cmp cl, 0
        jne _or_43
        ; move index.7{r4}, index.10{r3}
        mov cx, dx
        ; move c.4{r0}, c.7{r2}
        mov al, sil
        ; move c.4{r1}, c.4{r0}
        mov dil, al
        ; move index.7{r0}, index.7{r4}
        mov ax, cx
        jmp _while_40
_or_43:
        ; and t.56.1{r0}, 128
        and al, 128
        ; branch t.56.1{r0} equals 0: if_42_end
        cmp al, 0
        je _if_42_end
        ; move index.7{r4}, index.10{r3}
        mov cx, dx
        ; move c.4{r0}, c.7{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r1}
        mov [r12], dil
        ; move c.4{r1}, c.4{r0}
        mov dil, al
        ; move index.7{r0}, index.7{r4}
        mov ax, cx
        jmp _while_40
_if_42_end:
        ; 331:5 if [...] & 15 != 0
        ; cast t.60.1{r0}(i64), index.10{r3}(i16)
        movsx rax, dx
        ; addrof t.59.1{r4}, field
        lea rcx, [var_1]
        ; add t.59.2{r4}, t.60.1{r0}
        add rcx, rax
        ; load t.58.1{r0}, [t.59.2{r4}]
        mov al, [rcx]
        ; and t.57.1{r0}, 15
        and al, 15
        ; branch t.57.1{r0} equals 0: if_44_end
        cmp al, 0
        je _if_44_end
        ; move index.7{r4}, index.10{r3}
        mov cx, dx
        ; addrof memVarAddr{r9}, index.7
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], index.7{r4}
        mov [r12], cx
        ; move c.4{r0}, c.7{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, c.4
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c.4{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r1}
        mov [r12], dil
        ; move c.4{r1}, c.4{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, index.7
        lea r12, [rsp+40]
        ; move index.7{r0}, index.7{r3}
        mov ax, dx
        jmp _while_40
_if_44_end:
        ; 335:5 if revealNeighbors@u8@u8@i16([ExprVarAccess[varName=r, index=9, scope=function, type=u8, varIsArray=false, location=335:24], ExprVarAccess[varName=c, index=10, scope=function, type=u8, varIsArray=false, location=335:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=335:30]])
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, c.7
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], c.7{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, index.10
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], index.10{r3}
        mov [r12], dx
        ; call t.61.1{r0} = revealNeighbors@u8@u8@i16[r.7{r1}, c.7{r2}, index.10{r3}] -> bool
        call _revealNeighbors@u8@u8@i16
        ; branch t.61.1{r0} notequals 0: if_45_then
        cmp al, 0
        jne _if_45_then
        ; load index.10{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; move index.7{r0}, index.10{r3}
        mov ax, dx
        ; addrof memVarAddr{r9}, c.7
        lea r12, [rsp+43]
        ; load c.7{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.4{r1}, c.7{r2}
        mov dil, sil
        jmp _while_40
_if_45_then:
        ; addrof memVarAddr{r9}, c.7
        lea r12, [rsp+43]
        ; load c.7{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, index.10
        lea r12, [rsp+44]
        ; load index.10{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; const changed.10{r1}, 1
        mov dil, 1
        ; move index.7{r0}, index.10{r3}
        mov ax, dx
        ; move changed.7{r8}, changed.10{r1}
        mov bl, dil
        ; move c.4{r1}, c.7{r2}
        mov dil, sil
_while_40:
        ; branch c.4{r1} notequals 0: if_41_end
        cmp dil, 0
        jne _if_41_end
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; load r.7{r1}, [memVarAddr{r9}]
        mov dil, [r12]
_while_38:
        ; branch r.5{r1} notequals 0: if_39_end, while_30
        cmp dil, 0
        jne _if_39_end
_while_30:
        ; branch changed.2{r8} notequals 0: while_30_body, maybeRevealAround@u8@u8_ret
        cmp bl, 0
        jne _while_30_body
_maybeRevealAround@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void pushReveal@u8@u8@i16
        ;   rsp+0: arg row
        ;   rsp+1: arg column
        ;   rsp+2: arg index
_pushReveal@u8@u8@i16:
        sub rsp, 8
        ; addrof a.4.1{r0}, revealStackSize
        lea rax, [var_6]
        ; load stackSize.1{r0}, [a.4.1{r0}]
        mov al, [rax]
        ; 345:2 if stackSize >= 16
        ; branch stackSize.1{r0} gteq 16: if_46_then
        cmp al, 16
        jae _if_46_then
        ; cast t.8.1{r4}(i64), stackSize.1{r0}(u8)
        movzx rcx, al
        ; addrof t.7.1{r5}, revealStackRows
        lea r8, [var_2]
        ; add t.7.2{r5}, t.8.1{r4}
        add r8, rcx
        ; store [t.7.2{r5}], row{r1}
        mov [r8], dil
        ; move t.10.1{r1}, t.10.1{r4}
        mov rdi, rcx
        ; addrof t.9.1{r4}, revealStackColumns
        lea rcx, [var_3]
        ; add t.9.2{r4}, t.10.1{r1}
        add rcx, rdi
        ; store [t.9.2{r4}], column{r2}
        mov [rcx], sil
        ; addrof a.11.1{r1}, revealStackIndexTop
        lea rdi, [var_5]
        ; load t.12.1{r1}, [a.11.1{r1}]
        mov rdi, [rdi]
        ; store [t.12.1{r1}], index{r3}
        mov [rdi], dx
        ; addrof a.14.1{r1}, revealStackIndexTop
        lea rdi, [var_5]
        ; load t.15.1{r1}, [a.14.1{r1}]
        mov rdi, [rdi]
        ; add t.13.1{r1}, 2
        add rdi, 2
        ; addrof a.16.1{r2}, revealStackIndexTop
        lea rsi, [var_5]
        ; store [a.16.1{r2}], t.13.1{r1}
        mov [rsi], rdi
        ; add t.17.1{r0}, 1
        add al, 1
        ; addrof a.18.1{r1}, revealStackSize
        lea rdi, [var_6]
        ; store [a.18.1{r1}], t.17.1{r0}
        mov [rdi], al
        jmp _pushReveal@u8@u8@i16_ret
_if_46_then:
        ; const t.5.1{r0}, 255
        mov al, 255
        ; addrof a.6.1{r1}, revealStackSize
        lea rdi, [var_6]
        ; store [a.6.1{r1}], t.5.1{r0}
        mov [rdi], al
        ; 347:3 return
_pushReveal@u8@u8@i16_ret:
        add rsp, 8
        ret

        ; bool revealNeighbors@u8@u8@i16
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: arg index
        ;   rsp+36: var rowTo.2
        ;   rsp+37: var colFrom.2
        ;   rsp+38: var colTo.2
        ;   rsp+40: var index.8
        ;   rsp+42: var c.2
        ;   rsp+43: var changed.4
        ;   rsp+44: var cell.2
        ;   rsp+45: var changed.5
_revealNeighbors@u8@u8@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move rowFrom.1{r8}, row{r1}
        mov bl, dil
        ; 359:2 if rowFrom > 0
        ; branch rowFrom.1{r8} gt 0: if_47_then
        cmp bl, 0
        ja _if_47_then
        ; move index.1{r0}, index{r3}
        mov ax, dx
        jmp _if_47_end
_if_47_then:
        ; sub rowFrom.3{r8}, 1
        sub bl, 1
        ; move index.2{r0}, index{r3}
        mov ax, dx
        ; sub index.2{r0}, 40
        sub ax, 40
_if_47_end:
        ; move rowTo.1{r4}, row{r1}
        mov cl, dil
        ; add rowTo.1{r4}, 1
        add cl, 1
        ; 364:2 if rowTo >= 20
        ; branch rowTo.1{r4} gteq 20: if_48_then
        cmp cl, 20
        jae _if_48_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], rowTo.2{r4}
        mov [r12], cl
        jmp _if_48_end
_if_48_then:
        ; sub rowTo.3{r4}, 1
        sub cl, 1
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], rowTo.2{r4}
        mov [r12], cl
_if_48_end:
        ; move colFrom.1{r4}, column{r2}
        mov cl, sil
        ; 369:2 if colFrom > 0
        ; branch colFrom.1{r4} lteq 0: if_49_end
        cmp cl, 0
        jbe _if_49_end
        ; sub colFrom.3{r4}, 1
        sub cl, 1
        ; sub index.5{r0}, 1
        sub ax, 1
_if_49_end:
        ; move colTo.1{r5}, column{r2}
        mov r8b, sil
        ; add colTo.1{r5}, 1
        add r8b, 1
        ; 374:2 if colTo >= 40
        ; branch colTo.1{r5} gteq 40: if_50_then
        cmp r8b, 40
        jae _if_50_then
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], colTo.2{r5}
        mov [r12], r8b
        jmp _if_50_end
_if_50_then:
        ; sub colTo.3{r5}, 1
        sub r8b, 1
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], colTo.2{r5}
        mov [r12], r8b
_if_50_end:
        ; const changed.1{r5}, 0
        mov r8b, 0
        ; 378:2 for r <= rowTo
        ; move colFrom.2{r3}, colFrom.2{r4}
        mov dl, cl
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+38]
        ; load colTo.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move index.7{r4}, index.7{r0}
        mov cx, ax
        ; move changed.2{r0}, changed.2{r5}
        mov al, r8b
        jmp _for_51
_for_51_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], colTo.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], rowTo.2{r1}
        mov [r12], dil
        ; move changed.2{r5}, changed.2{r0}
        mov r8b, al
        ; move index.7{r0}, index.7{r4}
        mov ax, cx
        ; move colFrom.2{r4}, colFrom.2{r3}
        mov cl, dl
        ; move c.1{r6}, colFrom.2{r4}
        mov r9b, cl
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], colFrom.2{r4}
        mov [r12], cl
        ; 379:3 for c <= colTo
        ; move index.8{r3}, index.7{r0}
        mov dx, ax
        ; move changed.3{r0}, changed.2{r5}
        mov al, r8b
        ; move changed.3{r1}, changed.3{r0}
        mov dil, al
        ; move c.2{r0}, c.2{r4}
        mov al, cl
        ; move index.8{r4}, index.8{r3}
        mov cx, dx
        ; move c.2{r3}, c.2{r0}
        mov dl, al
        jmp _for_52
_for_52_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], colTo.2{r2}
        mov [r12], sil
        ; move changed.3{r0}, changed.3{r1}
        mov al, dil
        ; move c.2{r1}, c.2{r3}
        mov dil, dl
        ; move index.8{r3}, index.8{r4}
        mov dx, cx
        ; move c.2{r4}, c.2{r1}
        mov cl, dil
        ; cast t.12.1{r5}(i64), index.8{r3}(i16)
        movsx r8, dx
        ; addrof t.11.1{r6}, field
        lea r9, [var_1]
        ; add t.11.2{r6}, t.12.1{r5}
        add r9, r8
        ; load cell.1{r5}, [t.11.2{r6}]
        mov r8b, [r9]
        ; 381:4 if cell & 32 != 0
        ; move t.13.1{r6}, cell.1{r5}
        mov r9b, r8b
        ; and t.13.1{r6}, 32
        and r9b, 32
        ; branch t.13.1{r6} equals 0: if_53_end
        cmp r9b, 0
        je _if_53_end
        ; addrof memVarAddr{r9}, changed.4
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], changed.4{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c.2{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, index.8
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], index.8{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, changed.4
        lea r12, [rsp+43]
        ; move changed.4{r1}, changed.4{r0}
        mov dil, al
        jmp _for_52_continue
_if_53_end:
        ; move cell.2{r1}, cell.1{r5}
        mov dil, r8b
        ; or cell.2{r1}, 32
        or dil, 32
        ; cast t.15.1{r0}(i64), index.8{r3}(i16)
        movsx rax, dx
        ; addrof memVarAddr{r9}, index.8
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], index.8{r3}
        mov [r12], dx
        ; addrof t.14.1{r5}, field
        lea r8, [var_1]
        ; add t.14.2{r5}, t.15.1{r0}
        add r8, rax
        ; store [t.14.2{r5}], cell.2{r1}
        mov [r8], dil
        ; addrof memVarAddr{r9}, cell.2
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], cell.2{r1}
        mov [r12], dil
        ; move r.2{r2}, r.2{r8}
        mov sil, bl
        ; move c.2{r3}, c.2{r4}
        mov dl, cl
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c.2{r4}
        mov [r12], cl
        ; call printCellAt@u8@u8@u8[cell.2{r1}, r.2{r2}, c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; const changed.5{r0}, 1
        mov al, 1
        ; 389:4 if cell & 143 == 0 && revealStackSize != 255
        ; addrof memVarAddr{r9}, cell.2
        lea r12, [rsp+44]
        ; load cell.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move t.16.1{r4}, cell.2{r1}
        mov cl, dil
        ; and t.16.1{r4}, 143
        and cl, 143
        ; branch t.16.1{r4} equals 0: and_55
        cmp cl, 0
        je _and_55
        ; move changed.4{r1}, changed.4{r0}
        mov dil, al
        jmp _for_52_continue
_and_55:
        ; addrof a.17.1{r4}, revealStackSize
        lea rcx, [var_6]
        ; load t.18.1{r4}, [a.17.1{r4}]
        mov cl, [rcx]
        ; branch t.18.1{r4} notequals 255: if_54_then
        cmp cl, 255
        jne _if_54_then
        ; addrof memVarAddr{r9}, changed.4
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], changed.4{r0}
        mov [r12], al
        ; move changed.4{r1}, changed.4{r0}
        mov dil, al
        jmp _for_52_continue
_if_54_then:
        ; addrof memVarAddr{r9}, changed.5
        lea r12, [rsp+45]
        ; store [memVarAddr{r9}], changed.5{r0}
        mov [r12], al
        ; move r.2{r1}, r.2{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+42]
        ; load c.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move c.2{r2}, c.2{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, index.8
        lea r12, [rsp+40]
        ; load index.8{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; call pushReveal@u8@u8@i16[r.2{r1}, c.2{r2}, index.8{r3}]
        call _pushReveal@u8@u8@i16
        ; addrof memVarAddr{r9}, changed.5
        lea r12, [rsp+45]
        ; load changed.5{r1}, [memVarAddr{r9}]
        mov dil, [r12]
_for_52_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+42]
        ; load c.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move c.4{r2}, c.2{r3}
        mov sil, dl
        ; add c.4{r2}, 1
        add sil, 1
        ; addrof memVarAddr{r9}, index.8
        lea r12, [rsp+40]
        ; load index.8{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; move index.11{r3}, index.8{r4}
        mov dx, cx
        ; add index.11{r3}, 1
        add dx, 1
        ; move index.8{r4}, index.11{r3}
        mov cx, dx
        ; move c.2{r3}, c.4{r2}
        mov dl, sil
_for_52:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+38]
        ; load colTo.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch c.2{r3} lteq colTo.2{r2}: for_52_body
        cmp dl, sil
        jbe _for_52_body
        ; cast t.22.1{r3}(i16), colTo.2{r2}(u8)
        movzx dx, sil
        ; sub t.21.1{r4}, t.22.1{r3}
        sub cx, dx
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+37]
        ; load colFrom.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; cast t.23.1{r5}(i16), colFrom.2{r3}(u8)
        movzx r8w, dl
        ; add t.20.1{r4}, t.23.1{r5}
        add cx, r8w
        ; add t.19.1{r4}, 40
        add cx, 40
        ; sub index.9{r4}, 1
        sub cx, 1
        ; move r.4{r5}, r.2{r8}
        mov r8b, bl
        ; add r.4{r5}, 1
        add r8b, 1
        ; move changed.2{r0}, changed.3{r1}
        mov al, dil
        ; move r.2{r8}, r.4{r5}
        mov bl, r8b
_for_51:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+36]
        ; load rowTo.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch r.2{r8} lteq rowTo.2{r1}: for_51_body
        cmp bl, dil
        jbe _for_51_body
        ; 395:9 return changed
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var row.2
        ;   rsp+34: var bombsLeft.2
        ;   rsp+36: var chr.1
        ;   rsp+38: var bombsLeft.3
        ;   rsp+40: var bombsLeft.6
_main:
        sub rsp, 24
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
        ; const t.10.1{r8}, 0
        mov rbx, 0
        ; addrof a.11.1{r0}, revealStackIndexTop
        lea rax, [var_5]
        ; store [a.11.1{r0}], t.10.1{r8}
        mov [rax], rbx
        ; const t.12.1{r8}, 0
        mov bl, 0
        ; addrof a.13.1{r0}, revealStackSize
        lea rax, [var_6]
        ; store [a.13.1{r0}], t.12.1{r8}
        mov [rax], bl
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
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
        ; const col.1{r8}, 20
        mov bl, 20
        ; const row.1{r0}, 10
        mov al, 10
        ; const bombsLeft.1{r4}, -1
        mov cx, -1
        ; 407:2 while true
        ; move row.2{r1}, row.1{r0}
        mov dil, al
        ; move bombsLeft.2{r0}, bombsLeft.1{r4}
        mov ax, cx
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        jmp _while_56
_if_57_end:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; const t.15.1{r3}, 1
        mov dl, 1
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.15.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; const t.16.1{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.16.1{r3}]
        call _showCursor@u8@u8@bool
        ; 416:3 if chr == 27
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; load chr.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 13: if_59_then
        cmp ax, 13
        je _if_59_then
        ; branch chr.1{r0} notequals -8120: if_63_else, if_63_then
        cmp ax, -8120
        jne _if_63_else
        jmp _if_63_then
_if_59_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; branch bombsLeft.2{r3} gteq 0: main.no_critical_edge_42, if_60_then
        cmp dx, 0
        jge _main.no_critical_edge_42
        jmp _if_60_then
_if_63_else:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; branch chr.1{r0} notequals -8112: if_65_else, if_65_then
        cmp ax, -8112
        jne _if_65_else
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        jmp _if_65_then
_if_63_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch row.2{r1} lteq 0: main.no_critical_edge_41, if_64_then
        cmp dil, 0
        jbe _main.no_critical_edge_41
        jmp _if_64_then
_main.no_critical_edge_42:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move bombsLeft.3{r0}, bombsLeft.2{r3}
        mov ax, dx
        ; addrof memVarAddr{r9}, bombsLeft.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombsLeft.3{r0}
        mov [r12], ax
        jmp _if_60_end
_if_60_then:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call bombsLeft.4{r0} = initField@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _initField@u8@u8
        ; addrof memVarAddr{r9}, bombsLeft.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombsLeft.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_60_end
_if_65_else:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_67_else, if_67_then
        cmp ax, -8117
        jne _if_67_else
        jmp _if_67_then
_if_65_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch row.2{r1} gteq 19: main.no_critical_edge_40, if_66_then
        cmp dil, 19
        jae _main.no_critical_edge_40
        jmp _if_66_then
_main.no_critical_edge_41:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r3}
        mov [r12], dx
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        jmp _while_56
_if_64_then:
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        ; move row.4{r3}, row.2{r1}
        mov dl, dil
        ; sub row.4{r3}, 1
        sub dl, 1
        ; move row.2{r1}, row.4{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        jmp _while_56
_if_60_end:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call index.1{r0} = rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.18.1{r3}(i64), index.1{r0}(i16)
        movsx rdx, ax
        ; addrof t.17.1{r4}, field
        lea rcx, [var_1]
        ; add t.17.2{r4}, t.18.1{r3}
        add rcx, rdx
        ; load cell.1{r3}, [t.17.2{r4}]
        mov dl, [rcx]
        ; 426:4 if cell & 32 == 0
        ; move t.19.1{r4}, cell.1{r3}
        mov cl, dl
        ; and t.19.1{r4}, 32
        and cl, 32
        ; branch t.19.1{r4} notequals 0: main.no_critical_edge_43, if_61_then
        cmp cl, 0
        jne _main.no_critical_edge_43
        jmp _if_61_then
_if_67_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_69_else, if_69_then
        cmp ax, -8115
        jne _if_69_else
        jmp _if_69_then
_if_67_then:
        ; branch col.2{r8} lteq 0: main.no_critical_edge_39, if_68_then
        cmp bl, 0
        jbe _main.no_critical_edge_39
        jmp _if_68_then
_main.no_critical_edge_40:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_if_66_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; move row.5{r0}, row.2{r1}
        mov al, dil
        ; add row.5{r0}, 1
        add al, 1
        ; move row.2{r1}, row.5{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_main.no_critical_edge_43:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp _if_61_end
_if_61_then:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move t.20.1{r4}, cell.1{r3}
        mov cl, dl
        ; or t.20.1{r4}, 32
        or cl, 32
        ; cast t.22.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.21.1{r5}, field
        lea r8, [var_1]
        ; add t.21.2{r5}, t.22.1{r0}
        add r8, rax
        ; store [t.21.2{r5}], t.20.1{r4}
        mov [r8], cl
        jmp _if_61_end
_if_69_else:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch chr.1{r0} notequals 32: main.no_critical_edge_34, if_71_then
        cmp ax, 32
        jne _main.no_critical_edge_34
        jmp _if_71_then
_if_69_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch col.2{r8} gteq 39: main.no_critical_edge_38, if_70_then
        cmp bl, 39
        jae _main.no_critical_edge_38
        jmp _if_70_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_if_68_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; sub col.5{r8}, 1
        sub bl, 1
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_if_61_end:
        ; 429:4 if cell & 128 != 0
        ; move t.23.1{r0}, cell.1{r3}
        mov al, dl
        ; and t.23.1{r0}, 128
        and al, 128
        ; branch t.23.1{r0} equals 0: if_62_end, if_62_then
        cmp al, 0
        je _if_62_end
        jmp _if_62_then
_main.no_critical_edge_34:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_if_71_then:
        ; branch bombsLeft.2{r3} lt 0: main.no_critical_edge_35, if_72_then
        cmp dx, 0
        jl _main.no_critical_edge_35
        jmp _if_72_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_if_70_then:
        ; add col.6{r8}, 1
        add bl, 1
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        jmp _while_56
_if_62_end:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call maybeRevealAround@u8@u8[row.2{r1}, col.2{r2}]
        call _maybeRevealAround@u8@u8
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, bombsLeft.3
        lea r12, [rsp+38]
        ; load bombsLeft.3{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        jmp _while_56
_main.no_critical_edge_35:
        ; move bombsLeft.2{r0}, bombsLeft.2{r3}
        mov ax, dx
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        jmp _while_56
_if_72_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call index.2{r0} = rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.26.1{r4}(i64), index.2{r0}(i16)
        movsx rcx, ax
        ; addrof t.25.1{r5}, field
        lea r8, [var_1]
        ; add t.25.2{r5}, t.26.1{r4}
        add r8, rcx
        ; load cell.3{r4}, [t.25.2{r5}]
        mov cl, [r8]
        ; 465:5 if cell & 32 == 0
        ; move t.27.1{r5}, cell.3{r4}
        mov r8b, cl
        ; and t.27.1{r5}, 32
        and r8b, 32
        ; branch t.27.1{r5} equals 0: if_73_then
        cmp r8b, 0
        je _if_73_then
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r5}, [memVarAddr{r9}]
        mov r8w, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; move bombsLeft.2{r0}, bombsLeft.2{r5}
        mov ax, r8w
        jmp _while_56
_if_73_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r5}, [memVarAddr{r9}]
        mov r8w, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move cell.4{r1}, cell.3{r4}
        mov dil, cl
        ; xor cell.4{r1}, 64
        xor dil, 64
        ; 467:6 if cell & 128 != 0
        ; move t.28.1{r4}, cell.4{r1}
        mov cl, dil
        ; and t.28.1{r4}, 128
        and cl, 128
        ; branch t.28.1{r4} notequals 0: if_74_then
        cmp cl, 0
        jne _if_74_then
        ; move bombsLeft.6{r4}, bombsLeft.2{r5}
        mov cx, r8w
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], bombsLeft.6{r4}
        mov [r12], cx
        jmp _if_74_end
_if_74_then:
        ; 468:7 if cell & 64 != 0
        ; move t.29.1{r4}, cell.4{r1}
        mov cl, dil
        ; and t.29.1{r4}, 64
        and cl, 64
        ; branch t.29.1{r4} notequals 0: if_75_then
        cmp cl, 0
        jne _if_75_then
        ; move bombsLeft.7{r4}, bombsLeft.2{r5}
        mov cx, r8w
        ; add bombsLeft.7{r4}, 1
        add cx, 1
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], bombsLeft.6{r4}
        mov [r12], cx
        jmp _if_74_end
_if_75_then:
        ; move bombsLeft.8{r4}, bombsLeft.2{r5}
        mov cx, r8w
        ; sub bombsLeft.8{r4}, 1
        sub cx, 1
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], bombsLeft.6{r4}
        mov [r12], cx
_if_74_end:
        ; cast t.31.1{r0}(i64), index.2{r0}(i16)
        movsx rax, ax
        ; addrof t.30.1{r4}, field
        lea rcx, [var_1]
        ; add t.30.2{r4}, t.31.1{r0}
        add rcx, rax
        ; store [t.30.2{r4}], cell.4{r1}
        mov [rcx], dil
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; move col.2{r3}, col.2{r8}
        mov dl, bl
        ; call printCellAt@u8@u8@u8[cell.4{r1}, row.2{r2}, col.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; load bombsLeft.6{r0}, [memVarAddr{r9}]
        mov ax, [r12]
_while_56:
        ; branch bombsLeft.2{r0} notequals 0: if_57_end
        cmp ax, 0
        jne _if_57_end
        ; const t.14.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.14.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_62_then:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], dil
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call printCellAt@u8@u8[row.2{r1}, col.2{r2}]
        call _printCellAt@u8@u8
        ; const t.24.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.24.1{r1}]
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
        ; variable 1: field[] (u8*/800)
        var_1 rb 800
        ; variable 2: revealStackRows[] (u8*/16)
        var_2 rb 16
        ; variable 3: revealStackColumns[] (u8*/16)
        var_3 rb 16
        ; variable 4: revealStackIndices[] (i16*/32)
        var_4 rb 32
        ; variable 5: revealStackIndexTop (i16*/8)
        var_5 rb 8
        ; variable 6: revealStackSize (u8/1)
        var_6 rb 1

segment readable
        string_0 db ' |', 0x00
        string_1 db ' You', 0x27, 've cleaned the field!', 0x00
        string_2 db 'boom! you', 0x27, 've lost', 0x00

