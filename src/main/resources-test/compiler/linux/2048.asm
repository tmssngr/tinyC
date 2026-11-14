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

        ; void _printUint@i32
        ;   rsp+0: arg number
_printUint@i32:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i32)
        movsxd rdi, edi
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

        ; i16 _tileValue@u8
        ;   rsp+0: arg exponent
_tileValue@u8:
        sub rsp, 8
        ; const value.1{r0}, 1
        mov ax, 1
        ; const index.1{r2}, 0
        mov sil, 0
        ; 49:2 for index < exponent
        jmp for_12
for_12_body:
        ; shiftleft value.3{r0}, 1
        sal ax, 1
        ; add index.3{r2}, 1
        add sil, 1
for_12:
        ; branch index.2{r2} lt exponent{r1}: for_12_body
        cmp sil, dil
        jb for_12_body
        ; 52:9 return value
        add rsp, 8
        ret

        ; u8 _spawnTile
        ;   rsp+32: var tile.1
_spawnTile:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const emptyCount.1{r0}, 0
        mov al, 0
        ; const index.1{r1}, 0
        mov dil, 0
        ; 57:2 for index < 16
        ; move emptyCount.2{r8}, emptyCount.1{r0}
        mov bl, al
        jmp for_13
for_13_body:
        ; 58:3 if [...] == 0
        ; cast t.7.1{r1}(i64), index.2{r0}(u8)
        movzx rdi, al
        ; addrof t.6.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rsi, rdi
        ; load t.5.1{r1}, [t.6.2{r2}]
        mov dil, [rsi]
        ; branch t.5.1{r1} equals 0: if_14_then
        cmp dil, 0
        je if_14_then
        ; move emptyCount.3{r1}, emptyCount.2{r8}
        mov dil, bl
        jmp for_13_continue
if_14_then:
        ; move emptyCount.4{r1}, emptyCount.2{r8}
        mov dil, bl
        ; add emptyCount.4{r1}, 1
        add dil, 1
for_13_continue:
        ; add index.6{r0}, 1
        add al, 1
        ; move emptyCount.2{r8}, emptyCount.3{r1}
        mov bl, dil
for_13:
        ; branch index.2{r0} lt 16: for_13_body
        cmp al, 16
        jb for_13_body
        ; branch emptyCount.2{r8} equals 0: if_15_then
        cmp bl, 0
        je if_15_then
        ; call t.9.1{r0} = _random16[] -> i16
        call _random16
        ; cast t.10.1{r1}(i16), emptyCount.2{r8}(u8)
        movzx di, bl
        ; mod t.8.1{r3}, t.8.1{r0}, t.10.1{r1}
        movsx rax, ax
        movsx rdi, di
        cqo
        idiv rdi
        ; move t.8.1{r2}, t.8.1{r3}
        mov si, dx
        ; cast chosen.1{r0}(u8), t.8.1{r2}(i16)
        mov al, sil
        ; const index.3{r1}, 0
        mov dil, 0
        ; 67:2 for index < 16
        ; move chosen.2{r2}, chosen.1{r0}
        mov sil, al
        ; move index.4{r8}, index.3{r1}
        mov bl, dil
        jmp for_16
for_16_body:
        ; 68:3 if [...] != 0
        ; cast t.13.1{r0}(i64), index.4{r8}(u8)
        movzx rax, bl
        ; addrof t.12.1{r1}, tiles
        lea rdi, [var_1]
        ; add t.12.2{r1}, t.13.1{r0}
        add rdi, rax
        ; load t.11.1{r0}, [t.12.2{r1}]
        mov al, [rdi]
        ; branch t.11.1{r0} equals 0: if_17_end
        cmp al, 0
        je if_17_end
        ; move chosen.3{r0}, chosen.2{r2}
        mov al, sil
        jmp for_16_continue
if_17_end:
        ; branch chosen.2{r2} equals 0: if_18_then
        cmp sil, 0
        je if_18_then
        ; move chosen.4{r0}, chosen.2{r2}
        mov al, sil
        ; sub chosen.4{r0}, 1
        sub al, 1
for_16_continue:
        ; move index.8{r1}, index.4{r8}
        mov dil, bl
        ; add index.8{r1}, 1
        add dil, 1
        ; move chosen.2{r2}, chosen.3{r0}
        mov sil, al
        ; move index.4{r8}, index.8{r1}
        mov bl, dil
        jmp for_16
if_15_then:
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
for_16:
        ; branch index.4{r8} lt 16: for_16_body
        cmp bl, 16
        jb for_16_body
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
if_18_then:
        ; const tile.1{r1}, 1
        mov dil, 1
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], tile.1{r1}
        mov [r12], dil
        ; 73:4 if _random16([]) % 10 == 0
        ; call t.15.1{r0} = _random16[] -> i16
        call _random16
        ; mod t.14.1{r3}, t.14.1{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move t.14.1{r1}, t.14.1{r3}
        mov di, dx
        ; branch t.14.1{r1} equals 0: if_19_then
        cmp di, 0
        je if_19_then
        ; load tile.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp if_19_end
if_19_then:
        ; const tile.3{r0}, 2
        mov al, 2
if_19_end:
        ; cast t.17.1{r1}(i64), index.4{r8}(u8)
        movzx rdi, bl
        ; addrof t.16.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.16.2{r2}, t.17.1{r1}
        add rsi, rdi
        ; store [t.16.2{r2}], tile.2{r0}
        mov [rsi], al
        ; 77:11 return index
        ; move index.4{r0}, index.4{r8}
        mov al, bl
_spawnTile_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool _slideLine@u8@u8
        ;   rsp+32: arg first
        ;   rsp+33: arg step
        ;   rsp+34: var source.2
        ;   rsp+35: var target.2
        ;   rsp+36: var position.2
        ;   rsp+37: var tile.1
        ;   rsp+38: var target.3
        ;   rsp+39: var previousMerged.3
        ;   rsp+40: var moved.3
        ;   rsp+41: var previousMerged.4
        ;   rsp+42: var moved.4
        ;   rsp+43: var merged.2
        ;   rsp+44: var nextTile.1
_slideLine@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move first{r8}, first{r1}
        mov bl, dil
        ; move source.1{r0}, first{r8}
        mov al, bl
        ; const moved.1{r4}, 0
        mov cl, 0
        ; const position.1{r5}, 0
        mov r8b, 0
        ; 91:2 for position < 4
        ; addrof memVarAddr{r9}, position.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], position.2{r5}
        mov [r12], r8b
        ; move moved.2{r6}, moved.2{r4}
        mov r9b, cl
        ; move step{r4}, step{r2}
        mov cl, sil
        ; move moved.2{r2}, moved.2{r6}
        mov sil, r9b
        ; move source.2{r3}, source.2{r0}
        mov dl, al
        ; move previousMerged.2{r1}, previousMerged.2{r6}
        mov dil, r9b
        jmp for_20
for_20_body:
        ; addrof memVarAddr{r9}, position.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], position.2{r5}
        mov [r12], r8b
        ; move moved.2{r5}, moved.2{r2}
        mov r8b, sil
        ; move step{r2}, step{r4}
        mov sil, cl
        ; move moved.2{r4}, moved.2{r5}
        mov cl, r8b
        ; move previousMerged.2{r5}, previousMerged.2{r1}
        mov r8b, dil
        ; move target.2{r1}, target.2{r0}
        mov dil, al
        ; move source.2{r0}, source.2{r3}
        mov al, dl
        ; move previousMerged.2{r3}, previousMerged.2{r5}
        mov dl, r8b
        ; cast t.14.1{r5}(i64), source.2{r0}(u8)
        movzx r8, al
        ; addrof sourceTile.1{r6}, tiles
        lea r9, [var_1]
        ; add sourceTile.2{r6}, t.14.1{r5}
        add r9, r8
        ; load tile.1{r5}, [sourceTile.2{r6}]
        mov r8b, [r9]
        ; 94:3 if tile != 0
        ; branch tile.1{r5} notequals 0: if_21_then
        cmp r8b, 0
        jne if_21_then
        ; addrof memVarAddr{r9}, target.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], target.3{r1}
        mov [r12], dil
        ; move previousMerged.3{r1}, previousMerged.2{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, previousMerged.3
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], previousMerged.3{r1}
        mov [r12], dil
        ; move moved.3{r1}, moved.2{r4}
        mov dil, cl
        ; addrof memVarAddr{r9}, moved.3
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], moved.3{r1}
        mov [r12], dil
        ; move previousMerged.3{r1}, previousMerged.3{r3}
        mov dil, dl
        ; move source.2{r3}, source.2{r0}
        mov dl, al
        ; move step{r4}, step{r2}
        mov cl, sil
        ; addrof memVarAddr{r9}, target.3
        lea r12, [rsp+38]
        ; load target.3{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, moved.3
        lea r12, [rsp+40]
        ; load moved.3{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        jmp if_21_end
if_21_then:
        ; const t.15.1{r7}, 0
        mov r10b, 0
        ; store [sourceTile.2{r6}], t.15.1{r7}
        mov [r9], r10b
        ; const merged.1{r6}, 0
        mov r9b, 0
        ; 97:4 if target != first && !previousMerged
        ; branch target.2{r1} notequals first{r8}: and_23
        cmp dil, bl
        jne and_23
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r5}
        mov [r12], r8b
        ; move merged.2{r0}, merged.2{r6}
        mov al, r9b
        ; move moved.4{r2}, moved.4{r4}
        mov sil, cl
        ; move previousMerged.4{r1}, previousMerged.4{r3}
        mov dil, dl
        jmp if_22_end
and_23:
        ; branch previousMerged.2{r3} equals 0: if_22_then
        cmp dl, 0
        je if_22_then
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r5}
        mov [r12], r8b
        ; move merged.2{r0}, merged.2{r6}
        mov al, r9b
        ; move moved.4{r2}, moved.4{r4}
        mov sil, cl
        ; move previousMerged.4{r1}, previousMerged.4{r3}
        mov dil, dl
        jmp if_22_end
