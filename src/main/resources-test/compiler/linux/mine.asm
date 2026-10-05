format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; i16 _getChar
_getChar:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        jmp while_1
if_2_end:
        ; call c.2{r0} = _____getChar[] -> i16
        call _____getChar
        ; move c.2{r8}, c.2{r0}
        mov bx, ax
        ; 37:3 if c == 27
        ; branch c.2{r8} equals 27: if_3_then
        cmp bx, 27
        je if_3_then
        ; branch c.2{r8} notequals 91: while_1
        cmp bx, 91
        jne while_1
        ; call c.3{r0} = _____getChar[] -> i16
        call _____getChar
        ; 45:3 if c == 65
        ; branch c.3{r0} equals 65: if_5_then
        cmp ax, 65
        je if_5_then
        ; branch c.3{r0} equals 66: if_6_then
        cmp ax, 66
        je if_6_then
        ; branch c.3{r0} equals 67: if_7_then
        cmp ax, 67
        je if_7_then
        ; branch c.3{r0} equals 68: if_8_then, while_1
        cmp ax, 68
        je if_8_then
while_1:
        ; call c.1{r0} = _____getChar[] -> i16
        call _____getChar
        ; 32:3 if c != 27
        ; branch c.1{r0} equals 27: if_2_end
        cmp ax, 27
        je if_2_end
        ; 33:11 return c
        jmp _getChar_ret
if_3_then:
        ; 38:11 return c
        ; move c.2{r0}, c.2{r8}
        mov ax, bx
        jmp _getChar_ret
if_5_then:
        ; const {r0}, -8120
        mov ax, -8120
        jmp _getChar_ret
if_6_then:
        ; const {r0}, -8112
        mov ax, -8112
        jmp _getChar_ret
if_7_then:
        ; const {r0}, -8115
        mov ax, -8115
        jmp _getChar_ret
if_8_then:
        ; const {r0}, -8117
        mov ax, -8117
_getChar_ret:
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void _setCursor@i16@i16
        ;   rsp+32: arg row
        ;   rsp+34: arg column
_setCursor@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; move column{r9}, column{r2}
        mov r12w, si
        ; const t.2.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; move row{r1}, row{r8}
        mov di, bx
        ; call _printUint@i16[row{r1}]
        call _printUint@i16
        ; const arg.2.0{r1}, 59
        mov dil, 59
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; move column{r1}, column{r9}
        mov di, r12w
        ; call _printUint@i16[column{r1}]
        call _printUint@i16
        ; const arg.4.0{r1}, 72
        mov dil, 72
        ; call _printChar@u8[arg.4.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _printString@@u8
        ;   rsp+24: arg str
_printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; call length.1{r0} = _strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length.1{r2}, length.1{r0}
        mov rsi, rax
        ; call _printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void _printChar@u8
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
        ; call _printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _printUint@i16
        ;   rsp+0: arg number
_printUint@i16:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call _printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 8
        ret

        ; void _printUint@i64
        ;   rsp+0: arg number
        ;   rsp+20: var buffer
_printUint@i64:
        sub rsp, 40
        ; const pos.1{r0}, 20
        mov al, 20
        ; 33:2 while true
        jmp while_9
_printUint@i64.no_critical_edge_4:
        ; move pos.2{r0}, pos.3{r2}
        mov al, sil
while_9:
        ; move pos.3{r2}, pos.2{r0}
        mov sil, al
        ; sub pos.3{r2}, 1
        sub sil, 1
        ; move remainder.1{r5}, number.1{r1}
        mov r8, rdi
        ; move remainder.1{r0}, remainder.1{r5}
        mov rax, r8
        ; mod remainder.1{r3}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r5}, remainder.1{r3}
        mov r8, rdx
        ; move number.2{r0}, number.2{r1}
        mov rax, rdi
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r1}, number.2{r0}
        mov rdi, rax
        ; cast t.5.1{r0}(u8), remainder.1{r5}(i64)
        mov al, r8b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r2}(u8)
        movzx rdx, sil
        ; addrof t.6.1{r4}, buffer
        lea rcx, [rsp+20]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; store [t.6.2{r4}], digit.1{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number.2{r1} notequals 0: _printUint@i64.no_critical_edge_4
        cmp rdi, 0
        jne _printUint@i64.no_critical_edge_4
        ; move t.8.2{r1}, t.8.2{r4}
        mov rdi, rcx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; sub t.10.1{r0}, pos.3{r2}
        sub al, sil
        ; move t.10.1{r2}, t.10.1{r0}
        mov sil, al
        ; call _printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 40
        ret

        ; i64 _strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r0}, 0
        mov rax, 0
        ; 73:2 for *str != 0
        jmp for_11
for_11_body:
        ; add length.3{r0}, 1
        add rax, 1
        ; add str.2{r1}, 1
        add rdi, 1
for_11:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_11_body
        cmp sil, 0
        jne for_11_body
        ; 76:9 return length
        add rsp, 8
        ret

        ; void _printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call _printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void _initRandom@i32
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

        ; i32 _random
_random:
        sub rsp, 8
        ; addrof a.5.1{r0}, __random__
        lea rax, [var_0]
        ; load r.1{r0}, [a.5.1{r0}]
        mov eax, [rax]
        ; move t.6.1{r1}, r.1{r0}
        mov edi, eax
        ; and t.6.1{r1}, 524287
        and edi, 524287
        ; mul b.1{r1}, 48271
        movsxd rdi, edi
        imul  rdi, 48271
        ; shiftright t.7.1{r0}, 15
        sar eax, 15
        ; mul c.1{r0}, 48271
        movsxd rax, eax
        imul  rax, 48271
        ; move t.8.1{r2}, c.1{r0}
        mov esi, eax
        ; and t.8.1{r2}, 65535
        and esi, 65535
        ; shiftleft d.1{r2}, 15
        sal esi, 15
        ; shiftright t.10.1{r0}, 16
        sar eax, 16
        ; add t.9.1{r0}, b.1{r1}
        add eax, edi
        ; add e.1{r0}, d.1{r2}
        add eax, esi
        ; move t.12.1{r1}, e.1{r0}
        mov edi, eax
        ; and t.12.1{r1}, 2147483647
        and edi, 2147483647
        ; shiftright t.13.1{r0}, 31
        sar eax, 31
        ; add t.11.1{r1}, t.13.1{r0}
        add edi, eax
        ; addrof a.14.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.14.1{r0}], t.11.1{r1}
        mov [rax], edi
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r1}
        mov eax, edi
        add rsp, 8
        ret

        ; i16 _random16