if_22_then:
        ; move previous.1{r7}, target.2{r1}
        mov r10b, dil
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r1}
        mov [r12], dil
        ; sub previous.1{r7}, step{r2}
        sub r10b, sil
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; cast t.16.1{r1}(i64), previous.1{r7}(u8)
        movzx rdi, r10b
        ; addrof previousTile.1{r2}, tiles
        lea rsi, [var_1]
        ; add previousTile.2{r2}, t.16.1{r1}
        add rsi, rdi
        ; 100:5 if *previousTile == tile
        ; load t.17.1{r1}, [previousTile.2{r2}]
        mov dil, [rsi]
        ; branch t.17.1{r1} equals tile.1{r5}: if_24_then
        cmp dil, r8b
        je if_24_then
        ; addrof memVarAddr{r9}, previousMerged.4
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], previousMerged.4{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, moved.4
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], moved.4{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, merged.2
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], merged.2{r6}
        mov [r12], r9b
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r5}
        mov [r12], r8b
        ; move merged.2{r0}, merged.2{r6}
        mov al, r9b
        ; move moved.4{r2}, moved.4{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, previousMerged.4
        lea r12, [rsp+41]
        ; move previousMerged.4{r1}, previousMerged.4{r3}
        mov dil, dl
        jmp if_22_end
if_24_then:
        ; move t.18.1{r1}, previous.1{r7}
        mov dil, r10b
        ; or t.18.1{r1}, 128
        or dil, 128
        ; cast t.20.1{r3}(i64), source.2{r0}(u8)
        movzx rdx, al
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof t.19.1{r0}, moveTargets
        lea rax, [var_3]
        ; add t.19.2{r0}, t.20.1{r3}
        add rax, rdx
        ; store [t.19.2{r0}], t.18.1{r1}
        mov [rax], dil
        ; move nextTile.1{r0}, tile.1{r5}
        mov al, r8b
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r5}
        mov [r12], r8b
        ; add nextTile.1{r0}, 1
        add al, 1
        ; store [previousTile.2{r2}], nextTile.1{r0}
        mov [rsi], al
        ; move nextTile.1{r1}, nextTile.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, nextTile.1
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], nextTile.1{r0}
        mov [r12], al
        ; call t.21.1{r0} = _tileValue@u8[nextTile.1{r1}] -> i16
        call _tileValue@u8
        ; cast mergedScore.1{r0}(i32), t.21.1{r0}(i16)
        movsx eax, ax
        ; addrof a.23.1{r1}, score
        lea rdi, [var_4]
        ; load t.24.1{r1}, [a.23.1{r1}]
        mov edi, [rdi]
        ; add t.22.1{r1}, mergedScore.1{r0}
        add edi, eax
        ; addrof a.25.1{r0}, score
        lea rax, [var_4]
        ; store [a.25.1{r0}], t.22.1{r1}
        mov [rax], edi
        ; 107:6 if nextTile == 11
        ; load nextTile.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch nextTile.1{r1} notequals 11: if_25_end
        cmp dil, 11
        jne if_25_end
        ; const t.26.1{r0}, 1
        mov al, 1
        ; addrof a.27.1{r1}, gameState
        lea rdi, [var_5]
        ; store [a.27.1{r1}], t.26.1{r0}
        mov [rdi], al
if_25_end:
        ; const merged.3{r0}, 1
        mov al, 1
        ; const previousMerged.6{r1}, 1
        mov dil, 1
        ; const moved.7{r2}, 1
        mov sil, 1
if_22_end:
        ; branch merged.2{r0} equals 0: if_26_then
        cmp al, 0
        je if_26_then
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; load target.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; load step{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        jmp if_21_end
if_26_then:
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; load target.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; cast t.29.1{r1}(i64), source.2{r3}(u8)
        movzx rdi, dl
        ; addrof t.28.1{r4}, moveTargets
        lea rcx, [var_3]
        ; add t.28.2{r4}, t.29.1{r1}
        add rcx, rdi
        ; store [t.28.2{r4}], target.2{r0}
        mov [rcx], al
        ; cast t.31.1{r1}(i64), target.2{r0}(u8)
        movzx rdi, al
        ; addrof t.30.1{r4}, tiles
        lea rcx, [var_1]
        ; add t.30.2{r4}, t.31.1{r1}
        add rcx, rdi
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; load tile.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; store [t.30.2{r4}], tile.1{r1}
        mov [rcx], dil
        ; 118:5 if target != source
        ; branch target.2{r0} equals source.2{r3}: if_27_end
        cmp al, dl
        je if_27_end
        ; const moved.6{r1}, 1
        mov dil, 1
        ; move moved.5{r2}, moved.6{r1}
        mov sil, dil
if_27_end:
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; load step{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; add target.7{r0}, step{r4}
        add al, cl
        ; const previousMerged.5{r1}, 0
        mov dil, 0
if_21_end:
        ; add source.4{r3}, step{r4}
        add dl, cl
        ; addrof memVarAddr{r9}, position.2
        lea r12, [rsp+36]
        ; load position.2{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        ; add position.5{r5}, 1
        add r8b, 1
for_20:
        ; branch position.2{r5} lt 4: for_20_body
        cmp r8b, 4
        jb for_20_body
        ; 127:9 return moved
        ; move moved.2{r0}, moved.2{r2}
        mov al, sil
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; bool _slide@u8
        ;   rsp+32: arg direction
        ;   rsp+33: var moved.2
        ;   rsp+34: var line.2
_slide@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move direction{r8}, direction{r1}
        mov bl, dil
        ; const index.1{r0}, 0
        mov al, 0
        ; 131:2 for index < 16
        jmp for_28
for_28_body:
        ; cast t.8.1{r1}(i64), index.2{r0}(u8)
        movzx rdi, al
        ; addrof t.7.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.7.2{r2}, t.8.1{r1}
        add rsi, rdi
        ; load t.6.1{r1}, [t.7.2{r2}]
        mov dil, [rsi]
        ; cast t.10.1{r2}(i64), index.2{r0}(u8)
        movzx rsi, al
        ; addrof t.9.1{r3}, moveTiles
        lea rdx, [var_2]
        ; add t.9.2{r3}, t.10.1{r2}
        add rdx, rsi
        ; store [t.9.2{r3}], t.6.1{r1}
        mov [rdx], dil
        ; move t.12.1{r1}, t.12.1{r2}
        mov rdi, rsi
        ; addrof t.11.1{r2}, moveTargets
        lea rsi, [var_3]
        ; add t.11.2{r2}, t.12.1{r1}
        add rsi, rdi
        ; store [t.11.2{r2}], index.2{r0}
        mov [rsi], al
        ; add index.3{r0}, 1
        add al, 1
for_28:
        ; branch index.2{r0} lt 16: for_28_body
        cmp al, 16
        jb for_28_body
        ; const moved.1{r0}, 0
        mov al, 0
        ; const line.1{r1}, 0
        mov dil, 0
        ; 136:2 for line < 4
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], moved.2{r0}
        mov [r12], al
        ; load moved.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp for_29
for_29_body:
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], moved.2{r0}
        mov [r12], al
        ; move line.2{r0}, line.2{r1}
        mov al, dil
        ; shiftleft first.1{r1}, 2
        shl dil, 2
        ; const step.1{r2}, 1
        mov sil, 1
        ; 139:3 if direction == 1
        ; branch direction{r8} equals 1: if_30_then
        cmp bl, 1
        je if_30_then
        ; branch direction{r8} notequals 2: if_31_else, if_31_then
        cmp bl, 2
        jne if_31_else
        jmp if_31_then
if_30_then:
        ; add first.2{r1}, 3
        add dil, 3
        ; const step.2{r2}, 255
        mov sil, 255
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp if_30_end
if_31_else:
        ; branch direction{r8} notequals 3: _slide@u8.no_critical_edge_17, if_32_then
        cmp bl, 3
        jne _slide@u8.no_critical_edge_17
        jmp if_32_then
if_31_then:
        ; move first.4{r1}, line.2{r0}
        mov dil, al
        ; const step.4{r2}, 4
        mov sil, 4
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp if_30_end
_slide@u8.no_critical_edge_17:
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp if_30_end
if_32_then:
        ; move first.5{r1}, line.2{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        ; add first.5{r1}, 12
        add dil, 12
        ; const step.5{r0}, 252
        mov al, 252
        ; move step.3{r2}, step.5{r0}
        mov sil, al
if_30_end:
        ; 151:3 if _slideLine@u8@u8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=151:16], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=151:23]])
        ; call t.13.1{r0} = _slideLine@u8@u8[first.3{r1}, step.3{r2}] -> bool
        call _slideLine@u8@u8
        ; branch t.13.1{r0} notequals 0: if_33_then
        cmp al, 0
        jne if_33_then
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; load moved.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp for_29_continue
if_33_then:
        ; const moved.5{r0}, 1
        mov al, 1