_random16:
        sub rsp, 8
        ; 20:25 return (i16) & 32767
        ; call t.2.1{r0} = _random[] -> i32
        call _random
        ; cast t.1.1{r0}(i16), t.2.1{r0}(i32)
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 8
        ret

        ; i16 _rowColumnToCell@u8@u8
        ;   rsp+0: arg row
        ;   rsp+1: arg column
_rowColumnToCell@u8@u8:
        sub rsp, 8
        ; cast r.1{r0}(i16), row{r1}(u8)
        movzx ax, dil
        ; cast c.1{r1}(i16), column{r2}(u8)
        movzx di, sil
        ; 26:19 return r * 40 + c
        ; mul t.5.1{r0}, 40
        movsx rax, ax
        imul  rax, 40
        ; add t.4.1{r0}, c.1{r1}
        add ax, di
        add rsp, 8
        ret

        ; i16 _columnToX@u8
        ;   rsp+0: arg column
_columnToX@u8:
        sub rsp, 8
        ; cast c.1{r0}(i16), column{r1}(u8)
        movzx ax, dil
        ; 35:17 return c + 1 << 1
        ; add t.3.1{r0}, 1
        add ax, 1
        ; shiftleft t.2.1{r0}, 1
        sal ax, 1
        add rsp, 8
        ret

        ; void _printCellAt@u8@u8
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
        ; move column{r0}, column{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], al
        ; call t.5.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r1}, field
        lea rdi, [var_1]
        ; add t.3.2{r1}, t.4.1{r0}
        add rdi, rax
        ; load cell.1{r1}, [t.3.2{r1}]
        mov dil, [rdi]
        ; move row{r2}, row{r8}
        mov sil, bl
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call _printCellAt@u8@u8@u8[cell.1{r1}, row{r2}, column{r3}]
        call _printCellAt@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _printCellAt@u8@u8@u8
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
        ; call x.1{r0} = _columnToX@u8[column{r1}] -> i16
        call _columnToX@u8
        ; addrof memVarAddr{r9}, row
        lea r12, [rsp+33]
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.4.1{r1}(i16), row{r2}(u8)
        movzx di, sil
        ; move x.1{r2}, x.1{r0}
        mov si, ax
        ; call _setCursor@i16@i16[t.4.1{r1}, x.1{r2}]
        call _setCursor@i16@i16
        ; move cell{r1}, cell{r8}
        mov dil, bl
        ; load row{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; call _printCell@u8@u8@u8[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _printCell@u8@u8@u8
        ;   rsp+24: arg cell
        ;   rsp+25: arg row
        ;   rsp+26: arg column
_printCell@u8@u8@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const chr.1{r0}, 46
        mov al, 46
        ; 51:2 if cell & 32 != 0
        ; move t.6.1{r4}, cell{r1}
        mov cl, dil
        ; and t.6.1{r4}, 32
        and cl, 32
        ; branch t.6.1{r4} notequals 0: if_12_then
        cmp cl, 0
        jne if_12_then
        ; 66:7 if cell & 64 != 0
        ; and t.11.1{r1}, 64
        and dil, 64
        ; branch t.11.1{r1} equals 0: _printCell@u8@u8@u8.no_critical_edge_10, if_15_then
        cmp dil, 0
        je _printCell@u8@u8@u8.no_critical_edge_10
        jmp if_15_then
if_12_then:
        ; 52:3 if cell & 128 != 0
        ; move t.7.1{r0}, cell{r1}
        mov al, dil
        ; and t.7.1{r0}, 128
        and al, 128
        ; branch t.7.1{r0} equals 0: if_13_else, if_13_then
        cmp al, 0
        je if_13_else
        jmp if_13_then
_printCell@u8@u8@u8.no_critical_edge_10:
        ; move chr.2{r8}, chr.1{r0}
        mov bl, al
        jmp if_12_end
if_15_then:
        ; const chr.3{r0}, 35
        mov al, 35
        ; move chr.2{r8}, chr.3{r0}
        mov bl, al
        jmp if_12_end
if_13_else:
        ; move row{r1}, row{r2}
        mov dil, sil
        ; move column{r2}, column{r3}
        mov sil, dl
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.10.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.9.1{r1}, field
        lea rdi, [var_1]
        ; add t.9.2{r1}, t.10.1{r0}
        add rdi, rax
        ; load t.8.1{r0}, [t.9.2{r1}]
        mov al, [rdi]
        ; and count.1{r0}, 15
        and al, 15
        ; 58:4 if count > 0
        ; branch count.1{r0} lteq 0: if_14_else, if_14_then
        cmp al, 0
        jbe if_14_else
        jmp if_14_then
if_13_then:
        ; const chr.4{r0}, 42
        mov al, 42
        ; move chr.2{r8}, chr.4{r0}
        mov bl, al
        jmp if_12_end
if_14_else:
        ; const chr.5{r0}, 32
        mov al, 32
        ; move chr.2{r8}, chr.5{r0}
        mov bl, al
        jmp if_12_end
if_14_then:
        ; add chr.6{r0}, 48
        add al, 48
        ; move chr.2{r8}, chr.6{r0}
        mov bl, al
if_12_end:
        ; move chr.2{r1}, chr.2{r8}
        mov dil, bl
        ; call _printChar@u8[chr.2{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void _initializeScreen
_initializeScreen:
        sub rsp, 8
        ; call _printField[]
        call _printField
        add rsp, 8
        ret

        ; void _printField
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
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row.1{r0}, 0
        mov al, 0
        ; 85:2 for row < 20
        ; move row.2{r8}, row.1{r0}
        mov bl, al
        jmp for_16
for_16_body:
        ; cast t.3.1{r1}(i16), row.2{r8}(u8)
        movzx di, bl
        ; const arg.1.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[t.3.1{r1}, arg.1.1{r2}]
        call _setCursor@i16@i16
        ; const arg.2.0{r1}, 124
        mov dil, 124
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; const column.1{r0}, 0
        mov al, 0
        ; 90:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], sil
        jmp for_17
for_17_body:
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], sil
        ; const arg.3.0{r1}, 32
        mov dil, 32
        ; call _printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; move row.2{r1}, row.2{r8}
        mov dil, bl
        ; load column.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move column.2{r2}, column.2{r0}
        mov sil, al
        ; call t.6.1{r0} = _rowColumnToCell@u8@u8[row.2{r1}, column.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.5.1{r0}(i64), t.6.1{r0}(i16)
        movsx rax, ax
        ; addrof t.4.1{r1}, field
        lea rdi, [var_1]
        ; add t.4.2{r1}, t.5.1{r0}
        add rdi, rax
        ; load cell.1{r1}, [t.4.2{r1}]
        mov dil, [rdi]
        ; move row.2{r2}, row.2{r8}
        mov sil, bl
        ; load column.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move column.2{r3}, column.2{r0}
        mov dl, al
        ; call _printCell@u8@u8@u8[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@u8@u8
        ; load column.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move column.3{r0}, column.2{r2}
        mov al, sil
        ; add column.3{r0}, 1
        add al, 1
        ; move column.2{r2}, column.3{r0}
        mov sil, al
for_17:
        ; branch column.2{r2} lt 40: for_17_body
        cmp sil, 40
        jb for_17_body
        ; const t.7.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call _printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; move row.4{r0}, row.2{r8}
        mov al, bl
        ; add row.4{r0}, 1
        add al, 1
        ; move row.2{r8}, row.4{r0}
        mov bl, al
for_16:
        ; branch row.2{r8} lt 20: for_16_body
        cmp bl, 20
        jb for_16_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _showCursor@u8@u8@bool
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
        ; call x.1{r0} = _columnToX@u8[column{r1}] -> i16
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
        ; call _setCursor@i16@i16[t.6.1{r1}, t.7.1{r2}]
        call _setCursor@i16@i16
        ; const chr.1{r0}, 32
        mov al, 32
        ; 115:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} equals 0: if_18_end
        cmp dl, 0
        je if_18_end
        ; const chr.3{r0}, 91
        mov al, 91
if_18_end:
        ; move chr.2{r1}, chr.2{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], chr.2{r0}
        mov [r12], al
        ; call _printChar@u8[chr.2{r1}]
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
        ; call _setCursor@i16@i16[t.8.1{r1}, t.9.1{r2}]
        call _setCursor@i16@i16
        ; 121:2 if show
        ; addrof memVarAddr{r9}, show
        lea r12, [rsp+34]
        ; load show{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch show{r3} notequals 0: if_19_then
        cmp dl, 0
        jne if_19_then
        ; addrof memVarAddr{r9}, chr.2
        lea r12, [rsp+38]
        ; load chr.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp if_19_end
if_19_then:
        ; const chr.5{r0}, 93
        mov al, 93
        ; move chr.4{r1}, chr.5{r0}
        mov dil, al
if_19_end:
        ; call _printChar@u8[chr.4{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i16 _abs@i16
        ;   rsp+0: arg a
_abs@i16:
        sub rsp, 8
        ; branch a{r1} lt 0: if_20_then
        cmp di, 0
        jl if_20_then
        ; 179:9 return a
        ; move a{r0}, a{r1}
        mov ax, di
        jmp _abs@i16_ret
if_20_then:
        ; 177:10 return -a
        ; neg t.1.1{r1}, a{r1}
        neg rdi
        ; move t.1.1{r0}, t.1.1{r1}
        mov ax, di
_abs@i16_ret:
        add rsp, 8
        ret

        ; void _clearField
_clearField:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov ax, 0
        ; const i.1{r1}, 800
        mov di, 800
        ; 184:2 for i > 0
        jmp for_21
for_21_body:
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
for_21:
        ; branch i.2{r1} gt 0: for_21_body
        cmp di, 0
        jg for_21_body
        add rsp, 8
        ret

        ; i16 _initField@u8@u8
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
        ; 193:2 for bombs > 0
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
        jmp for_22
for_22_body:
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], bombCount.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombs.2{r1}
        mov [r12], di
        ; call t.8.1{r0} = _random16[] -> i16
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
        ; call t.9.1{r0} = _random16[] -> i16
        call _random16
        ; mod column.1{r3}, column.1{r0}, 40
        movsx rax, ax
        cqo
        mov rcx, 40
        idiv rcx
        ; move column.1{r1}, column.1{r3}
        mov di, dx
        ; addrof memVarAddr{r9}, column.1
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], column.1{r1}
        mov [r12], di
        ; 196:3 if _abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=196:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=196:20], location=196:18]]) > 1 || _abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=197:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=197:20], location=197:18]]) > 1
        ; addrof memVarAddr{r9}, row.1
        lea r12, [rsp+40]
        ; load row.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.11.1{r1}, row.1{r0}
        mov di, ax
        ; sub t.11.1{r1}, r.1{r8}
        sub di, bx
        ; call t.10.1{r0} = _abs@i16[t.11.1{r1}] -> i16
        call _abs@i16
        ; branch t.10.1{r0} gt 1: if_23_then
        cmp ax, 1
        jg if_23_then
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
        ; call t.12.1{r0} = _abs@i16[t.13.1{r1}] -> i16
        call _abs@i16
        ; branch t.12.1{r0} gt 1: if_23_then
        cmp ax, 1
        jg if_23_then
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, bombCount.4
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], bombCount.4{r0}
        mov [r12], ax
        jmp for_22_continue
if_23_then:
        ; 198:4 if _setBomb@u8@u8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=198:15], type=u8, location=198:22], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=198:26], type=u8, location=198:36]])
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
        ; call t.14.1{r0} = _setBomb@u8@u8[t.15.1{r1}, t.16.1{r2}] -> bool
        call _setBomb@u8@u8
        ; branch t.14.1{r0} notequals 0: if_25_then
        cmp al, 0
        jne if_25_then
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        jmp for_22_continue
if_25_then:
        ; addrof memVarAddr{r9}, bombCount.2
        lea r12, [rsp+36]
        ; load bombCount.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add bombCount.5{r0}, 1
        add ax, 1
for_22_continue:
        ; addrof memVarAddr{r9}, bombs.2
        lea r12, [rsp+38]
        ; load bombs.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; sub bombs.5{r1}, 1
        sub di, 1
for_22:
        ; branch bombs.2{r1} gt 0: for_22_body
        cmp di, 0
        jg for_22_body
        ; 203:9 return bombCount
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; bool _setBomb@u8@u8
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
        ; move column{r0}, column{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], al
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; move index.1{r1}, index.1{r0}
        mov di, ax
        ; 208:2 if [...] == 128
        ; cast t.14.1{r0}(i64), index.1{r1}(i16)
        movsx rax, di
        ; addrof t.13.1{r2}, field
        lea rsi, [var_1]
        ; add t.13.2{r2}, t.14.1{r0}
        add rsi, rax
        ; load t.12.1{r0}, [t.13.2{r2}]
        mov al, [rsi]
        ; branch t.12.1{r0} equals 128: if_26_then
        cmp al, 128
        je if_26_then
        ; const t.15.1{r0}, 128
        mov al, 128
        ; cast t.17.1{r2}(i64), index.1{r1}(i16)
        movsx rsi, di
        ; addrof t.16.1{r3}, field
        lea rdx, [var_1]
        ; add t.16.2{r3}, t.17.1{r2}
        add rdx, rsi
        ; store [t.16.2{r3}], t.15.1{r0}
        mov [rdx], al
        ; move rowFrom.1{r2}, row{r8}
        mov sil, bl
        ; 214:2 if rowFrom > 0
        ; branch rowFrom.1{r2} lteq 0: if_27_end, if_27_then
        cmp sil, 0
        jbe if_27_end
        jmp if_27_then