for_29_continue:
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; load line.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add line.5{r1}, 1
        add dil, 1
for_29:
        ; branch line.2{r1} lt 4: for_29_body
        cmp dil, 4
        jb for_29_body
        ; 155:9 return moved
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool _canMove
_canMove:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov al, 0
        ; 159:2 for index < 16
        jmp for_34
for_34_body:
        ; cast t.3.1{r1}(i64), index.2{r0}(u8)
        movzx rdi, al
        ; addrof t.2.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.2.2{r2}, t.3.1{r1}
        add rsi, rdi
        ; load tile.1{r1}, [t.2.2{r2}]
        mov dil, [rsi]
        ; 161:3 if tile == 0
        ; branch tile.1{r1} equals 0: if_35_then
        cmp dil, 0
        je if_35_then
        ; 164:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r2}, index.2{r0}
        mov sil, al
        ; and t.4.1{r2}, 3
        and sil, 3
        ; branch t.4.1{r2} equals 3: if_36_end
        cmp sil, 3
        je if_36_end
        ; move t.8.1{r2}, index.2{r0}
        mov sil, al
        ; add t.8.1{r2}, 1
        add sil, 1
        ; cast t.7.1{r2}(i64), t.8.1{r2}(u8)
        movzx rsi, sil
        ; addrof t.6.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.6.2{r3}, t.7.1{r2}
        add rdx, rsi
        ; load t.5.1{r2}, [t.6.2{r3}]
        mov sil, [rdx]
        ; branch t.5.1{r2} equals tile.1{r1}: if_36_then, if_36_end
        cmp sil, dil
        je if_36_then
if_36_end:
        ; branch index.2{r0} gteq 12: for_34_continue
        cmp al, 12
        jae for_34_continue
        ; move t.12.1{r2}, index.2{r0}
        mov sil, al
        ; add t.12.1{r2}, 4
        add sil, 4
        ; cast t.11.1{r2}(i64), t.12.1{r2}(u8)
        movzx rsi, sil
        ; addrof t.10.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.10.2{r3}, t.11.1{r2}
        add rdx, rsi
        ; load t.9.1{r2}, [t.10.2{r3}]
        mov sil, [rdx]
        ; branch t.9.1{r2} equals tile.1{r1}: if_38_then, for_34_continue
        cmp sil, dil
        je if_38_then
for_34_continue:
        ; add index.5{r0}, 1
        add al, 1
for_34:
        ; branch index.2{r0} lt 16: for_34_body
        cmp al, 16
        jb for_34_body
        ; const {r0}, 0
        mov al, 0
        jmp _canMove_ret
if_35_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
if_36_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
if_38_then:
        ; const {r0}, 1
        mov al, 1
_canMove_ret:
        add rsp, 8
        ret

        ; void _printTile@u8
        ;   rsp+24: arg exponent
_printTile@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move exponent{r8}, exponent{r1}
        mov bl, dil
        ; branch exponent{r8} equals 0: if_40_then
        cmp bl, 0
        je if_40_then
        ; branch exponent{r8} notequals 1: if_41_else, if_41_then
        cmp bl, 1
        jne if_41_else
        jmp if_41_then