if_26_then:
        ; const {r0}, 0
        mov al, 0
        jmp _setBomb@u8@u8_ret
if_27_then:
        ; sub rowFrom.3{r2}, 1
        sub sil, 1
        ; sub index.3{r1}, 40
        sub di, 40
if_27_end:
        ; move rowTo.1{r3}, row{r8}
        mov dl, bl
        ; add rowTo.1{r3}, 1
        add dl, 1
        ; 219:2 if rowTo >= 20
        ; branch rowTo.1{r3} lt 20: if_28_end
        cmp dl, 20
        jb if_28_end
        ; sub rowTo.3{r3}, 1
        sub dl, 1
if_28_end:
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; load column{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move colFrom.1{r5}, column{r4}
        mov r8b, cl
        ; 224:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_29_end
        cmp r8b, 0
        jbe if_29_end
        ; sub colFrom.3{r5}, 1
        sub r8b, 1
        ; sub index.6{r1}, 1
        sub di, 1
if_29_end:
        ; move colTo.1{r6}, column{r4}
        mov r9b, cl
        ; add colTo.1{r6}, 1
        add r9b, 1
        ; 229:2 if colTo >= 40
        ; branch colTo.1{r6} lt 40: if_30_end
        cmp r9b, 40
        jb if_30_end
        ; sub colTo.3{r6}, 1
        sub r9b, 1
if_30_end:
        ; 234:2 for r <= rowTo
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
        jmp for_31
for_31_body:
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
        ; 235:3 for c <= colTo
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp for_32
for_32_body:
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
        ; branch r.2{r2} notequals row{r8}: if_33_end
        cmp sil, bl
        jne if_33_end
        ; branch c.2{r7} notequals column{r4}: if_33_end
        cmp r10b, cl
        jne if_33_end
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        jmp for_32_continue
if_33_end:
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
        ; 241:4 if cell & 128 == 0
        ; move t.20.1{r8}, cell.1{r4}
        mov bl, cl
        ; and t.20.1{r8}, 128
        and bl, 128
        ; branch t.20.1{r8} equals 0: if_35_then
        cmp bl, 0
        je if_35_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        jmp for_32_continue
if_35_then:
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
for_32_continue:
        ; move c.5{r3}, c.2{r7}
        mov dl, r10b
        ; add c.5{r3}, 1
        add dl, 1
        ; add index.13{r1}, 1
        add di, 1
        ; move c.2{r7}, c.5{r3}
        mov r10b, dl
for_32:
        ; branch c.2{r7} lteq colTo.2{r6}: for_32_body
        cmp r10b, r9b
        jbe for_32_body
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
for_31:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; load rowTo.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch r.2{r2} lteq rowTo.2{r3}: for_31_body
        cmp sil, dl
        jbe for_31_body
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

        ; void _maybeRevealAround@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var r.2
        ;   rsp+36: var index.4
        ;   rsp+38: var c.2
        ;   rsp+39: var r.7
        ;   rsp+40: var index.6
        ;   rsp+42: var c.4
        ;   rsp+43: var c.7
        ;   rsp+44: var index.9
_maybeRevealAround@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bl, dil
        ; move column{r0}, column{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], al
        ; call _printCellAt@u8@u8[row{r1}, column{r2}]
        call _printCellAt@u8@u8
        ; move row{r1}, row{r8}
        mov dil, bl
        ; load column{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; 255:2 if [...] & 15 != 0
        ; cast t.14.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.13.1{r1}, field
        lea rdi, [var_1]
        ; add t.13.2{r1}, t.14.1{r0}
        add rdi, rax
        ; load t.12.1{r0}, [t.13.2{r1}]
        mov al, [rdi]
        ; and t.11.1{r0}, 15
        and al, 15
        ; branch t.11.1{r0} notequals 0: _maybeRevealAround@u8@u8_ret
        cmp al, 0
        jne _maybeRevealAround@u8@u8_ret
        ; const changed.1{r0}, 1
        mov al, 1
        ; 260:2 while changed
        ; move changed.2{r8}, changed.1{r0}
        mov bl, al
        jmp while_37
while_37_body:
        ; const changed.3{r0}, 0
        mov al, 0
        ; const index.2{r1}, 0
        mov di, 0
        ; const r.1{r2}, 0
        mov sil, 0
        ; 264:3 for r < 20
        ; move changed.4{r8}, changed.3{r0}
        mov bl, al
        ; move r.2{r0}, r.2{r2}
        mov al, sil
        jmp for_38
for_38_body:
        ; move r.2{r2}, r.2{r0}
        mov sil, al
        ; move index.3{r0}, index.3{r1}
        mov ax, di
        ; const c.1{r1}, 0
        mov dil, 0
        ; 265:4 for c < 40
        ; move c.2{r3}, c.1{r1}
        mov dl, dil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r2}
        mov [r12], sil
        ; move c.2{r2}, c.2{r3}
        mov sil, dl
        ; move index.4{r1}, index.4{r0}
        mov di, ax
        jmp for_39
for_39_body:
        ; move c.2{r3}, c.2{r2}
        mov dl, sil
        ; move index.4{r0}, index.4{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.16.1{r1}(i64), index.4{r0}(i16)
        movsx rdi, ax
        ; addrof t.15.1{r4}, field
        lea rcx, [var_1]
        ; add t.15.2{r4}, t.16.1{r1}
        add rcx, rdi
        ; load cell.1{r1}, [t.15.2{r4}]
        mov dil, [rcx]
        ; 267:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.17.1{r4}, cell.1{r1}
        mov cl, dil
        ; and t.17.1{r4}, 32
        and cl, 32
        ; branch t.17.1{r4} notequals 0: or_41
        cmp cl, 0
        jne or_41
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.4{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        jmp for_39_continue
or_41:
        ; and t.18.1{r1}, 128
        and dil, 128
        ; branch t.18.1{r1} equals 0: if_40_end
        cmp dil, 0
        je if_40_end
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.4{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r2}
        mov [r12], sil
        jmp for_39_continue
if_40_end:
        ; 270:5 if [...] & 15 != 0
        ; cast t.22.1{r1}(i64), index.4{r0}(i16)
        movsx rdi, ax
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], index.4{r0}
        mov [r12], ax
        ; addrof t.21.1{r0}, field
        lea rax, [var_1]
        ; add t.21.2{r0}, t.22.1{r1}
        add rax, rdi
        ; load t.20.1{r0}, [t.21.2{r0}]
        mov al, [rax]
        ; and t.19.1{r0}, 15
        and al, 15
        ; branch t.19.1{r0} equals 0: if_42_end
        cmp al, 0
        je if_42_end
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r2}
        mov [r12], sil
        jmp for_39_continue
if_42_end:
        ; 274:5 if _revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=5, scope=function, type=u8, varIsArray=false, location=274:24], ExprVarAccess[varName=c, index=6, scope=function, type=u8, varIsArray=false, location=274:27]])
        ; move r.2{r1}, r.2{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], r.2{r2}
        mov [r12], sil
        ; move c.2{r2}, c.2{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r3}
        mov [r12], dl
        ; call t.23.1{r0} = _revealNeighbors@u8@u8[r.2{r1}, c.2{r2}] -> bool
        call _revealNeighbors@u8@u8
        ; branch t.23.1{r0} equals 0: for_39_continue
        cmp al, 0
        je for_39_continue
        ; const changed.9{r0}, 1
        mov al, 1
        ; move changed.8{r8}, changed.9{r0}
        mov bl, al