if_40_then:
        ; const t.1.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call _printString@@u8[t.1.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_41_else:
        ; branch exponent{r8} notequals 2: if_42_else, if_42_then
        cmp bl, 2
        jne if_42_else
        jmp if_42_then
if_41_then:
        ; const t.2.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_42_else:
        ; branch exponent{r8} notequals 3: if_43_else, if_43_then
        cmp bl, 3
        jne if_43_else
        jmp if_43_then
if_42_then:
        ; const t.3.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_43_else:
        ; branch exponent{r8} notequals 4: if_44_else, if_44_then
        cmp bl, 4
        jne if_44_else
        jmp if_44_then
if_43_then:
        ; const t.4.1{r1}, [string-4]
        lea rdi, [string_4]
        ; call _printString@@u8[t.4.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_44_else:
        ; branch exponent{r8} notequals 5: if_45_else, if_45_then
        cmp bl, 5
        jne if_45_else
        jmp if_45_then
if_44_then:
        ; const t.5.1{r1}, [string-5]
        lea rdi, [string_5]
        ; call _printString@@u8[t.5.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_45_else:
        ; branch exponent{r8} notequals 6: if_46_else, if_46_then
        cmp bl, 6
        jne if_46_else
        jmp if_46_then
if_45_then:
        ; const t.6.1{r1}, [string-6]
        lea rdi, [string_6]
        ; call _printString@@u8[t.6.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_46_else:
        ; branch exponent{r8} notequals 7: if_47_else, if_47_then
        cmp bl, 7
        jne if_47_else
        jmp if_47_then
if_46_then:
        ; const t.7.1{r1}, [string-7]
        lea rdi, [string_7]
        ; call _printString@@u8[t.7.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_47_else:
        ; branch exponent{r8} notequals 8: if_48_else, if_48_then
        cmp bl, 8
        jne if_48_else
        jmp if_48_then
if_47_then:
        ; const t.8.1{r1}, [string-8]
        lea rdi, [string_8]
        ; call _printString@@u8[t.8.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_48_else:
        ; branch exponent{r8} notequals 9: if_49_else, if_49_then
        cmp bl, 9
        jne if_49_else
        jmp if_49_then
if_48_then:
        ; const t.9.1{r1}, [string-9]
        lea rdi, [string_9]
        ; call _printString@@u8[t.9.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_49_else:
        ; branch exponent{r8} notequals 10: if_50_else, if_50_then
        cmp bl, 10
        jne if_50_else
        jmp if_50_then
if_49_then:
        ; const t.10.1{r1}, [string-10]
        lea rdi, [string_10]
        ; call _printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_50_else:
        ; branch exponent{r8} notequals 11: if_51_else, if_51_then
        cmp bl, 11
        jne if_51_else
        jmp if_51_then
if_50_then:
        ; const t.11.1{r1}, [string-11]
        lea rdi, [string_11]
        ; call _printString@@u8[t.11.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_51_else:
        ; const t.13.1{r1}, [string-13]
        lea rdi, [string_13]
        ; call _printString@@u8[t.13.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_51_then:
        ; const t.12.1{r1}, [string-12]
        lea rdi, [string_12]
        ; call _printString@@u8[t.12.1{r1}]
        call _printString@@u8
_printTile@u8_ret:
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void _drawTileAt@i16@i16@u8
        ;   rsp+32: arg row
        ;   rsp+34: arg column
        ;   rsp+36: arg exponent
_drawTileAt@i16@i16@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move row{r8}, row{r1}
        mov bx, di
        ; move column{r0}, column{r2}
        mov ax, si
        ; branch exponent{r3} notequals 0: if_52_end, _drawTileAt@i16@i16@u8_ret
        cmp dl, 0
        jne if_52_end
        ; addrof memVarAddr{r9}, exponent
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], exponent{r3}
        mov [r12], dl
        jmp _drawTileAt@i16@i16@u8_ret
if_52_end:
        ; addrof memVarAddr{r9}, exponent
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], exponent{r3}
        mov [r12], dl
        ; move row{r1}, row{r8}
        mov di, bx
        ; move column{r2}, column{r0}
        mov si, ax
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r0}
        mov [r12], ax
        ; call _setCursor@i16@i16[row{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.3.1{r1}, [string-14]
        lea rdi, [string_14]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; move t.4.1{r1}, row{r8}
        mov di, bx
        ; add t.4.1{r1}, 1
        add di, 1
        ; load column{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move column{r2}, column{r0}
        mov si, ax
        ; call _setCursor@i16@i16[t.4.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const arg.3.0{r1}, 124
        mov dil, 124
        ; call _printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; addrof memVarAddr{r9}, exponent
        lea r12, [rsp+36]
        ; load exponent{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move exponent{r1}, exponent{r3}
        mov dil, dl
        ; call _printTile@u8[exponent{r1}]
        call _printTile@u8
        ; const arg.5.0{r1}, 124
        mov dil, 124
        ; call _printChar@u8[arg.5.0{r1}]
        call _printChar@u8
        ; move t.5.1{r1}, row{r8}
        mov di, bx
        ; add t.5.1{r1}, 2
        add di, 2
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call _setCursor@i16@i16[t.5.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.6.1{r1}, [string-14]
        lea rdi, [string_14]
        ; call _printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawTileAt@i16@i16@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; u8 _tileRow@u8
        ;   rsp+0: arg index
_tileRow@u8:
        sub rsp, 8
        ; 232:19 return index & 12 + 3
        ; move t.2.1{r0}, index{r1}
        mov al, dil
        ; and t.2.1{r0}, 12
        and al, 12
        ; add t.1.1{r0}, 3
        add al, 3
        add rsp, 8
        ret

        ; u8 _tileColumn@u8
        ;   rsp+0: arg index
_tileColumn@u8:
        sub rsp, 8
        ; move column.1{r0}, index{r1}
        mov al, dil
        ; and column.1{r0}, 3
        and al, 3
        ; 237:36 return column << 3 + 1 + column
        ; move t.4.1{r1}, column.1{r0}
        mov dil, al
        ; shiftleft t.4.1{r1}, 3
        shl dil, 3
        ; add t.3.1{r1}, 1
        add dil, 1
        ; add t.2.1{r1}, column.1{r0}
        add dil, al
        ; move t.2.1{r0}, t.2.1{r1}
        mov al, dil
        add rsp, 8
        ret

        ; void _clearTileTrail@u8@u8@u8@u8
        ;   rsp+32: arg row
        ;   rsp+33: arg column
        ;   rsp+34: arg direction
        ;   rsp+35: arg distance
        ;   rsp+36: var height.5
        ;   rsp+40: var spaces.2
        ;   rsp+48: var row.5
        ;   rsp+49: var line.2
_clearTileTrail@u8@u8@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const width.1{r0}, 8
        mov al, 8
        ; const height.1{r5}, 3
        mov r8b, 3
        ; 244:2 if direction < 2
        ; branch direction{r3} lt 2: if_53_then
        cmp dl, 2
        jb if_53_then
        ; branch distance{r4} gteq height.1{r5}: _clearTileTrail@u8@u8@u8@u8.no_critical_edge_14, if_56_end
        cmp cl, r8b
        jae _clearTileTrail@u8@u8@u8@u8.no_critical_edge_14
        jmp if_56_end
if_53_then:
        ; branch distance{r4} gteq width.1{r0}: if_54_end, if_54_then
        cmp cl, al
        jae if_54_end
        jmp if_54_then
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_14:
        ; move height.2{r4}, height.1{r5}
        mov cl, r8b
        jmp if_56_end
if_54_then:
        ; move width.4{r0}, distance{r4}
        mov al, cl
        jmp if_54_end
if_56_end:
        ; branch direction{r3} notequals 2: _clearTileTrail@u8@u8@u8@u8.no_critical_edge_15, if_57_then
        cmp dl, 2
        jne _clearTileTrail@u8@u8@u8@u8.no_critical_edge_15
        jmp if_57_then
if_54_end:
        ; branch direction{r3} notequals 0: _clearTileTrail@u8@u8@u8@u8.no_critical_edge_17, if_55_then
        cmp dl, 0
        jne _clearTileTrail@u8@u8@u8@u8.no_critical_edge_17
        jmp if_55_then
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_15:
        ; move column.3{r8}, column{r2}
        mov bl, sil
        ; move height.5{r2}, height.2{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, height.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], height.5{r2}
        mov [r12], sil
        jmp if_53_end
if_57_then:
        ; const t.11.1{r3}, 3
        mov dl, 3
        ; sub t.10.1{r3}, height.2{r4}
        sub dl, cl
        ; add row.4{r1}, t.10.1{r3}
        add dil, dl
        ; move column.3{r8}, column{r2}
        mov bl, sil
        ; move height.5{r2}, height.2{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, height.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], height.5{r2}
        mov [r12], sil
        jmp if_53_end
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_17:
        ; move column.3{r8}, column{r2}
        mov bl, sil
        ; move height.5{r2}, height.1{r5}
        mov sil, r8b
        ; addrof memVarAddr{r9}, height.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], height.5{r2}
        mov [r12], sil
        jmp if_53_end
if_55_then:
        ; const t.9.1{r3}, 8
        mov dl, 8
        ; sub t.8.1{r3}, width.3{r0}
        sub dl, al
        ; add column.4{r2}, t.8.1{r3}
        add sil, dl
        ; move column.3{r8}, column.4{r2}
        mov bl, sil
        ; move height.5{r2}, height.1{r5}
        mov sil, r8b
        ; addrof memVarAddr{r9}, height.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], height.5{r2}
        mov [r12], sil
if_53_end:
        ; const spaces.1{r2}, [string-15]
        lea rsi, [string_15]
        ; const t.14.1{r3}, 8
        mov dl, 8
        ; sub t.13.1{r3}, width.5{r0}
        sub dl, al
        ; cast t.12.1{r0}(i64), t.13.1{r3}(u8)
        movzx rax, dl
        ; add spaces.2{r2}, t.12.1{r0}
        add rsi, rax
        ; addrof memVarAddr{r9}, spaces.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], spaces.2{r2}
        mov [r12], rsi
        ; const line.1{r0}, 0
        mov al, 0
        ; 262:2 for line < height
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        ; move row.5{r0}, row.5{r1}
        mov al, dil
        ; load line.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        jmp for_58
for_58_body:
        ; addrof memVarAddr{r9}, height.5
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], height.5{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r9}], line.2{r1}
        mov [r12], dil
        ; move row.5{r1}, row.5{r0}
        mov dil, al
        ; cast t.15.1{r0}(i16), row.5{r1}(u8)
        movzx ax, dil
        ; addrof memVarAddr{r9}, row.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r9}], row.5{r1}
        mov [r12], dil
        ; cast t.16.1{r2}(i16), column.3{r8}(u8)
        movzx si, bl
        ; move t.15.1{r1}, t.15.1{r0}
        mov di, ax
        ; call _setCursor@i16@i16[t.15.1{r1}, t.16.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r9}, spaces.2
        lea r12, [rsp+40]
        ; load spaces.2{r0}, [memVarAddr{r9}]
        mov rax, [r12]
        ; move spaces.2{r1}, spaces.2{r0}
        mov rdi, rax
        ; call _printString@@u8[spaces.2{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, row.5
        lea r12, [rsp+48]
        ; load row.5{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add row.6{r0}, 1
        add al, 1
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+49]
        ; load line.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add line.3{r1}, 1
        add dil, 1
for_58:
        ; addrof memVarAddr{r9}, height.5
        lea r12, [rsp+36]
        ; load height.5{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; branch line.2{r1} lt height.5{r2}: for_58_body
        cmp dil, sil
        jb for_58_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; bool _drawMoveFrame@u8@u8@u8@bool
        ;   rsp+32: arg direction
        ;   rsp+33: arg previous
        ;   rsp+34: arg travel
        ;   rsp+35: arg erase
        ;   rsp+36: var horizontal.1
        ;   rsp+37: var forward.1
        ;   rsp+38: var count.2
        ;   rsp+39: var index.2
        ;   rsp+40: var exponent.1
        ;   rsp+41: var distance.4
        ;   rsp+42: var oldOffset.2
        ;   rsp+43: var pending.9
        ;   rsp+44: var offset.2
        ;   rsp+45: var row.3
        ;   rsp+46: var column.3
        ;   rsp+48: var t.52.1
_drawMoveFrame@u8@u8@u8@bool:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move direction{r8}, direction{r1}
        mov bl, dil
        ; lt horizontal.1{r0}, direction{r8}, 2
        cmp bl, 2
        setb al
        ; and t.17.1{r1}, 1
        and dil, 1
        ; notequals forward.1{r1}, t.17.1{r1}, 0
        cmp dil, 0
        setne dil
        ; const pending.1{r5}, 0
        mov r8b, 0
        ; const count.1{r6}, 0
        mov r9b, 0
        ; 276:2 for count < 16
        ; addrof memVarAddr{r9}, direction
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], direction{r8}
        mov [r12], bl
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], horizontal.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, previous
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], previous{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, travel
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], travel{r3}
        mov [r12], dl
        ; move count.2{r0}, count.2{r6}
        mov al, r9b
        ; move pending.2{r1}, pending.2{r5}
        mov dil, r8b
        jmp for_59
for_59_body:
        ; move count.2{r6}, count.2{r0}
        mov r9b, al
        ; addrof memVarAddr{r9}, direction
        lea r12, [rsp+32]
        ; load direction{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; load erase{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; load horizontal.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move pending.2{r5}, pending.2{r1}
        mov r8b, dil
        ; addrof memVarAddr{r9}, previous
        lea r12, [rsp+33]
        ; load previous{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, travel
        lea r12, [rsp+34]
        ; load travel{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; load forward.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move index.1{r7}, count.2{r6}
        mov r10b, r9b
        ; 278:3 if !forward
        ; branch forward.1{r1} equals 0: if_60_then
        cmp dil, 0
        je if_60_then
        ; addrof memVarAddr{r9}, count.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count.2{r6}
        mov [r12], r9b
        jmp if_60_end
if_60_then:
        ; const t.18.1{r7}, 15
        mov r10b, 15
        ; sub index.3{r7}, count.2{r6}
        sub r10b, r9b
        ; addrof memVarAddr{r9}, count.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], count.2{r6}
        mov [r12], r9b
if_60_end:
        ; cast t.20.1{r6}(i64), index.2{r7}(u8)
        movzx r9, r10b
        ; addrof memVarAddr{r9}, direction
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], direction{r8}
        mov [r12], bl
        ; addrof t.19.1{r8}, moveTiles
        lea rbx, [var_2]
        ; add t.19.2{r8}, t.20.1{r6}
        add rbx, r9
        ; load exponent.1{r6}, [t.19.2{r8}]
        mov r9b, [rbx]
        ; 283:3 if exponent == 0
        ; branch exponent.1{r6} notequals 0: if_61_end
        cmp r9b, 0
        jne if_61_end
        ; move pending.4{r8}, pending.2{r5}
        mov bl, r8b
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], horizontal.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, previous
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], previous{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, travel
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], travel{r3}
        mov [r12], dl
        jmp for_59_continue
if_61_end:
        ; cast t.23.1{r8}(i64), index.2{r7}(u8)
        movzx rbx, r10b
        ; addrof memVarAddr{r9}, exponent.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], exponent.1{r6}
        mov [r12], r9b
        ; addrof t.22.1{r6}, moveTargets
        lea r9, [var_3]
        ; add t.22.2{r6}, t.23.1{r8}
        add r9, rbx
        ; load t.21.1{r6}, [t.22.2{r6}]
        mov r9b, [r9]
        ; move target.1{r8}, t.21.1{r6}
        mov bl, r9b
        ; and target.1{r8}, 15
        and bl, 15
        ; move distance.1{r6}, index.2{r7}
        mov r9b, r10b
        ; sub distance.1{r6}, target.1{r8}
        sub r9b, bl
        ; 289:3 if forward
        ; branch forward.1{r1} equals 0: if_62_end
        cmp dil, 0
        je if_62_end
        ; move distance.3{r6}, target.1{r8}
        mov r9b, bl
        ; sub distance.3{r6}, index.2{r7}
        sub r9b, r10b
if_62_end:
        ; branch horizontal.1{r0} notequals 0: if_63_then
        cmp al, 0
        jne if_63_then
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], horizontal.1{r0}
        mov [r12], al
        jmp if_63_end
if_63_then:
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], horizontal.1{r0}
        mov [r12], al
        ; move t.24.1{r0}, distance.2{r6}
        mov al, r9b
        ; shiftleft t.24.1{r0}, 3
        shl al, 3
        ; add distance.5{r6}, t.24.1{r0}
        add r9b, al
if_63_end:
        ; move oldOffset.1{r0}, previous{r2}
        mov al, sil
        ; addrof memVarAddr{r9}, previous
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], previous{r2}
        mov [r12], sil
        ; 298:3 if oldOffset > distance
        ; branch oldOffset.1{r0} lteq distance.4{r6}: if_64_end
        cmp al, r9b
        jbe if_64_end
        ; move oldOffset.3{r0}, distance.4{r6}
        mov al, r9b
if_64_end:
        ; move offset.1{r2}, travel{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, travel
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], travel{r3}
        mov [r12], dl
        ; 304:3 if offset >= distance
        ; branch offset.1{r2} gteq distance.4{r6}: if_65_then
        cmp sil, r9b
        jae if_65_then
        ; const pending.8{r3}, 1
        mov dl, 1
        ; addrof memVarAddr{r9}, distance.4
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], distance.4{r6}
        mov [r12], r9b
        jmp if_65_end
if_65_then:
        ; move offset.3{r2}, distance.4{r6}
        mov sil, r9b
        ; addrof memVarAddr{r9}, distance.4
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], distance.4{r6}
        mov [r12], r9b
        ; move pending.9{r3}, pending.2{r5}
        mov dl, r8b
if_65_end:
        ; branch oldOffset.2{r0} equals offset.2{r2}: and_67
        cmp al, sil
        je and_67
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], pending.9{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, exponent.1
        lea r12, [rsp+40]
        ; load exponent.1{r6}, [memVarAddr{r9}]
        mov r9b, [r12]
        jmp if_66_end
and_67:
        ; branch erase{r4} equals 0: or_68
        cmp cl, 0
        je or_68
        ; move pending.4{r8}, pending.9{r3}
        mov bl, dl
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        jmp for_59_continue
or_68:
        ; cast t.27.1{r5}(i64), target.1{r8}(u8)
        movzx r8, bl
        ; addrof t.26.1{r6}, tiles
        lea r9, [var_1]
        ; add t.26.2{r6}, t.27.1{r5}
        add r9, r8
        ; load t.25.1{r5}, [t.26.2{r6}]
        mov r8b, [r9]
        ; addrof memVarAddr{r9}, exponent.1
        lea r12, [rsp+40]
        ; load exponent.1{r6}, [memVarAddr{r9}]
        mov r9b, [r12]
        ; branch exponent.1{r6} notequals t.25.1{r5}: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        cmp r9b, r8b
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        ; move pending.4{r8}, pending.9{r3}
        mov bl, dl
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        jmp for_59_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46:
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], pending.9{r3}
        mov [r12], dl
if_66_end:
        ; move displacement.1{r3}, offset.2{r2}
        mov dl, sil
        ; addrof memVarAddr{r9}, offset.2
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], offset.2{r2}
        mov [r12], sil
        ; 316:3 if erase
        ; branch erase{r4} notequals 0: if_69_then
        cmp cl, 0
        jne if_69_then
        ; addrof memVarAddr{r9}, oldOffset.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], oldOffset.2{r0}
        mov [r12], al
        jmp if_69_end
if_69_then:
        ; move displacement.3{r2}, oldOffset.2{r0}
        mov sil, al
        ; addrof memVarAddr{r9}, oldOffset.2
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], oldOffset.2{r0}
        mov [r12], al
if_69_end:
        ; branch forward.1{r1} notequals 0: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41, if_70_then
        cmp dil, 0
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        jmp if_70_then
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41:
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        ; move displacement.4{r0}, displacement.2{r2}
        mov al, sil
        jmp if_70_end
if_70_then:
        ; addrof memVarAddr{r9}, forward.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], forward.1{r1}
        mov [r12], dil
        ; const t.28.1{r0}, 0
        mov al, 0
        ; sub displacement.5{r0}, displacement.2{r2}
        sub al, sil
if_70_end:
        ; move t.29.1{r1}, index.2{r7}
        mov dil, r10b
        ; and t.29.1{r1}, 12
        and dil, 12
        ; add row.1{r1}, 3
        add dil, 3
        ; move column.1{r2}, index.2{r7}
        mov sil, r10b
        ; addrof memVarAddr{r9}, index.2
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], index.2{r7}
        mov [r12], r10b
        ; and column.1{r2}, 3
        and sil, 3
        ; move t.31.1{r3}, column.1{r2}
        mov dl, sil
        ; shiftleft t.31.1{r3}, 3
        shl dl, 3
        ; add t.30.1{r3}, 1
        add dl, 1
        ; add column.2{r2}, t.30.1{r3}
        add sil, dl
        ; 328:3 if horizontal
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; load horizontal.1{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; branch horizontal.1{r3} notequals 0: if_71_then
        cmp dl, 0
        jne if_71_then
        ; add row.2{r1}, displacement.4{r0}
        add dil, al
        jmp if_71_end
if_71_then:
        ; addrof memVarAddr{r9}, horizontal.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], horizontal.1{r3}
        mov [r12], dl
        ; add column.4{r2}, displacement.4{r0}
        add sil, al