for_39_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.6{r0}, c.2{r2}
        mov al, sil
        ; add c.6{r0}, 1
        add al, 1
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+36]
        ; load index.4{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add index.8{r1}, 1
        add di, 1
        ; move c.2{r2}, c.6{r0}
        mov sil, al
for_39:
        ; branch c.2{r2} lt 40: for_39_body
        cmp sil, 40
        jb for_39_body
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+34]
        ; load r.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add r.6{r0}, 1
        add al, 1
for_38:
        ; branch r.2{r0} lt 20: for_38_body
        cmp al, 20
        jb for_38_body
        ; branch changed.4{r8} equals 0: _maybeRevealAround@u8@u8_ret
        cmp bl, 0
        je _maybeRevealAround@u8@u8_ret
        ; const r.4{r0}, 20
        mov al, 20
        ; 285:3 while true
        ; move index.5{r2}, index.5{r1}
        mov si, di
        ; move r.5{r1}, r.5{r0}
        mov dil, al
        ; move index.5{r0}, index.5{r2}
        mov ax, si
        jmp while_45
if_46_end:
        ; move index.5{r2}, index.5{r0}
        mov si, ax
        ; move r.5{r0}, r.5{r1}
        mov al, dil
        ; move index.5{r1}, index.5{r2}
        mov di, si
        ; sub r.7{r0}, 1
        sub al, 1
        ; const c.3{r2}, 40
        mov sil, 40
        ; 292:4 while true
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r0}
        mov [r12], al
        ; move index.6{r0}, index.6{r1}
        mov ax, di
        ; move c.4{r1}, c.4{r2}
        mov dil, sil
        jmp while_47