if_71_end:
        ; branch erase{r4} equals 0: if_72_else, if_72_then
        cmp cl, 0
        je if_72_else
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        jmp if_72_then
if_72_else:
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        ; cast t.33.1{r1}(i16), row.3{r1}(u8)
        movzx di, dil
        ; cast t.34.1{r2}(i16), column.3{r2}(u8)
        movzx si, sil
        ; move exponent.1{r3}, exponent.1{r6}
        mov dl, r9b
        ; call _drawTileAt@i16@i16@u8[t.33.1{r1}, t.34.1{r2}, exponent.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; 340:4 if offset == distance
        ; addrof memVarAddr{r9}, distance.4
        lea r12, [rsp+41]
        ; load distance.4{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, offset.2
        lea r12, [rsp+44]
        ; load offset.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; branch offset.2{r0} notequals distance.4{r1}: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42, if_73_then
        cmp al, dil
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42
        jmp if_73_then
if_72_then:
        ; addrof memVarAddr{r9}, column.3
        lea r12, [rsp+46]
        ; store [memVarAddr{r9}], column.3{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, erase
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], erase{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, row.3
        lea r12, [rsp+45]
        ; store [memVarAddr{r9}], row.3{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, offset.2
        lea r12, [rsp+44]
        ; load offset.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.32.1{r4}, offset.2{r0}
        mov cl, al
        ; addrof memVarAddr{r9}, oldOffset.2
        lea r12, [rsp+42]
        ; load oldOffset.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; sub t.32.1{r4}, oldOffset.2{r0}
        sub cl, al
        ; addrof memVarAddr{r9}, direction
        lea r12, [rsp+32]
        ; load direction{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move direction{r3}, direction{r0}
        mov dl, al
        ; call _clearTileTrail@u8@u8@u8@u8[row.3{r1}, column.3{r2}, direction{r3}, t.32.1{r4}]
        call _clearTileTrail@u8@u8@u8@u8
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; load pending.9{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move pending.4{r8}, pending.9{r0}
        mov bl, al
        jmp for_59_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42:
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; load pending.9{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move pending.4{r8}, pending.9{r0}
        mov bl, al
        jmp for_59_continue
if_73_then:
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; load pending.9{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; 341:5 if [...] & 128 != 0
        ; addrof memVarAddr{r9}, index.2
        lea r12, [rsp+39]
        ; load index.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.38.1{r2}(i64), index.2{r1}(u8)
        movzx rsi, dil
        ; addrof t.37.1{r3}, moveTargets
        lea rdx, [var_3]
        ; add t.37.2{r3}, t.38.1{r2}
        add rdx, rsi
        ; load t.36.1{r2}, [t.37.2{r3}]
        mov sil, [rdx]
        ; and t.35.1{r2}, 128
        and sil, 128
        ; branch t.35.1{r2} notequals 0: if_74_then
        cmp sil, 0
        jne if_74_then
        ; 345:10 if [...] & 64 != 0
        ; cast t.51.1{r2}(i64), target.1{r8}(u8)
        movzx rsi, bl
        ; addrof t.50.1{r3}, moveTargets
        lea rdx, [var_3]
        ; add t.50.2{r3}, t.51.1{r2}
        add rdx, rsi
        ; load t.49.1{r2}, [t.50.2{r3}]
        mov sil, [rdx]
        ; and t.48.1{r2}, 64
        and sil, 64
        ; branch t.48.1{r2} equals 0: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_43, if_75_then
        cmp sil, 0
        je _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_43
        jmp if_75_then
if_74_then:
        ; cast t.42.1{r2}(i64), target.1{r8}(u8)
        movzx rsi, bl
        ; addrof t.41.1{r3}, moveTargets
        lea rdx, [var_3]
        ; add t.41.2{r3}, t.42.1{r2}
        add rdx, rsi
        ; load t.40.1{r2}, [t.41.2{r3}]
        mov sil, [rdx]
        ; or t.39.1{r2}, 64
        or sil, 64
        ; cast t.44.1{r3}(i64), target.1{r8}(u8)
        movzx rdx, bl
        ; addrof t.43.1{r4}, moveTargets
        lea rcx, [var_3]
        ; add t.43.2{r4}, t.44.1{r3}
        add rcx, rdx
        ; store [t.43.2{r4}], t.39.1{r2}
        mov [rcx], sil
        ; const t.45.1{r2}, 0
        mov sil, 0
        ; cast t.47.1{r1}(i64), index.2{r1}(u8)
        movzx rdi, dil
        ; addrof t.46.1{r3}, moveTiles
        lea rdx, [var_2]
        ; add t.46.2{r3}, t.47.1{r1}
        add rdx, rdi
        ; store [t.46.2{r3}], t.45.1{r2}
        mov [rdx], sil
        ; move pending.4{r8}, pending.9{r0}
        mov bl, al
        jmp for_59_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_43:
        ; move pending.4{r8}, pending.9{r0}
        mov bl, al
        jmp for_59_continue
if_75_then:
        ; addrof memVarAddr{r9}, index.2
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], index.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], pending.9{r0}
        mov [r12], al
        ; move target.1{r1}, target.1{r8}
        mov dil, bl
        ; call t.53.1{r0} = _tileRow@u8[target.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.52.1{r1}(i16), t.53.1{r0}(u8)
        movzx di, al
        ; addrof memVarAddr{r9}, t.52.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r9}], t.52.1{r1}
        mov [r12], di
        ; move target.1{r1}, target.1{r8}
        mov dil, bl
        ; call t.55.1{r0} = _tileColumn@u8[target.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.54.1{r2}(i16), t.55.1{r0}(u8)
        movzx si, al
        ; cast t.58.1{r0}(i64), target.1{r8}(u8)
        movzx rax, bl
        ; addrof t.57.1{r1}, tiles
        lea rdi, [var_1]
        ; add t.57.2{r1}, t.58.1{r0}
        add rdi, rax
        ; load t.56.1{r3}, [t.57.2{r1}]
        mov dl, [rdi]
        ; load t.52.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; call _drawTileAt@i16@i16@u8[t.52.1{r1}, t.54.1{r2}, t.56.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; const t.59.1{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r9}, index.2
        lea r12, [rsp+39]
        ; load index.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.61.1{r1}(i64), index.2{r1}(u8)
        movzx rdi, dil
        ; addrof t.60.1{r2}, moveTiles
        lea rsi, [var_2]
        ; add t.60.2{r2}, t.61.1{r1}
        add rsi, rdi
        ; store [t.60.2{r2}], t.59.1{r0}
        mov [rsi], al
        ; addrof memVarAddr{r9}, pending.9
        lea r12, [rsp+43]
        ; load pending.9{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move pending.4{r8}, pending.9{r0}
        mov bl, al
for_59_continue:
        ; addrof memVarAddr{r9}, count.2
        lea r12, [rsp+38]
        ; load count.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add count.5{r0}, 1
        add al, 1
        ; move pending.2{r1}, pending.4{r8}
        mov dil, bl
for_59:
        ; branch count.2{r0} lt 16: for_59_body
        cmp al, 16
        jb for_59_body
        ; 352:9 return pending
        ; move pending.2{r0}, pending.2{r1}
        mov al, dil
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void _animateMove@u8
        ;   rsp+32: arg direction
        ;   rsp+33: var pending.2
        ;   rsp+34: var previous.1
        ;   rsp+35: var travel.3
        ;   rsp+36: var speed.3
        ;   rsp+37: var pending.3
        ;   rsp+38: var target.1
        ;   rsp+40: var t.21.1
_animateMove@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move direction{r8}, direction{r1}
        mov bl, dil
        ; const travel.1{r0}, 0
        mov al, 0
        ; const speed.1{r1}, 1
        mov dil, 1
        ; const pending.1{r2}, 1
        mov sil, 1
        ; 361:2 while pending
        ; addrof memVarAddr{r9}, pending.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], pending.2{r2}
        mov [r12], sil
        jmp while_76
while_76_body:
        ; move previous.1{r3}, travel.2{r0}
        mov dl, al
        ; add travel.3{r0}, speed.2{r1}
        add al, dil
        ; add speed.3{r1}, 1
        add dil, 1
        ; addrof memVarAddr{r9}, speed.3
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], speed.3{r1}
        mov [r12], dil
        ; const t.7.1{r4}, 1
        mov cl, 1
        ; move direction{r1}, direction{r8}
        mov dil, bl
        ; move previous.1{r2}, previous.1{r3}
        mov sil, dl
        ; addrof memVarAddr{r9}, previous.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], previous.1{r3}
        mov [r12], dl
        ; move travel.3{r3}, travel.3{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, travel.3
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], travel.3{r0}
        mov [r12], al
        ; call _ = _drawMoveFrame@u8@u8@u8@bool[direction{r1}, previous.1{r2}, travel.3{r3}, t.7.1{r4}] -> bool
        call _drawMoveFrame@u8@u8@u8@bool
        ; const t.8.1{r4}, 0
        mov cl, 0
        ; move direction{r1}, direction{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, previous.1
        lea r12, [rsp+34]
        ; load previous.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, travel.3
        lea r12, [rsp+35]
        ; load travel.3{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move travel.3{r3}, travel.3{r0}
        mov dl, al
        ; call pending.3{r0} = _drawMoveFrame@u8@u8@u8@bool[direction{r1}, previous.1{r2}, travel.3{r3}, t.8.1{r4}] -> bool
        call _drawMoveFrame@u8@u8@u8@bool
        ; addrof memVarAddr{r9}, pending.3
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], pending.3{r0}
        mov [r12], al
        ; call _waitFrame[]
        call _waitFrame
        ; addrof memVarAddr{r9}, travel.3
        lea r12, [rsp+35]
        ; load travel.3{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move travel.2{r0}, travel.3{r3}
        mov al, dl
        ; addrof memVarAddr{r9}, speed.3
        lea r12, [rsp+36]
        ; load speed.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, pending.3
        lea r12, [rsp+37]
        ; load pending.3{r2}, [memVarAddr{r9}]
        mov sil, [r12]
while_76:
        ; branch pending.2{r2} notequals 0: while_76_body
        cmp sil, 0
        jne while_76_body
        ; const index.1{r0}, 0
        mov al, 0
        ; 371:2 for index < 16
        ; move index.2{r8}, index.1{r0}
        mov bl, al
        jmp for_77
for_77_body:
        ; cast t.11.1{r0}(i64), index.2{r8}(u8)
        movzx rax, bl
        ; addrof t.10.1{r1}, moveTargets
        lea rdi, [var_3]
        ; add t.10.2{r1}, t.11.1{r0}
        add rdi, rax
        ; load t.9.1{r0}, [t.10.2{r1}]
        mov al, [rdi]
        ; and target.1{r0}, 15
        and al, 15
        ; 373:3 if [...] != 0 && [...] != [...]
        ; cast t.14.1{r1}(i64), index.2{r8}(u8)
        movzx rdi, bl
        ; addrof t.13.1{r2}, moveTiles
        lea rsi, [var_2]
        ; add t.13.2{r2}, t.14.1{r1}
        add rsi, rdi
        ; load t.12.1{r1}, [t.13.2{r2}]
        mov dil, [rsi]
        ; branch t.12.1{r1} equals 0: for_77_continue
        cmp dil, 0
        je for_77_continue
        ; cast t.17.1{r1}(i64), index.2{r8}(u8)
        movzx rdi, bl
        ; addrof t.16.1{r2}, moveTiles
        lea rsi, [var_2]
        ; add t.16.2{r2}, t.17.1{r1}
        add rsi, rdi
        ; load t.15.1{r1}, [t.16.2{r2}]
        mov dil, [rsi]
        ; cast t.20.1{r2}(i64), target.1{r0}(u8)
        movzx rsi, al
        ; addrof t.19.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.19.2{r3}, t.20.1{r2}
        add rdx, rsi
        ; load t.18.1{r2}, [t.19.2{r3}]
        mov sil, [rdx]
        ; branch t.15.1{r1} equals t.18.1{r2}: for_77_continue
        cmp dil, sil
        je for_77_continue
        ; move target.1{r1}, target.1{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, target.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], target.1{r0}
        mov [r12], al
        ; call t.23.1{r0} = _tileRow@u8[target.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.22.1{r0}(i16), t.23.1{r0}(u8)
        movzx ax, al
        ; move t.21.1{r1}, t.22.1{r0}
        mov di, ax
        ; add t.21.1{r1}, 1
        add di, 1
        ; addrof memVarAddr{r9}, t.21.1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], t.21.1{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, target.1
        lea r12, [rsp+38]
        ; load target.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move target.1{r1}, target.1{r0}
        mov dil, al
        ; call t.26.1{r0} = _tileColumn@u8[target.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.25.1{r0}(i16), t.26.1{r0}(u8)
        movzx ax, al
        ; move t.24.1{r2}, t.25.1{r0}
        mov si, ax
        ; add t.24.1{r2}, 1
        add si, 1
        ; addrof memVarAddr{r9}, t.21.1
        lea r12, [rsp+40]
        ; load t.21.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; call _setCursor@i16@i16[t.21.1{r1}, t.24.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r9}, target.1
        lea r12, [rsp+38]
        ; load target.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.29.1{r0}(i64), target.1{r1}(u8)
        movzx rax, dil
        ; addrof t.28.1{r1}, tiles
        lea rdi, [var_1]
        ; add t.28.2{r1}, t.29.1{r0}
        add rdi, rax
        ; load t.27.1{r1}, [t.28.2{r1}]
        mov dil, [rdi]
        ; call _printTile@u8[t.27.1{r1}]
        call _printTile@u8
for_77_continue:
        ; move index.4{r0}, index.2{r8}
        mov al, bl
        ; add index.4{r0}, 1
        add al, 1
        ; move index.2{r8}, index.4{r0}
        mov bl, al
for_77:
        ; branch index.2{r8} lt 16: for_77_body
        cmp bl, 16
        jb for_77_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void _drawFrame
_drawFrame:
        sub rsp, 8
        ; const arg.0.0{r1}, 1
        mov di, 1
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-16]
        lea rdi, [string_16]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void _clearBoard
_clearBoard:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const row.1{r0}, 0
        mov ax, 0
        ; 413:2 for row < 15
        ; move row.2{r8}, row.1{r0}
        mov bx, ax
        jmp for_80
for_80_body:
        ; move t.1.1{r1}, row.2{r8}
        mov di, bx
        ; add t.1.1{r1}, 3
        add di, 3
        ; const arg.0.1{r2}, 1
        mov si, 1
        ; call _setCursor@i16@i16[t.1.1{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.2.1{r1}, [string-17]
        lea rdi, [string_17]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; move row.3{r0}, row.2{r8}
        mov ax, bx
        ; add row.3{r0}, 1
        add ax, 1
        ; move row.2{r8}, row.3{r0}
        mov bx, ax
for_80:
        ; branch row.2{r8} lt 15: for_80_body
        cmp bx, 15
        jl for_80_body
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void _drawBoard
        ;   rsp+32: var row.2
        ;   rsp+34: var boardRow.2
        ;   rsp+36: var column.2
        ;   rsp+38: var boardColumn.2
_drawBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call _clearBoard[]
        call _clearBoard
        ; const index.1{r0}, 0
        mov al, 0
        ; const row.1{r1}, 3
        mov di, 3
        ; const boardRow.1{r2}, 0
        mov sil, 0
        ; 423:2 for boardRow < 4
        ; move index.2{r8}, index.1{r0}
        mov bl, al
        ; move row.2{r0}, row.1{r1}
        mov ax, di
        ; move boardRow.2{r1}, boardRow.1{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, boardRow.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], boardRow.2{r1}
        mov [r12], dil
        ; move row.2{r1}, row.2{r0}
        mov di, ax
        jmp for_81
for_81_body:
        ; addrof memVarAddr{r9}, boardRow.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], boardRow.2{r2}
        mov [r12], sil
        ; move row.2{r0}, row.2{r1}
        mov ax, di
        ; const column.1{r1}, 1
        mov di, 1
        ; const boardColumn.1{r2}, 0
        mov sil, 0
        ; 425:3 for boardColumn < 4
        ; move column.2{r3}, column.1{r1}
        mov dx, di
        ; move boardColumn.2{r1}, boardColumn.1{r2}
        mov dil, sil
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], boardColumn.2{r1}
        mov [r12], dil
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], ax
        ; move column.2{r2}, column.2{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; move boardColumn.2{r3}, boardColumn.2{r1}
        mov dl, dil
        jmp for_82
for_82_body:
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], boardColumn.2{r3}
        mov [r12], dl
        ; move column.2{r3}, column.2{r2}
        mov dx, si
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.7.1{r1}(i64), index.3{r8}(u8)
        movzx rdi, bl
        ; addrof t.6.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rsi, rdi
        ; load t.5.1{r4}, [t.6.2{r2}]
        mov cl, [rsi]
        ; move row.2{r1}, row.2{r0}
        mov di, ax
        ; move column.2{r2}, column.2{r3}
        mov si, dx
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], column.2{r3}
        mov [r12], dx
        ; move t.5.1{r3}, t.5.1{r4}
        mov dl, cl
        ; call _drawTileAt@i16@i16@u8[row.2{r1}, column.2{r2}, t.5.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; move index.4{r0}, index.3{r8}
        mov al, bl
        ; add index.4{r0}, 1
        add al, 1
        ; load column.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move column.3{r1}, column.2{r2}
        mov di, si
        ; add column.3{r1}, 9
        add di, 9
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; load boardColumn.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; add boardColumn.3{r3}, 1
        add dl, 1
        ; move index.3{r8}, index.4{r0}
        mov bl, al
        ; move column.2{r2}, column.3{r1}
        mov si, di
for_82:
        ; branch boardColumn.2{r3} lt 4: for_82_body
        cmp dl, 4
        jb for_82_body
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move row.4{r0}, row.2{r1}
        mov ax, di
        ; add row.4{r0}, 4
        add ax, 4
        ; addrof memVarAddr{r9}, boardRow.2
        lea r12, [rsp+34]
        ; load boardRow.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add boardRow.4{r2}, 1
        add sil, 1
        ; move row.2{r1}, row.4{r0}
        mov di, ax
for_81:
        ; branch boardRow.2{r2} lt 4: for_81_body
        cmp sil, 4
        jb for_81_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _drawScore
_drawScore:
        sub rsp, 8
        ; const arg.0.0{r1}, 0
        mov di, 0
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-18]
        lea rdi, [string_18]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r0}, score
        lea rax, [var_4]
        ; load t.2.1{r1}, [a.1.1{r0}]
        mov edi, [rax]
        ; call _printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-19]
        lea rdi, [string_19]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void _drawStatus
_drawStatus:
        sub rsp, 8
        ; const arg.0.0{r1}, 19
        mov di, 19
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-20]
        lea rdi, [string_20]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 19
        mov di, 19
        ; const arg.2.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 445:2 if gameState == 1
        ; addrof a.1.1{r0}, gameState
        lea rax, [var_5]
        ; load t.2.1{r0}, [a.1.1{r0}]
        mov al, [rax]
        ; branch t.2.1{r0} equals 1: if_83_then
        cmp al, 1
        je if_83_then
        ; 448:7 if gameState == 2
        ; addrof a.4.1{r0}, gameState
        lea rax, [var_5]
        ; load t.5.1{r0}, [a.4.1{r0}]
        mov al, [rax]
        ; branch t.5.1{r0} notequals 2: _drawStatus_ret, if_84_then
        cmp al, 2
        jne _drawStatus_ret
        jmp if_84_then
if_83_then:
        ; const t.3.1{r1}, [string-21]
        lea rdi, [string_21]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
if_84_then:
        ; const t.6.1{r1}, [string-22]
        lea rdi, [string_22]
        ; call _printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawStatus_ret:
        add rsp, 8
        ret

        ; void _newGame
_newGame:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov al, 0
        ; 454:2 for index < 16
        jmp for_85
for_85_body:
        ; const t.1.1{r1}, 0
        mov dil, 0
        ; cast t.3.1{r2}(i64), index.2{r0}(u8)
        movzx rsi, al
        ; addrof t.2.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.2.2{r3}, t.3.1{r2}
        add rdx, rsi
        ; store [t.2.2{r3}], t.1.1{r1}
        mov [rdx], dil
        ; add index.3{r0}, 1
        add al, 1
for_85:
        ; branch index.2{r0} lt 16: for_85_body
        cmp al, 16
        jb for_85_body
        ; const t.4.1{r0}, 0
        mov eax, 0
        ; addrof a.5.1{r1}, score
        lea rdi, [var_4]
        ; store [a.5.1{r1}], t.4.1{r0}
        mov [rdi], eax
        ; call _drawScore[]
        call _drawScore
        ; const t.6.1{r0}, 0
        mov al, 0
        ; addrof a.7.1{r1}, gameState
        lea rdi, [var_5]
        ; store [a.7.1{r1}], t.6.1{r0}
        mov [rdi], al
        ; call _ = _spawnTile[] -> u8
        call _spawnTile
        ; call _ = _spawnTile[] -> u8
        call _spawnTile
        ; call _drawBoard[]
        call _drawBoard
        ; call _drawStatus[]
        call _drawStatus
        ; const arg.5.0{r1}, 21
        mov di, 21
        ; const arg.5.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.5.0{r1}, arg.5.1{r2}]
        call _setCursor@i16@i16
        add rsp, 8
        ret

        ; void _main
        ;   rsp+32: var t.12.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const t.3.1{r0}, 0
        mov eax, 0
        ; addrof a.4.1{r1}, __random__
        lea rdi, [var_0]
        ; store [a.4.1{r1}], t.3.1{r0}
        mov [rdi], eax
        ; addrof a.6.1{r1}, score
        lea rdi, [var_4]
        ; store [a.6.1{r1}], t.5.1{r0}
        mov [rdi], eax
        ; const t.7.1{r0}, 0
        mov al, 0
        ; addrof a.8.1{r1}, gameState
        lea rdi, [var_5]
        ; store [a.8.1{r1}], t.7.1{r0}
        mov [rdi], al
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call _initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call _drawFrame[]
        call _drawFrame
        ; call _newGame[]
        call _newGame
        ; 471:2 while true
        jmp while_86
if_87_end:
        ; branch key.1{r8} equals 114: if_88_then
        cmp bx, 114
        je if_88_then
        ; branch key.1{r8} equals 82: if_88_then
        cmp bx, 82
        je if_88_then
        ; 480:3 if gameState != 0
        ; addrof a.9.1{r0}, gameState
        lea rax, [var_5]
        ; load t.10.1{r0}, [a.9.1{r0}]
        mov al, [rax]
        ; branch t.10.1{r0} notequals 0: while_86
        cmp al, 0
        jne while_86
        ; branch key.1{r8} equals -8117: if_91_then, or_93
        cmp bx, -8117
        je if_91_then
        jmp or_93
if_88_then:
        ; call _newGame[]
        call _newGame
        jmp while_86
or_93:
        ; branch key.1{r8} equals 97: if_91_then
        cmp bx, 97
        je if_91_then
        ; branch key.1{r8} equals 65: if_91_then
        cmp bx, 65
        je if_91_then
        ; branch key.1{r8} equals -8115: if_94_then
        cmp bx, -8115
        je if_94_then
        ; branch key.1{r8} equals 100: if_94_then, or_95
        cmp bx, 100
        je if_94_then
        jmp or_95
if_91_then:
        ; const direction.2{r0}, 0
        mov al, 0
        ; move direction.3{r8}, direction.2{r0}
        mov bl, al
        jmp if_91_end
or_95:
        ; branch key.1{r8} equals 68: if_94_then
        cmp bx, 68
        je if_94_then
        ; branch key.1{r8} equals -8120: if_97_then
        cmp bx, -8120
        je if_97_then
        ; branch key.1{r8} equals 119: if_97_then, or_98
        cmp bx, 119
        je if_97_then
        jmp or_98
if_94_then:
        ; const direction.4{r0}, 1
        mov al, 1
        ; move direction.3{r8}, direction.4{r0}
        mov bl, al
        jmp if_91_end
or_98:
        ; branch key.1{r8} equals 87: if_97_then
        cmp bx, 87
        je if_97_then
        ; branch key.1{r8} equals -8112: if_100_then
        cmp bx, -8112
        je if_100_then
        ; branch key.1{r8} equals 115: if_100_then, or_101
        cmp bx, 115
        je if_100_then
        jmp or_101
if_97_then:
        ; const direction.5{r0}, 2
        mov al, 2
        ; move direction.3{r8}, direction.5{r0}
        mov bl, al
        jmp if_91_end
or_101:
        ; branch key.1{r8} notequals 83: while_86, if_100_then
        cmp bx, 83
        jne while_86
if_100_then:
        ; const direction.6{r0}, 3
        mov al, 3
        ; move direction.3{r8}, direction.6{r0}
        mov bl, al
if_91_end:
        ; 500:3 if !_slide@u8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=500:13]])
        ; move direction.3{r1}, direction.3{r8}
        mov dil, bl
        ; call t.11.1{r0} = _slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.11.1{r0} equals 0: while_86
        cmp al, 0
        je while_86
        ; move direction.3{r1}, direction.3{r8}
        mov dil, bl
        ; call _animateMove@u8[direction.3{r1}]
        call _animateMove@u8
        ; call spawned.1{r0} = _spawnTile[] -> u8
        call _spawnTile
        ; move spawned.1{r8}, spawned.1{r0}
        mov bl, al
        ; 506:3 if spawned != 255
        ; branch spawned.1{r8} equals 255: if_104_end
        cmp bl, 255
        je if_104_end
        ; move spawned.1{r1}, spawned.1{r8}
        mov dil, bl
        ; call t.13.1{r0} = _tileRow@u8[spawned.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.12.1{r1}(i16), t.13.1{r0}(u8)
        movzx di, al
        ; addrof memVarAddr{r9}, t.12.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], t.12.1{r1}
        mov [r12], di
        ; move spawned.1{r1}, spawned.1{r8}
        mov dil, bl
        ; call t.15.1{r0} = _tileColumn@u8[spawned.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.14.1{r2}(i16), t.15.1{r0}(u8)
        movzx si, al
        ; cast t.18.1{r0}(i64), spawned.1{r8}(u8)
        movzx rax, bl
        ; addrof t.17.1{r1}, tiles
        lea rdi, [var_1]
        ; add t.17.2{r1}, t.18.1{r0}
        add rdi, rax
        ; load t.16.1{r3}, [t.17.2{r1}]
        mov dl, [rdi]
        ; load t.12.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; call _drawTileAt@i16@i16@u8[t.12.1{r1}, t.14.1{r2}, t.16.1{r3}]
        call _drawTileAt@i16@i16@u8
if_104_end:
        ; 509:3 if gameState == 0 && !_canMove([])
        ; addrof a.19.1{r0}, gameState
        lea rax, [var_5]
        ; load t.20.1{r0}, [a.19.1{r0}]
        mov al, [rax]
        ; branch t.20.1{r0} notequals 0: if_105_end
        cmp al, 0
        jne if_105_end
        ; call t.21.1{r0} = _canMove[] -> bool
        call _canMove
        ; branch t.21.1{r0} notequals 0: if_105_end
        cmp al, 0
        jne if_105_end
        ; const t.22.1{r0}, 2
        mov al, 2
        ; addrof a.23.1{r1}, gameState
        lea rdi, [var_5]
        ; store [a.23.1{r1}], t.22.1{r0}
        mov [rdi], al
if_105_end:
        ; call _drawScore[]
        call _drawScore
        ; 513:3 if gameState != 0
        ; addrof a.24.1{r0}, gameState
        lea rax, [var_5]
        ; load t.25.1{r0}, [a.24.1{r0}]
        mov al, [rax]
        ; branch t.25.1{r0} equals 0: if_107_end
        cmp al, 0
        je if_107_end
        ; call _drawStatus[]
        call _drawStatus
if_107_end:
        ; const arg.13.0{r1}, 21
        mov di, 21
        ; const arg.13.1{r2}, 0
        mov si, 0
        ; call _setCursor@i16@i16[arg.13.0{r1}, arg.13.1{r2}]
        call _setCursor@i16@i16
while_86:
        ; call key.1{r0} = _getChar[] -> i16
        call _getChar
        ; move key.1{r8}, key.1{r0}
        mov bx, ax
        ; 473:3 if key == 27
        ; branch key.1{r8} notequals 27: if_87_end
        cmp bx, 27
        jne if_87_end
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
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

        ; void _waitFrame
_waitFrame:
        sub  rsp, 10h
        mov  qword [rsp], 0
        mov  qword [rsp+8], 25000000
        mov  rdi, rsp
        xor  esi, esi
        mov  eax, 35
        syscall
        add  rsp, 10h
        ret

segment readable writable
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: tiles[] (u8*/16)
        var_1 rb 16
        ; variable 2: moveTiles[] (u8*/16)
        var_2 rb 16
        ; variable 3: moveTargets[] (u8*/16)
        var_3 rb 16
        ; variable 4: score (i32/4)
        var_4 rb 4
        ; variable 5: gameState (u8/1)
        var_5 rb 1

segment readable
        string_0 db 0x1b, '[', 0x00
        string_1 db '      ', 0x00
        string_2 db '   2  ', 0x00
        string_3 db '   4  ', 0x00
        string_4 db '   8  ', 0x00
        string_5 db '  16  ', 0x00
        string_6 db '  32  ', 0x00
        string_7 db '  64  ', 0x00
        string_8 db '  128 ', 0x00
        string_9 db '  256 ', 0x00
        string_10 db '  512 ', 0x00
        string_11 db ' 1024 ', 0x00
        string_12 db ' 2048 ', 0x00
        string_13 db '  ?   ', 0x00
        string_14 db '+------+', 0x00
        string_15 db '        ', 0x00
        string_16 db 'Arrows/WASD  R restart  Esc quit', 0x00
        string_17 db '                                   ', 0x00
        string_18 db '2048  Score: ', 0x00
        string_19 db '          ', 0x00
        string_20 db '                                      ', 0x00
        string_21 db '2048! Press R to play again.', 0x00
        string_22 db 'No moves left. Press R to restart.', 0x00