if_48_end:
        ; move c.4{r2}, c.4{r1}
        mov sil, dil
        ; move index.6{r1}, index.6{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; load r.7{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move c.7{r3}, c.4{r2}
        mov dl, sil
        ; sub c.7{r3}, 1
        sub dl, 1
        ; sub index.9{r1}, 1
        sub di, 1
        ; cast t.25.1{r2}(i64), index.9{r1}(i16)
        movsx rsi, di
        ; addrof t.24.1{r4}, field
        lea rcx, [var_1]
        ; add t.24.2{r4}, t.25.1{r2}
        add rcx, rsi
        ; load cell.2{r2}, [t.24.2{r4}]
        mov sil, [rcx]
        ; 299:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.26.1{r4}, cell.2{r2}
        mov cl, sil
        ; and t.26.1{r4}, 32
        and cl, 32
        ; branch t.26.1{r4} notequals 0: or_50
        cmp cl, 0
        jne or_50
        ; move c.4{r2}, c.7{r3}
        mov sil, dl
        ; move index.6{r0}, index.6{r1}
        mov ax, di
        ; move c.4{r1}, c.4{r2}
        mov dil, sil
        jmp while_47
or_50:
        ; and t.27.1{r2}, 128
        and sil, 128
        ; branch t.27.1{r2} equals 0: if_49_end
        cmp sil, 0
        je if_49_end
        ; move c.4{r2}, c.7{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r0}
        mov [r12], al
        ; move index.6{r0}, index.6{r1}
        mov ax, di
        ; move c.4{r1}, c.4{r2}
        mov dil, sil
        jmp while_47
if_49_end:
        ; 302:5 if [...] & 15 != 0
        ; cast t.31.1{r2}(i64), index.9{r1}(i16)
        movsx rsi, di
        ; addrof t.30.1{r4}, field
        lea rcx, [var_1]
        ; add t.30.2{r4}, t.31.1{r2}
        add rcx, rsi
        ; load t.29.1{r2}, [t.30.2{r4}]
        mov sil, [rcx]
        ; and t.28.1{r2}, 15
        and sil, 15
        ; branch t.28.1{r2} equals 0: if_51_end
        cmp sil, 0
        je if_51_end
        ; addrof memVarAddr{r9}, index.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], index.6{r1}
        mov [r12], di
        ; move c.4{r2}, c.7{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, c.4
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], c.4{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r0}
        mov [r12], al
        ; move c.4{r1}, c.4{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, index.6
        lea r12, [rsp+40]
        ; load index.6{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        jmp while_47
if_51_end:
        ; addrof memVarAddr{r9}, index.9
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], index.9{r1}
        mov [r12], di
        ; 306:5 if _revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=8, scope=function, type=u8, varIsArray=false, location=306:24], ExprVarAccess[varName=c, index=9, scope=function, type=u8, varIsArray=false, location=306:27]])
        ; move r.7{r1}, r.7{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], r.7{r0}
        mov [r12], al
        ; move c.7{r2}, c.7{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, c.7
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], c.7{r3}
        mov [r12], dl
        ; call t.32.1{r0} = _revealNeighbors@u8@u8[r.7{r1}, c.7{r2}] -> bool
        call _revealNeighbors@u8@u8
        ; branch t.32.1{r0} notequals 0: if_52_then
        cmp al, 0
        jne if_52_then
        ; addrof memVarAddr{r9}, index.9
        lea r12, [rsp+44]
        ; load index.9{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; addrof memVarAddr{r9}, c.7
        lea r12, [rsp+43]
        ; load c.7{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move c.4{r1}, c.7{r2}
        mov dil, sil
        jmp while_47
if_52_then:
        ; addrof memVarAddr{r9}, c.7
        lea r12, [rsp+43]
        ; load c.7{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, index.9
        lea r12, [rsp+44]
        ; load index.9{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; const changed.10{r1}, 1
        mov dil, 1
        ; move changed.7{r8}, changed.10{r1}
        mov bl, dil
        ; move c.4{r1}, c.7{r2}
        mov dil, sil
while_47:
        ; branch c.4{r1} notequals 0: if_48_end
        cmp dil, 0
        jne if_48_end
        ; addrof memVarAddr{r9}, r.7
        lea r12, [rsp+39]
        ; load r.7{r1}, [memVarAddr{r9}]
        mov dil, [r12]
while_45:
        ; branch r.5{r1} notequals 0: if_46_end, while_37
        cmp dil, 0
        jne if_46_end
while_37:
        ; branch changed.2{r8} notequals 0: while_37_body, _maybeRevealAround@u8@u8_ret
        cmp bl, 0
        jne while_37_body
_maybeRevealAround@u8@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; bool _revealNeighbors@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: var rowTo.2
        ;   rsp+35: var colFrom.2
        ;   rsp+36: var colTo.2
        ;   rsp+37: var r.2
        ;   rsp+38: var c.2
        ;   rsp+39: var changed.4
_revealNeighbors@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move rowFrom.1{r0}, row{r1}
        mov al, dil
        ; 316:2 if rowFrom > 0
        ; branch rowFrom.1{r0} gt 0: if_53_then
        cmp al, 0
        ja if_53_then
        ; move rowFrom.2{r8}, rowFrom.1{r0}
        mov bl, al
        jmp if_53_end
if_53_then:
        ; sub rowFrom.3{r0}, 1
        sub al, 1
        ; move rowFrom.2{r8}, rowFrom.3{r0}
        mov bl, al
if_53_end:
        ; move rowTo.1{r0}, row{r1}
        mov al, dil
        ; add rowTo.1{r0}, 1
        add al, 1
        ; 320:2 if rowTo >= 20
        ; branch rowTo.1{r0} gteq 20: if_54_then
        cmp al, 20
        jae if_54_then
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r0}
        mov [r12], al
        jmp if_54_end
if_54_then:
        ; sub rowTo.3{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r0}
        mov [r12], al
if_54_end:
        ; move colFrom.1{r0}, column{r2}
        mov al, sil
        ; 325:2 if colFrom > 0
        ; branch colFrom.1{r0} lteq 0: if_55_end
        cmp al, 0
        jbe if_55_end
        ; sub colFrom.3{r0}, 1
        sub al, 1
if_55_end:
        ; move colTo.1{r1}, column{r2}
        mov dil, sil
        ; add colTo.1{r1}, 1
        add dil, 1
        ; 329:2 if colTo >= 40
        ; branch colTo.1{r1} gteq 40: if_56_then
        cmp dil, 40
        jae if_56_then
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r1}
        mov [r12], dil
        jmp if_56_end
if_56_then:
        ; sub colTo.3{r1}, 1
        sub dil, 1
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r1}
        mov [r12], dil
if_56_end:
        ; move rowFrom.2{r1}, rowFrom.2{r8}
        mov dil, bl
        ; move colFrom.2{r2}, colFrom.2{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom.2{r0}
        mov [r12], al
        ; call index.1{r0} = _rowColumnToCell@u8@u8[rowFrom.2{r1}, colFrom.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; const changed.1{r1}, 0
        mov dil, 0
        ; move r.1{r2}, rowFrom.2{r8}
        mov sil, bl
        ; 334:2 for r <= rowTo
        ; move index.2{r8}, index.1{r0}
        mov bx, ax
        ; move changed.2{r0}, changed.1{r1}
        mov al, dil
        ; move r.2{r3}, r.1{r2}
        mov dl, sil
        ; load colFrom.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; load colTo.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move r.2{r4}, r.2{r3}
        mov cl, dl
        jmp for_57
for_57_body:
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], colFrom.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], rowTo.2{r3}
        mov [r12], dl
        ; move r.2{r3}, r.2{r4}
        mov dl, cl
        ; move c.1{r1}, colFrom.2{r2}
        mov dil, sil
        ; 335:3 for c <= colTo
        ; move c.2{r4}, c.1{r1}
        mov cl, dil
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r3}
        mov [r12], dl
        ; move c.2{r3}, c.2{r4}
        mov dl, cl
        jmp for_58
for_58_body:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], colTo.2{r1}
        mov [r12], dil
        ; move c.2{r4}, c.2{r3}
        mov cl, dl
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; cast t.12.1{r1}(i64), index.3{r8}(i16)
        movsx rdi, bx
        ; addrof t.11.1{r2}, field
        lea rsi, [var_1]
        ; add t.11.2{r2}, t.12.1{r1}
        add rsi, rdi
        ; load cell.1{r1}, [t.11.2{r2}]
        mov dil, [rsi]
        ; 337:4 if cell & 32 != 0
        ; move t.13.1{r2}, cell.1{r1}
        mov sil, dil
        ; and t.13.1{r2}, 32
        and sil, 32
        ; branch t.13.1{r2} equals 0: if_59_end
        cmp sil, 0
        je if_59_end
        ; addrof memVarAddr{r9}, changed.4
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], changed.4{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, changed.4
        lea r12, [rsp+39]
        jmp for_58_continue
if_59_end:
        ; or cell.2{r1}, 32
        or dil, 32
        ; cast t.15.1{r0}(i64), index.3{r8}(i16)
        movsx rax, bx
        ; addrof t.14.1{r2}, field
        lea rsi, [var_1]
        ; add t.14.2{r2}, t.15.1{r0}
        add rsi, rax
        ; store [t.14.2{r2}], cell.2{r1}
        mov [rsi], dil
        ; move r.2{r2}, r.2{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], r.2{r3}
        mov [r12], dl
        ; move c.2{r3}, c.2{r4}
        mov dl, cl
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], c.2{r4}
        mov [r12], cl
        ; call _printCellAt@u8@u8@u8[cell.2{r1}, r.2{r2}, c.2{r3}]
        call _printCellAt@u8@u8@u8
        ; const changed.5{r0}, 1
        mov al, 1
for_58_continue:
        ; addrof memVarAddr{r9}, c.2
        lea r12, [rsp+38]
        ; load c.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move c.4{r1}, c.2{r3}
        mov dil, dl
        ; add c.4{r1}, 1
        add dil, 1
        ; move index.6{r2}, index.3{r8}
        mov si, bx
        ; add index.6{r2}, 1
        add si, 1
        ; move index.3{r8}, index.6{r2}
        mov bx, si
        ; move c.2{r3}, c.4{r1}
        mov dl, dil
for_58:
        ; addrof memVarAddr{r9}, colTo.2
        lea r12, [rsp+36]
        ; load colTo.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch c.2{r3} lteq colTo.2{r1}: for_58_body
        cmp dl, dil
        jbe for_58_body
        ; cast t.19.1{r2}(i16), colTo.2{r1}(u8)
        movzx si, dil
        ; move t.18.1{r3}, index.3{r8}
        mov dx, bx
        ; sub t.18.1{r3}, t.19.1{r2}
        sub dx, si
        ; addrof memVarAddr{r9}, colFrom.2
        lea r12, [rsp+35]
        ; load colFrom.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; cast t.20.1{r4}(i16), colFrom.2{r2}(u8)
        movzx cx, sil
        ; add t.17.1{r3}, t.20.1{r4}
        add dx, cx
        ; add t.16.1{r3}, 40
        add dx, 40
        ; sub index.4{r3}, 1
        sub dx, 1
        ; addrof memVarAddr{r9}, r.2
        lea r12, [rsp+37]
        ; load r.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; add r.4{r4}, 1
        add cl, 1
        ; move index.2{r8}, index.4{r3}
        mov bx, dx
for_57:
        ; addrof memVarAddr{r9}, rowTo.2
        lea r12, [rsp+34]
        ; load rowTo.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch r.2{r4} lteq rowTo.2{r3}: for_57_body
        cmp cl, dl
        jbe for_57_body
        ; 348:9 return changed
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _main
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
        ; const t.8.1{r0}, 0
        mov eax, 0
        ; addrof a.9.1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.9.1{r1}], t.8.1{r0}
        mov [rdi], eax
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call _initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call _clearField[]
        call _clearField
        ; call _initializeScreen[]
        call _initializeScreen
        ; const arg.3.0{r1}, 20
        mov di, 20
        ; const arg.3.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; const col.1{r0}, 20
        mov al, 20
        ; const row.1{r1}, 10
        mov dil, 10
        ; const bombsLeft.1{r2}, -1
        mov si, -1
        ; 360:2 while true
        ; move col.2{r8}, col.1{r0}
        mov bl, al
        ; move row.2{r0}, row.1{r1}
        mov al, dil
        ; move bombsLeft.2{r1}, bombsLeft.1{r2}
        mov di, si
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_61_end:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; const t.11.1{r3}, 1
        mov dl, 1
        ; move row.2{r1}, row.2{r0}
        mov dil, al
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call _showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.11.1{r3}]
        call _showCursor@u8@u8@bool
        ; call chr.1{r0} = _getChar[] -> i16
        call _getChar
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; const t.12.1{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move row.2{r1}, row.2{r0}
        mov dil, al
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call _showCursor@u8@u8@bool[row.2{r1}, col.2{r2}, t.12.1{r3}]
        call _showCursor@u8@u8@bool
        ; 369:3 if chr == 27
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; load chr.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; branch chr.1{r0} equals 27: _main_ret
        cmp ax, 27
        je _main_ret
        ; branch chr.1{r0} equals 10: if_63_then
        cmp ax, 10
        je if_63_then
        ; branch chr.1{r0} notequals -8120: if_67_else, if_67_then
        cmp ax, -8120
        jne if_67_else
        jmp if_67_then
if_63_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; branch bombsLeft.2{r1} gteq 0: _main.no_critical_edge_42, if_64_then
        cmp di, 0
        jge _main.no_critical_edge_42
        jmp if_64_then
if_67_else:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; branch chr.1{r0} notequals -8112: if_69_else, if_69_then
        cmp ax, -8112
        jne if_69_else
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        jmp if_69_then
if_67_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; branch row.2{r0} lteq 0: _main.no_critical_edge_41, if_68_then
        cmp al, 0
        jbe _main.no_critical_edge_41
        jmp if_68_then
_main.no_critical_edge_42:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, bombsLeft.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombsLeft.3{r1}
        mov [r12], di
        jmp if_64_end
if_64_then:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move row.2{r1}, row.2{r0}
        mov dil, al
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call bombsLeft.4{r0} = _initField@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _initField@u8@u8
        ; addrof memVarAddr{r9}, bombsLeft.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], bombsLeft.3{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp if_64_end
if_69_else:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8117: if_71_else, if_71_then
        cmp ax, -8117
        jne if_71_else
        jmp if_71_then
if_69_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; branch row.2{r0} gteq 19: _main.no_critical_edge_40, if_70_then
        cmp al, 19
        jae _main.no_critical_edge_40
        jmp if_70_then
_main.no_critical_edge_41:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_68_then:
        ; sub row.4{r0}, 1
        sub al, 1
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_64_end:
        ; move row.2{r1}, row.2{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call index.1{r0} = _rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.14.1{r1}(i64), index.1{r0}(i16)
        movsx rdi, ax
        ; addrof t.13.1{r2}, field
        lea rsi, [var_1]
        ; add t.13.2{r2}, t.14.1{r1}
        add rsi, rdi
        ; load cell.1{r1}, [t.13.2{r2}]
        mov dil, [rsi]
        ; 379:4 if cell & 32 == 0
        ; move t.15.1{r2}, cell.1{r1}
        mov sil, dil
        ; and t.15.1{r2}, 32
        and sil, 32
        ; branch t.15.1{r2} notequals 0: _main.no_critical_edge_43, if_65_then
        cmp sil, 0
        jne _main.no_critical_edge_43
        jmp if_65_then
if_71_else:
        ; addrof memVarAddr{r9}, chr.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], chr.1{r0}
        mov [r12], ax
        ; branch chr.1{r0} notequals -8115: if_73_else, if_73_then
        cmp ax, -8115
        jne if_73_else
        jmp if_73_then
if_71_then:
        ; branch col.2{r8} lteq 0: _main.no_critical_edge_39, if_72_then
        cmp bl, 0
        jbe _main.no_critical_edge_39
        jmp if_72_then
_main.no_critical_edge_40:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; move row.2{r2}, row.2{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_70_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add row.5{r0}, 1
        add al, 1
        ; move row.2{r2}, row.5{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
_main.no_critical_edge_43:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        jmp if_65_end
if_65_then:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move t.16.1{r3}, cell.1{r1}
        mov dl, dil
        ; or t.16.1{r3}, 32
        or dl, 32
        ; cast t.18.1{r0}(i64), index.1{r0}(i16)
        movsx rax, ax
        ; addrof t.17.1{r4}, field
        lea rcx, [var_1]
        ; add t.17.2{r4}, t.18.1{r0}
        add rcx, rax
        ; store [t.17.2{r4}], t.16.1{r3}
        mov [rcx], dl
        jmp if_65_end
if_73_else:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch chr.1{r0} notequals 32: _main.no_critical_edge_34, if_75_then
        cmp ax, 32
        jne _main.no_critical_edge_34
        jmp if_75_then
if_73_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch col.2{r8} gteq 39: _main.no_critical_edge_38, if_74_then
        cmp bl, 39
        jae _main.no_critical_edge_38
        jmp if_74_then
_main.no_critical_edge_39:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_72_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; move col.5{r0}, col.2{r8}
        mov al, bl
        ; sub col.5{r0}, 1
        sub al, 1
        ; move col.2{r8}, col.5{r0}
        mov bl, al
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_65_end:
        ; 382:4 if cell & 128 != 0
        ; move t.19.1{r0}, cell.1{r1}
        mov al, dil
        ; and t.19.1{r0}, 128
        and al, 128
        ; branch t.19.1{r0} equals 0: if_66_end, if_66_then
        cmp al, 0
        je if_66_end
        jmp if_66_then
_main.no_critical_edge_34:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_75_then:
        ; branch bombsLeft.2{r1} lt 0: _main.no_critical_edge_35, if_76_then
        cmp di, 0
        jl _main.no_critical_edge_35
        jmp if_76_then
_main.no_critical_edge_38:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_74_then:
        ; move col.6{r0}, col.2{r8}
        mov al, bl
        ; add col.6{r0}, 1
        add al, 1
        ; move col.2{r8}, col.6{r0}
        mov bl, al
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_66_end:
        ; move row.2{r1}, row.2{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call _maybeRevealAround@u8@u8[row.2{r1}, col.2{r2}]
        call _maybeRevealAround@u8@u8
        ; addrof memVarAddr{r9}, bombsLeft.3
        lea r12, [rsp+38]
        ; load bombsLeft.3{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
_main.no_critical_edge_35:
        ; move row.2{r0}, row.2{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; move bombsLeft.2{r0}, bombsLeft.2{r1}
        mov ax, di
        jmp while_60
if_76_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], bombsLeft.2{r1}
        mov [r12], di
        ; move row.2{r0}, row.2{r2}
        mov al, sil
        ; move row.2{r1}, row.2{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], al
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call index.2{r0} = _rowColumnToCell@u8@u8[row.2{r1}, col.2{r2}] -> i16
        call _rowColumnToCell@u8@u8
        ; cast t.22.1{r1}(i64), index.2{r0}(i16)
        movsx rdi, ax
        ; addrof t.21.1{r2}, field
        lea rsi, [var_1]
        ; add t.21.2{r2}, t.22.1{r1}
        add rsi, rdi
        ; load cell.3{r1}, [t.21.2{r2}]
        mov dil, [rsi]
        ; 418:5 if cell & 32 == 0
        ; move t.23.1{r2}, cell.3{r1}
        mov sil, dil
        ; and t.23.1{r2}, 32
        and sil, 32
        ; branch t.23.1{r2} equals 0: if_77_then
        cmp sil, 0
        je if_77_then
        ; load row.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; move bombsLeft.2{r0}, bombsLeft.2{r2}
        mov ax, si
        jmp while_60
if_77_then:
        ; addrof memVarAddr{r9}, bombsLeft.2
        lea r12, [rsp+34]
        ; load bombsLeft.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; xor cell.4{r1}, 64
        xor dil, 64
        ; 420:6 if cell & 128 != 0
        ; move t.24.1{r4}, cell.4{r1}
        mov cl, dil
        ; and t.24.1{r4}, 128
        and cl, 128
        ; branch t.24.1{r4} notequals 0: if_78_then
        cmp cl, 0
        jne if_78_then
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], bombsLeft.6{r2}
        mov [r12], si
        jmp if_78_end
if_78_then:
        ; 421:7 if cell & 64 != 0
        ; move t.25.1{r4}, cell.4{r1}
        mov cl, dil
        ; and t.25.1{r4}, 64
        and cl, 64
        ; branch t.25.1{r4} notequals 0: if_79_then
        cmp cl, 0
        jne if_79_then
        ; add bombsLeft.7{r2}, 1
        add si, 1
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], bombsLeft.6{r2}
        mov [r12], si
        jmp if_78_end
if_79_then:
        ; sub bombsLeft.8{r2}, 1
        sub si, 1
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], bombsLeft.6{r2}
        mov [r12], si
if_78_end:
        ; cast t.27.1{r0}(i64), index.2{r0}(i16)
        movsx rax, ax
        ; addrof t.26.1{r2}, field
        lea rsi, [var_1]
        ; add t.26.2{r2}, t.27.1{r0}
        add rsi, rax
        ; store [t.26.2{r2}], cell.4{r1}
        mov [rsi], dil
        ; move row.2{r2}, row.2{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r3}
        mov [r12], dl
        ; move col.2{r3}, col.2{r8}
        mov dl, bl
        ; call _printCellAt@u8@u8@u8[cell.4{r1}, row.2{r2}, col.2{r3}]
        call _printCellAt@u8@u8@u8
        ; load row.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, bombsLeft.6
        lea r12, [rsp+40]
        ; load bombsLeft.6{r0}, [memVarAddr{r9}]
        mov ax, [r12]
while_60:
        ; branch bombsLeft.2{r0} notequals 0: if_61_end
        cmp ax, 0
        jne if_61_end
        ; const t.10.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call _printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _main_ret
if_66_then:
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r2}
        mov [r12], sil
        ; move row.2{r1}, row.2{r2}
        mov dil, sil
        ; move col.2{r2}, col.2{r8}
        mov sil, bl
        ; call _printCellAt@u8@u8[row.2{r1}, col.2{r2}]
        call _printCellAt@u8@u8
        ; const t.20.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call _printString@@u8[t.20.1{r1}]
        call _printString@@u8
_main_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void _printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

        ; i16 _____getChar
_____getChar:
        sub    rsp, 48
        xor    edi, edi
        mov    eax, 16
        mov    esi, 5401h
        mov    rdx, rsp
        syscall
        mov    r8d, [rsp+12]
        mov    r9w, [rsp+22]
        and    dword [rsp+12], not 4Ah
        mov    word [rsp+22], 100h
        mov    eax, 16
        mov    esi, 5402h
        syscall
        xor    eax, eax
        lea    rsi, [rsp+40]
        mov    edx, 1
        syscall
        mov    r10d, -1
        cmp    eax, 1
        jne    .restore
        movzx  r10d, byte [rsp+40]
.restore:
        mov    [rsp+12], r8d
        mov    [rsp+22], r9w
        mov    eax, 16
        mov    esi, 5402h
        mov    rdx, rsp
        syscall
        mov    eax, r10d
        add    rsp, 48
        ret

segment readable writable
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/800)
        var_1 rb 800

segment readable
        string_0 db 0x1b, '[', 0x00
        string_1 db ' |', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

