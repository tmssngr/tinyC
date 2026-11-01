format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; i16 getChar
_getChar:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        jmp _while_1
_if_2_end:
        ; call c.2{r0} = __getChar[] -> i16
        call ___getChar
        ; move c.2{r8}, c.2{r0}
        mov bx, ax
        ; 37:3 if c == 27
        ; branch c.2{r8} equals 27: if_3_then
        cmp bx, 27
        je _if_3_then
        ; branch c.2{r8} notequals 91: while_1
        cmp bx, 91
        jne _while_1
        ; call c.3{r0} = __getChar[] -> i16
        call ___getChar
        ; 45:3 if c == 65
        ; branch c.3{r0} equals 65: if_5_then
        cmp ax, 65
        je _if_5_then
        ; branch c.3{r0} equals 66: if_6_then
        cmp ax, 66
        je _if_6_then
        ; branch c.3{r0} equals 67: if_7_then
        cmp ax, 67
        je _if_7_then
        ; branch c.3{r0} equals 68: if_8_then, while_1
        cmp ax, 68
        je _if_8_then
_while_1:
        ; call c.1{r0} = __getChar[] -> i16
        call ___getChar
        ; 32:3 if c != 27
        ; branch c.1{r0} equals 27: if_2_end
        cmp ax, 27
        je _if_2_end
        ; 33:11 return c
        jmp _getChar_ret
_if_3_then:
        ; 38:11 return c
        ; move c.2{r0}, c.2{r8}
        mov ax, bx
        jmp _getChar_ret
_if_5_then:
        ; const {r0}, -8120
        mov ax, -8120
        jmp _getChar_ret
_if_6_then:
        ; const {r0}, -8112
        mov ax, -8112
        jmp _getChar_ret
_if_7_then:
        ; const {r0}, -8115
        mov ax, -8115
        jmp _getChar_ret
_if_8_then:
        ; const {r0}, -8117
        mov ax, -8117
_getChar_ret:
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void setCursor@i16@i16
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
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; move row{r1}, row{r8}
        mov di, bx
        ; call printUint@i16[row{r1}]
        call _printUint@i16
        ; const arg.2.0{r1}, 59
        mov dil, 59
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; move column{r1}, column{r9}
        mov di, r12w
        ; call printUint@i16[column{r1}]
        call _printUint@i16
        ; const arg.4.0{r1}, 72
        mov dil, 72
        ; call printChar@u8[arg.4.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

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

        ; void printUint@i32
        ;   rsp+0: arg number
_printUint@i32:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i32)
        movsxd rdi, edi
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
_while_9:
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
        ; branch number.2{r5} notequals 0: while_9
        cmp r8, 0
        jne _while_9
        ; addrof t.8.1{r3}, buffer
        lea rdx, [rsp+40]
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
        ; 73:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rsi
        jmp _for_11
_for_11_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_11:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_11_body
        cmp sil, 0
        jne _for_11_body
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

        ; i16 tileValue@u8
        ;   rsp+0: arg exponent
_tileValue@u8:
        sub rsp, 8
        ; const value.1{r2}, 1
        mov si, 1
        ; const index.1{r3}, 0
        mov dl, 0
        ; 40:2 for index < exponent
        ; move value.2{r0}, value.1{r2}
        mov ax, si
        ; move index.2{r2}, index.1{r3}
        mov sil, dl
        jmp _for_12
_for_12_body:
        ; move value.3{r3}, value.2{r0}
        mov dx, ax
        ; shiftleft value.3{r3}, 1
        sal dx, 1
        ; add index.3{r2}, 1
        add sil, 1
        ; move value.2{r0}, value.3{r3}
        mov ax, dx
_for_12:
        ; branch index.2{r2} lt exponent{r1}: for_12_body
        cmp sil, dil
        jb _for_12_body
        ; 43:9 return value
        add rsp, 8
        ret

        ; void spawnTile
        ;   rsp+32: var index.4
_spawnTile:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const emptyCount.1{r8}, 0
        mov bl, 0
        ; const index.1{r0}, 0
        mov al, 0
        ; 48:2 for index < 16
        jmp _for_13
_for_13_body:
        ; 49:3 if [...] == 0
        ; cast t.7.1{r1}(i64), index.2{r0}(u8)
        movzx rdi, al
        ; addrof t.6.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rsi, rdi
        ; load t.5.1{r1}, [t.6.2{r2}]
        mov dil, [rsi]
        ; branch t.5.1{r1} notequals 0: for_13_continue
        cmp dil, 0
        jne _for_13_continue
        ; add emptyCount.4{r8}, 1
        add bl, 1
_for_13_continue:
        ; add index.6{r0}, 1
        add al, 1
_for_13:
        ; branch index.2{r0} lt 16: for_13_body
        cmp al, 16
        jb _for_13_body
        ; branch emptyCount.2{r8} equals 0: spawnTile_ret
        cmp bl, 0
        je _spawnTile_ret
        ; call t.9.1{r0} = random16[] -> i16
        call _random16
        ; cast t.10.1{r8}(i16), emptyCount.2{r8}(u8)
        movzx bx, bl
        ; mod t.8.1{r3}, t.8.1{r0}, t.10.1{r8}
        movsx rax, ax
        movsx rbx, bx
        cqo
        idiv rbx
        ; move t.8.1{r1}, t.8.1{r3}
        mov di, dx
        ; cast chosen.1{r8}(u8), t.8.1{r1}(i16)
        mov bl, dil
        ; const index.3{r0}, 0
        mov al, 0
        ; 58:2 for index < 16
        jmp _for_16
_for_16_body:
        ; 59:3 if [...] != 0
        ; cast t.13.1{r1}(i64), index.4{r0}(u8)
        movzx rdi, al
        ; addrof t.12.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.12.2{r2}, t.13.1{r1}
        add rsi, rdi
        ; load t.11.1{r1}, [t.12.2{r2}]
        mov dil, [rsi]
        ; branch t.11.1{r1} notequals 0: for_16_continue
        cmp dil, 0
        jne _for_16_continue
        ; branch chosen.2{r8} equals 0: if_18_then
        cmp bl, 0
        je _if_18_then
        ; sub chosen.4{r8}, 1
        sub bl, 1
_for_16_continue:
        ; add index.8{r0}, 1
        add al, 1
_for_16:
        ; branch index.4{r0} gteq 16: spawnTile_ret, for_16_body
        cmp al, 16
        jae _spawnTile_ret
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], index.4{r0}
        mov [r12], al
        jmp _for_16_body
_if_18_then:
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], index.4{r0}
        mov [r12], al
        ; const tile.1{r8}, 1
        mov bl, 1
        ; 64:4 if random16([]) % 10 == 0
        ; call t.15.1{r0} = random16[] -> i16
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
        je _if_19_then
        ; move tile.2{r0}, tile.1{r8}
        mov al, bl
        jmp _if_19_end
_if_19_then:
        ; const tile.3{r0}, 2
        mov al, 2
_if_19_end:
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+32]
        ; load index.4{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.17.1{r1}(i64), index.4{r1}(u8)
        movzx rdi, dil
        ; addrof t.16.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.16.2{r2}, t.17.1{r1}
        add rsi, rdi
        ; store [t.16.2{r2}], tile.2{r0}
        mov [rsi], al
        ; 68:4 return
_spawnTile_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool slideLine@u8@u8
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
        ; const previousMerged.1{r4}, 0
        mov cl, 0
        ; const moved.1{r5}, 0
        mov r8b, 0
        ; const position.1{r6}, 0
        mov r9b, 0
        ; 79:2 for position < 4
        ; addrof memVarAddr{r9}, position.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], position.2{r6}
        mov [r12], r9b
        ; move moved.2{r3}, moved.2{r5}
        mov dl, r8b
        ; move step{r5}, step{r2}
        mov r8b, sil
        ; move previousMerged.2{r2}, previousMerged.2{r4}
        mov sil, cl
        ; move source.2{r4}, source.2{r0}
        mov cl, al
        ; move moved.2{r0}, moved.2{r3}
        mov al, dl
        jmp _for_20
_for_20_body:
        ; addrof memVarAddr{r9}, position.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], position.2{r6}
        mov [r12], r9b
        ; move target.2{r3}, target.2{r1}
        mov dl, dil
        ; move moved.2{r1}, moved.2{r0}
        mov dil, al
        ; move source.2{r0}, source.2{r4}
        mov al, cl
        ; move previousMerged.2{r4}, previousMerged.2{r2}
        mov cl, sil
        ; move step{r2}, step{r5}
        mov sil, r8b
        ; move moved.2{r5}, moved.2{r1}
        mov r8b, dil
        ; cast t.14.1{r6}(i64), source.2{r0}(u8)
        movzx r9, al
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof sourceTile.1{r0}, tiles
        lea rax, [var_1]
        ; add sourceTile.2{r0}, t.14.1{r6}
        add rax, r9
        ; load tile.1{r6}, [sourceTile.2{r0}]
        mov r9b, [rax]
        ; 82:3 if tile != 0
        ; branch tile.1{r6} notequals 0: if_21_then
        cmp r9b, 0
        jne _if_21_then
        ; move target.3{r0}, target.2{r3}
        mov al, dl
        ; addrof memVarAddr{r9}, target.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], target.3{r0}
        mov [r12], al
        ; move previousMerged.3{r0}, previousMerged.2{r4}
        mov al, cl
        ; addrof memVarAddr{r9}, previousMerged.3
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], previousMerged.3{r0}
        mov [r12], al
        ; move moved.3{r0}, moved.2{r5}
        mov al, r8b
        ; addrof memVarAddr{r9}, moved.3
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], moved.3{r0}
        mov [r12], al
        ; move moved.3{r3}, moved.3{r1}
        mov dl, dil
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move step{r5}, step{r2}
        mov r8b, sil
        ; addrof memVarAddr{r9}, target.3
        lea r12, [rsp+38]
        ; load target.3{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, previousMerged.3
        lea r12, [rsp+39]
        ; load previousMerged.3{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        jmp _if_21_end
_if_21_then:
        ; const t.15.1{r7}, 0
        mov r10b, 0
        ; store [sourceTile.2{r0}], t.15.1{r7}
        mov [rax], r10b
        ; const merged.1{r0}, 0
        mov al, 0
        ; 85:4 if target != first && !previousMerged
        ; branch target.2{r3} notequals first{r8}: and_23
        cmp dl, bl
        jne _and_23
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; move merged.2{r1}, merged.2{r0}
        mov dil, al
        ; move moved.4{r3}, moved.4{r5}
        mov dl, r8b
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov sil, cl
        jmp _if_22_end
_and_23:
        ; branch previousMerged.2{r4} equals 0: if_22_then
        cmp cl, 0
        je _if_22_then
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; move merged.2{r1}, merged.2{r0}
        mov dil, al
        ; move moved.4{r3}, moved.4{r5}
        mov dl, r8b
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov sil, cl
        jmp _if_22_end
_if_22_then:
        ; move previous.1{r7}, target.2{r3}
        mov r10b, dl
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r3}
        mov [r12], dl
        ; sub previous.1{r7}, step{r2}
        sub r10b, sil
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; cast t.16.1{r2}(i64), previous.1{r7}(u8)
        movzx rsi, r10b
        ; addrof previousTile.1{r3}, tiles
        lea rdx, [var_1]
        ; add previousTile.2{r3}, t.16.1{r2}
        add rdx, rsi
        ; 88:5 if *previousTile == tile
        ; load t.17.1{r2}, [previousTile.2{r3}]
        mov sil, [rdx]
        ; branch t.17.1{r2} equals tile.1{r6}: if_24_then
        cmp sil, r9b
        je _if_24_then
        ; addrof memVarAddr{r9}, previousMerged.4
        lea r12, [rsp+41]
        ; store [memVarAddr{r9}], previousMerged.4{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, moved.4
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], moved.4{r5}
        mov [r12], r8b
        ; addrof memVarAddr{r9}, merged.2
        lea r12, [rsp+43]
        ; store [memVarAddr{r9}], merged.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; move merged.2{r1}, merged.2{r0}
        mov dil, al
        ; move moved.4{r3}, moved.4{r5}
        mov dl, r8b
        ; addrof memVarAddr{r9}, previousMerged.4
        lea r12, [rsp+41]
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov sil, cl
        jmp _if_22_end
_if_24_then:
        ; move nextTile.1{r1}, tile.1{r6}
        mov dil, r9b
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; add nextTile.1{r1}, 1
        add dil, 1
        ; store [previousTile.2{r3}], nextTile.1{r1}
        mov [rdx], dil
        ; addrof memVarAddr{r9}, nextTile.1
        lea r12, [rsp+44]
        ; store [memVarAddr{r9}], nextTile.1{r1}
        mov [r12], dil
        ; call t.18.1{r0} = tileValue@u8[nextTile.1{r1}] -> i16
        call _tileValue@u8
        ; cast mergedScore.1{r1}(i32), t.18.1{r0}(i16)
        movsx edi, ax
        ; addrof a.20.1{r2}, score
        lea rsi, [var_2]
        ; load t.21.1{r2}, [a.20.1{r2}]
        mov esi, [rsi]
        ; add t.19.1{r2}, mergedScore.1{r1}
        add esi, edi
        ; addrof a.22.1{r1}, score
        lea rdi, [var_2]
        ; store [a.22.1{r1}], t.19.1{r2}
        mov [rdi], esi
        ; 93:6 if nextTile == 11
        ; load nextTile.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch nextTile.1{r1} notequals 11: if_25_end
        cmp dil, 11
        jne _if_25_end
        ; const t.23.1{r1}, 1
        mov dil, 1
        ; addrof a.24.1{r2}, gameState
        lea rsi, [var_3]
        ; store [a.24.1{r2}], t.23.1{r1}
        mov [rsi], dil
_if_25_end:
        ; const merged.3{r1}, 1
        mov dil, 1
        ; const previousMerged.6{r2}, 1
        mov sil, 1
        ; const moved.7{r3}, 1
        mov dl, 1
_if_22_end:
        ; branch merged.2{r1} equals 0: if_26_then
        cmp dil, 0
        je _if_26_then
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; load target.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; load step{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        jmp _if_21_end
_if_26_then:
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; load target.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; cast t.26.1{r2}(i64), target.2{r1}(u8)
        movzx rsi, dil
        ; addrof t.25.1{r4}, tiles
        lea rcx, [var_1]
        ; add t.25.2{r4}, t.26.1{r2}
        add rcx, rsi
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; load tile.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; store [t.25.2{r4}], tile.1{r2}
        mov [rcx], sil
        ; 103:5 if target != source
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; branch target.2{r1} equals source.2{r4}: if_27_end
        cmp dil, cl
        je _if_27_end
        ; const moved.6{r2}, 1
        mov sil, 1
        ; move moved.5{r3}, moved.6{r2}
        mov dl, sil
_if_27_end:
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; load step{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        ; add target.7{r1}, step{r5}
        add dil, r8b
        ; const previousMerged.5{r2}, 0
        mov sil, 0
_if_21_end:
        ; add source.4{r4}, step{r5}
        add cl, r8b
        ; addrof memVarAddr{r9}, position.2
        lea r12, [rsp+36]
        ; load position.2{r6}, [memVarAddr{r9}]
        mov r9b, [r12]
        ; add position.5{r6}, 1
        add r9b, 1
        ; move moved.2{r0}, moved.3{r3}
        mov al, dl
_for_20:
        ; branch position.2{r6} lt 4: for_20_body
        cmp r9b, 4
        jb _for_20_body
        ; 112:9 return moved
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; bool slide@u8
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
        ; const moved.1{r0}, 0
        mov al, 0
        ; const line.1{r3}, 0
        mov dl, 0
        ; 117:2 for line < 4
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], moved.2{r0}
        mov [r12], al
        ; move line.2{r0}, line.1{r3}
        mov al, dl
        ; move line.2{r2}, line.2{r0}
        mov sil, al
        ; load moved.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        jmp _for_28
_for_28_body:
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], moved.2{r0}
        mov [r12], al
        ; move line.2{r0}, line.2{r2}
        mov al, sil
        ; move first.1{r3}, line.2{r0}
        mov dl, al
        ; shiftleft first.1{r3}, 2
        shl dl, 2
        ; const step.1{r4}, 1
        mov cl, 1
        ; 120:3 if direction == 1
        ; branch direction{r8} equals 1: if_29_then
        cmp bl, 1
        je _if_29_then
        ; branch direction{r8} notequals 2: if_30_else, if_30_then
        cmp bl, 2
        jne _if_30_else
        jmp _if_30_then
_if_29_then:
        ; add first.2{r3}, 3
        add dl, 3
        ; const step.2{r4}, 255
        mov cl, 255
        ; move first.3{r1}, first.2{r3}
        mov dil, dl
        ; move step.3{r2}, step.2{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp _if_29_end
_if_30_else:
        ; branch direction{r8} notequals 3: slide@u8.no_critical_edge_13, if_31_then
        cmp bl, 3
        jne _slide@u8.no_critical_edge_13
        jmp _if_31_then
_if_30_then:
        ; move first.4{r3}, line.2{r0}
        mov dl, al
        ; const step.4{r4}, 4
        mov cl, 4
        ; move first.3{r1}, first.4{r3}
        mov dil, dl
        ; move step.3{r2}, step.4{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp _if_29_end
_slide@u8.no_critical_edge_13:
        ; move first.3{r1}, first.1{r3}
        mov dil, dl
        ; move step.3{r2}, step.1{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp _if_29_end
_if_31_then:
        ; move first.5{r3}, line.2{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        ; add first.5{r3}, 12
        add dl, 12
        ; const step.5{r0}, 252
        mov al, 252
        ; move first.3{r1}, first.5{r3}
        mov dil, dl
        ; move step.3{r2}, step.5{r0}
        mov sil, al
_if_29_end:
        ; 132:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=3, scope=function, type=u8, varIsArray=false, location=132:16], ExprVarAccess[varName=step, index=4, scope=function, type=u8, varIsArray=false, location=132:23]])
        ; call t.5.1{r0} = slideLine@u8@u8[first.3{r1}, step.3{r2}] -> bool
        call _slideLine@u8@u8
        ; branch t.5.1{r0} notequals 0: if_32_then
        cmp al, 0
        jne _if_32_then
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; load moved.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move moved.4{r1}, moved.2{r0}
        mov dil, al
        jmp _for_28_continue
_if_32_then:
        ; const moved.5{r1}, 1
        mov dil, 1
_for_28_continue:
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; load line.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add line.5{r2}, 1
        add sil, 1
        ; move moved.2{r0}, moved.4{r1}
        mov al, dil
_for_28:
        ; branch line.2{r2} lt 4: for_28_body
        cmp sil, 4
        jb _for_28_body
        ; 136:9 return moved
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; bool canMove
_canMove:
        sub rsp, 8
        ; const index.1{r1}, 0
        mov dil, 0
        ; 140:2 for index < 16
        jmp _for_33
_for_33_body:
        ; cast t.3.1{r2}(i64), index.2{r1}(u8)
        movzx rsi, dil
        ; addrof t.2.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.2.2{r3}, t.3.1{r2}
        add rdx, rsi
        ; load tile.1{r2}, [t.2.2{r3}]
        mov sil, [rdx]
        ; 142:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_34_then
        cmp sil, 0
        je _if_34_then
        ; 145:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r3}, index.2{r1}
        mov dl, dil
        ; and t.4.1{r3}, 3
        and dl, 3
        ; branch t.4.1{r3} equals 3: if_35_end
        cmp dl, 3
        je _if_35_end
        ; move t.8.1{r3}, index.2{r1}
        mov dl, dil
        ; add t.8.1{r3}, 1
        add dl, 1
        ; cast t.7.1{r3}(i64), t.8.1{r3}(u8)
        movzx rdx, dl
        ; addrof t.6.1{r4}, tiles
        lea rcx, [var_1]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; load t.5.1{r3}, [t.6.2{r4}]
        mov dl, [rcx]
        ; branch t.5.1{r3} equals tile.1{r2}: if_35_then, if_35_end
        cmp dl, sil
        je _if_35_then
_if_35_end:
        ; branch index.2{r1} gteq 12: for_33_continue
        cmp dil, 12
        jae _for_33_continue
        ; move t.12.1{r3}, index.2{r1}
        mov dl, dil
        ; add t.12.1{r3}, 4
        add dl, 4
        ; cast t.11.1{r3}(i64), t.12.1{r3}(u8)
        movzx rdx, dl
        ; addrof t.10.1{r4}, tiles
        lea rcx, [var_1]
        ; add t.10.2{r4}, t.11.1{r3}
        add rcx, rdx
        ; load t.9.1{r3}, [t.10.2{r4}]
        mov dl, [rcx]
        ; branch t.9.1{r3} equals tile.1{r2}: if_37_then, for_33_continue
        cmp dl, sil
        je _if_37_then
_for_33_continue:
        ; add index.5{r1}, 1
        add dil, 1
_for_33:
        ; branch index.2{r1} lt 16: for_33_body
        cmp dil, 16
        jb _for_33_body
        ; const {r0}, 0
        mov al, 0
        jmp _canMove_ret
_if_34_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
_if_35_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
_if_37_then:
        ; const {r0}, 1
        mov al, 1
_canMove_ret:
        add rsp, 8
        ret

        ; void printTile@u8
        ;   rsp+24: arg exponent
_printTile@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move exponent{r8}, exponent{r1}
        mov bl, dil
        ; branch exponent{r8} equals 0: if_39_then
        cmp bl, 0
        je _if_39_then
        ; branch exponent{r8} notequals 1: if_40_else, if_40_then
        cmp bl, 1
        jne _if_40_else
        jmp _if_40_then
_if_39_then:
        ; const t.1.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.1.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_40_else:
        ; branch exponent{r8} notequals 2: if_41_else, if_41_then
        cmp bl, 2
        jne _if_41_else
        jmp _if_41_then
_if_40_then:
        ; const t.2.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_41_else:
        ; branch exponent{r8} notequals 3: if_42_else, if_42_then
        cmp bl, 3
        jne _if_42_else
        jmp _if_42_then
_if_41_then:
        ; const t.3.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_42_else:
        ; branch exponent{r8} notequals 4: if_43_else, if_43_then
        cmp bl, 4
        jne _if_43_else
        jmp _if_43_then
_if_42_then:
        ; const t.4.1{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString@@u8[t.4.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_43_else:
        ; branch exponent{r8} notequals 5: if_44_else, if_44_then
        cmp bl, 5
        jne _if_44_else
        jmp _if_44_then
_if_43_then:
        ; const t.5.1{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString@@u8[t.5.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_44_else:
        ; branch exponent{r8} notequals 6: if_45_else, if_45_then
        cmp bl, 6
        jne _if_45_else
        jmp _if_45_then
_if_44_then:
        ; const t.6.1{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_45_else:
        ; branch exponent{r8} notequals 7: if_46_else, if_46_then
        cmp bl, 7
        jne _if_46_else
        jmp _if_46_then
_if_45_then:
        ; const t.7.1{r1}, [string-7]
        lea rdi, [string_7]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_46_else:
        ; branch exponent{r8} notequals 8: if_47_else, if_47_then
        cmp bl, 8
        jne _if_47_else
        jmp _if_47_then
_if_46_then:
        ; const t.8.1{r1}, [string-8]
        lea rdi, [string_8]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_47_else:
        ; branch exponent{r8} notequals 9: if_48_else, if_48_then
        cmp bl, 9
        jne _if_48_else
        jmp _if_48_then
_if_47_then:
        ; const t.9.1{r1}, [string-9]
        lea rdi, [string_9]
        ; call printString@@u8[t.9.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_48_else:
        ; branch exponent{r8} notequals 10: if_49_else, if_49_then
        cmp bl, 10
        jne _if_49_else
        jmp _if_49_then
_if_48_then:
        ; const t.10.1{r1}, [string-10]
        lea rdi, [string_10]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_49_else:
        ; branch exponent{r8} notequals 11: if_50_else, if_50_then
        cmp bl, 11
        jne _if_50_else
        jmp _if_50_then
_if_49_then:
        ; const t.11.1{r1}, [string-11]
        lea rdi, [string_11]
        ; call printString@@u8[t.11.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_50_else:
        ; const t.13.1{r1}, [string-13]
        lea rdi, [string_13]
        ; call printString@@u8[t.13.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_50_then:
        ; const t.12.1{r1}, [string-12]
        lea rdi, [string_12]
        ; call printString@@u8[t.12.1{r1}]
        call _printString@@u8
_printTile@u8_ret:
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void drawTileAt@i16@i16@u8
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
        ; branch exponent{r3} notequals 0: if_51_end, drawTileAt@i16@i16@u8_ret
        cmp dl, 0
        jne _if_51_end
        ; addrof memVarAddr{r9}, exponent
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], exponent{r3}
        mov [r12], dl
        jmp _drawTileAt@i16@i16@u8_ret
_if_51_end:
        ; addrof memVarAddr{r9}, exponent
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], exponent{r3}
        mov [r12], dl
        ; move row{r1}, row{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column{r2}
        mov [r12], si
        ; call setCursor@i16@i16[row{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.3.1{r1}, [string-14]
        lea rdi, [string_14]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; move t.4.1{r1}, row{r8}
        mov di, bx
        ; add t.4.1{r1}, 1
        add di, 1
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call setCursor@i16@i16[t.4.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const arg.3.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; addrof memVarAddr{r9}, exponent
        lea r12, [rsp+36]
        ; load exponent{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; move exponent{r1}, exponent{r3}
        mov dil, dl
        ; call printTile@u8[exponent{r1}]
        call _printTile@u8
        ; const arg.5.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.5.0{r1}]
        call _printChar@u8
        ; move t.5.1{r1}, row{r8}
        mov di, bx
        ; add t.5.1{r1}, 2
        add di, 2
        ; addrof memVarAddr{r9}, column
        lea r12, [rsp+34]
        ; load column{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; call setCursor@i16@i16[t.5.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.6.1{r1}, [string-14]
        lea rdi, [string_14]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawTileAt@i16@i16@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void drawFrame
_drawFrame:
        sub rsp, 8
        ; const arg.0.0{r1}, 1
        mov di, 1
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-15]
        lea rdi, [string_15]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void clearBoard
_clearBoard:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const row.1{r8}, 0
        mov bx, 0
        ; 220:2 for row < 15
        jmp _for_52
_for_52_body:
        ; move t.1.1{r1}, row.2{r8}
        mov di, bx
        ; add t.1.1{r1}, 3
        add di, 3
        ; const arg.0.1{r2}, 1
        mov si, 1
        ; call setCursor@i16@i16[t.1.1{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.2.1{r1}, [string-16]
        lea rdi, [string_16]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; move row.3{r0}, row.2{r8}
        mov ax, bx
        ; add row.3{r0}, 1
        add ax, 1
        ; move row.2{r8}, row.3{r0}
        mov bx, ax
_for_52:
        ; branch row.2{r8} lt 15: for_52_body
        cmp bx, 15
        jl _for_52_body
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void drawBoard
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
        ; call clearBoard[]
        call _clearBoard
        ; const index.1{r8}, 0
        mov bl, 0
        ; const row.1{r0}, 3
        mov ax, 3
        ; const boardRow.1{r4}, 0
        mov cl, 0
        ; 230:2 for boardRow < 4
        ; move row.2{r1}, row.1{r0}
        mov di, ax
        ; move boardRow.2{r0}, boardRow.1{r4}
        mov al, cl
        ; addrof memVarAddr{r9}, boardRow.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], boardRow.2{r0}
        mov [r12], al
        ; move boardRow.2{r2}, boardRow.2{r0}
        mov sil, al
        jmp _for_53
_for_53_body:
        ; addrof memVarAddr{r9}, boardRow.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], boardRow.2{r2}
        mov [r12], sil
        ; const column.1{r0}, 1
        mov ax, 1
        ; const boardColumn.1{r4}, 0
        mov cl, 0
        ; 232:3 for boardColumn < 4
        ; move column.2{r2}, column.1{r0}
        mov si, ax
        ; move boardColumn.2{r0}, boardColumn.1{r4}
        mov al, cl
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], boardColumn.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r1}
        mov [r12], di
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; move boardColumn.2{r3}, boardColumn.2{r0}
        mov dl, al
        jmp _for_54
_for_54_body:
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], boardColumn.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; cast t.7.1{r0}(i64), index.3{r8}(u8)
        movzx rax, bl
        ; addrof t.6.1{r4}, tiles
        lea rcx, [var_1]
        ; add t.6.2{r4}, t.7.1{r0}
        add rcx, rax
        ; load t.5.1{r3}, [t.6.2{r4}]
        mov dl, [rcx]
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], column.2{r2}
        mov [r12], si
        ; call drawTileAt@i16@i16@u8[row.2{r1}, column.2{r2}, t.5.1{r3}]
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
_for_54:
        ; branch boardColumn.2{r3} lt 4: for_54_body
        cmp dl, 4
        jb _for_54_body
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
_for_53:
        ; branch boardRow.2{r2} lt 4: for_53_body
        cmp sil, 4
        jb _for_53_body
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void drawScore
_drawScore:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const arg.0.0{r1}, 0
        mov di, 0
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-17]
        lea rdi, [string_17]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r8}, score
        lea rbx, [var_2]
        ; load t.2.1{r1}, [a.1.1{r8}]
        mov edi, [rbx]
        ; call printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-18]
        lea rdi, [string_18]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void drawStatus
_drawStatus:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const arg.0.0{r1}, 19
        mov di, 19
        ; const arg.0.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-19]
        lea rdi, [string_19]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 19
        mov di, 19
        ; const arg.2.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 252:2 if gameState == 1
        ; addrof a.1.1{r8}, gameState
        lea rbx, [var_3]
        ; load t.2.1{r8}, [a.1.1{r8}]
        mov bl, [rbx]
        ; branch t.2.1{r8} equals 1: if_55_then
        cmp bl, 1
        je _if_55_then
        ; 255:7 if gameState == 2
        ; addrof a.4.1{r8}, gameState
        lea rbx, [var_3]
        ; load t.5.1{r8}, [a.4.1{r8}]
        mov bl, [rbx]
        ; branch t.5.1{r8} notequals 2: drawStatus_ret, if_56_then
        cmp bl, 2
        jne _drawStatus_ret
        jmp _if_56_then
_if_55_then:
        ; const t.3.1{r1}, [string-20]
        lea rdi, [string_20]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
_if_56_then:
        ; const t.6.1{r1}, [string-21]
        lea rdi, [string_21]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawStatus_ret:
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void newGame
_newGame:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const index.1{r8}, 0
        mov bl, 0
        ; 261:2 for index < 16
        jmp _for_57
_for_57_body:
        ; const t.1.1{r0}, 0
        mov al, 0
        ; cast t.3.1{r1}(i64), index.2{r8}(u8)
        movzx rdi, bl
        ; addrof t.2.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.2.2{r2}, t.3.1{r1}
        add rsi, rdi
        ; store [t.2.2{r2}], t.1.1{r0}
        mov [rsi], al
        ; add index.3{r8}, 1
        add bl, 1
_for_57:
        ; branch index.2{r8} lt 16: for_57_body
        cmp bl, 16
        jb _for_57_body
        ; const t.4.1{r8}, 0
        mov ebx, 0
        ; addrof a.5.1{r0}, score
        lea rax, [var_2]
        ; store [a.5.1{r0}], t.4.1{r8}
        mov [rax], ebx
        ; const t.6.1{r8}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_3]
        ; store [a.7.1{r0}], t.6.1{r8}
        mov [rax], bl
        ; call spawnTile[]
        call _spawnTile
        ; call spawnTile[]
        call _spawnTile
        ; call drawBoard[]
        call _drawBoard
        ; call drawScore[]
        call _drawScore
        ; call drawStatus[]
        call _drawStatus
        ; const arg.5.0{r1}, 21
        mov di, 21
        ; const arg.5.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.5.0{r1}, arg.5.1{r2}]
        call _setCursor@i16@i16
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void main
_main:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; begin initialize global variables
        ; const t.2.1{r8}, 0
        mov ebx, 0
        ; addrof a.3.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.3.1{r0}], t.2.1{r8}
        mov [rax], ebx
        ; addrof a.5.1{r0}, score
        lea rax, [var_2]
        ; store [a.5.1{r0}], t.4.1{r8}
        mov [rax], ebx
        ; const t.6.1{r8}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_3]
        ; store [a.7.1{r0}], t.6.1{r8}
        mov [rax], bl
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call drawFrame[]
        call _drawFrame
        ; call newGame[]
        call _newGame
        ; 278:2 while true
        jmp _while_58
_if_59_end:
        ; branch key.1{r8} equals 114: if_60_then
        cmp bx, 114
        je _if_60_then
        ; branch key.1{r8} equals 82: if_60_then
        cmp bx, 82
        je _if_60_then
        ; 287:3 if gameState != 0
        ; addrof a.8.1{r0}, gameState
        lea rax, [var_3]
        ; load t.9.1{r0}, [a.8.1{r0}]
        mov al, [rax]
        ; branch t.9.1{r0} notequals 0: while_58
        cmp al, 0
        jne _while_58
        ; branch key.1{r8} equals -8117: if_63_then, or_65
        cmp bx, -8117
        je _if_63_then
        jmp _or_65
_if_60_then:
        ; call newGame[]
        call _newGame
        jmp _while_58
_or_65:
        ; branch key.1{r8} equals 97: if_63_then
        cmp bx, 97
        je _if_63_then
        ; branch key.1{r8} equals 65: if_63_then
        cmp bx, 65
        je _if_63_then
        ; branch key.1{r8} equals -8115: if_66_then
        cmp bx, -8115
        je _if_66_then
        ; branch key.1{r8} equals 100: if_66_then, or_67
        cmp bx, 100
        je _if_66_then
        jmp _or_67
_if_63_then:
        ; const direction.2{r8}, 0
        mov bl, 0
        ; move direction.3{r1}, direction.2{r8}
        mov dil, bl
        jmp _if_63_end
_or_67:
        ; branch key.1{r8} equals 68: if_66_then
        cmp bx, 68
        je _if_66_then
        ; branch key.1{r8} equals -8120: if_69_then
        cmp bx, -8120
        je _if_69_then
        ; branch key.1{r8} equals 119: if_69_then, or_70
        cmp bx, 119
        je _if_69_then
        jmp _or_70
_if_66_then:
        ; const direction.4{r8}, 1
        mov bl, 1
        ; move direction.3{r1}, direction.4{r8}
        mov dil, bl
        jmp _if_63_end
_or_70:
        ; branch key.1{r8} equals 87: if_69_then
        cmp bx, 87
        je _if_69_then
        ; branch key.1{r8} equals -8112: if_72_then
        cmp bx, -8112
        je _if_72_then
        ; branch key.1{r8} equals 115: if_72_then, or_73
        cmp bx, 115
        je _if_72_then
        jmp _or_73
_if_69_then:
        ; const direction.5{r8}, 2
        mov bl, 2
        ; move direction.3{r1}, direction.5{r8}
        mov dil, bl
        jmp _if_63_end
_or_73:
        ; branch key.1{r8} notequals 83: while_58, if_72_then
        cmp bx, 83
        jne _while_58
_if_72_then:
        ; const direction.6{r8}, 3
        mov bl, 3
        ; move direction.3{r1}, direction.6{r8}
        mov dil, bl
_if_63_end:
        ; 307:3 if !slide@u8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=307:13]])
        ; call t.10.1{r0} = slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.10.1{r0} equals 0: while_58
        cmp al, 0
        je _while_58
        ; call spawnTile[]
        call _spawnTile
        ; 312:3 if gameState == 0 && !canMove([])
        ; addrof a.11.1{r8}, gameState
        lea rbx, [var_3]
        ; load t.12.1{r8}, [a.11.1{r8}]
        mov bl, [rbx]
        ; branch t.12.1{r8} notequals 0: if_76_end
        cmp bl, 0
        jne _if_76_end
        ; call t.13.1{r0} = canMove[] -> bool
        call _canMove
        ; branch t.13.1{r0} notequals 0: if_76_end
        cmp al, 0
        jne _if_76_end
        ; const t.14.1{r8}, 2
        mov bl, 2
        ; addrof a.15.1{r0}, gameState
        lea rax, [var_3]
        ; store [a.15.1{r0}], t.14.1{r8}
        mov [rax], bl
_if_76_end:
        ; call drawBoard[]
        call _drawBoard
        ; call drawScore[]
        call _drawScore
        ; 317:3 if gameState != 0
        ; addrof a.16.1{r8}, gameState
        lea rbx, [var_3]
        ; load t.17.1{r8}, [a.16.1{r8}]
        mov bl, [rbx]
        ; branch t.17.1{r8} equals 0: if_78_end
        cmp bl, 0
        je _if_78_end
        ; call drawStatus[]
        call _drawStatus
_if_78_end:
        ; const arg.10.0{r1}, 21
        mov di, 21
        ; const arg.10.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.10.0{r1}, arg.10.1{r2}]
        call _setCursor@i16@i16
_while_58:
        ; call key.1{r0} = getChar[] -> i16
        call _getChar
        ; move key.1{r8}, key.1{r0}
        mov bx, ax
        ; 280:3 if key == 27
        ; branch key.1{r8} notequals 27: if_59_end
        cmp bx, 27
        jne _if_59_end
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

        ; i16 __getChar
___getChar:
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
        ; variable 1: tiles[] (u8*/16)
        var_1 rb 16
        ; variable 2: score (i32/4)
        var_2 rb 4
        ; variable 3: gameState (u8/1)
        var_3 rb 1

segment readable
        string_0 db 0x1b, '[', 0x00
        string_1 db '      ', 0x00
        string_2 db '  2   ', 0x00
        string_3 db '  4   ', 0x00
        string_4 db '  8   ', 0x00
        string_5 db '  16  ', 0x00
        string_6 db '  32  ', 0x00
        string_7 db '  64  ', 0x00
        string_8 db ' 128  ', 0x00
        string_9 db ' 256  ', 0x00
        string_10 db ' 512  ', 0x00
        string_11 db ' 1024 ', 0x00
        string_12 db ' 2048 ', 0x00
        string_13 db '  ?   ', 0x00
        string_14 db '+------+', 0x00
        string_15 db 'Arrows/WASD  R restart  Esc quit', 0x00
        string_16 db '                                   ', 0x00
        string_17 db '2048  Score: ', 0x00
        string_18 db '          ', 0x00
        string_19 db '                                      ', 0x00
        string_20 db '2048! Press R to play again.', 0x00
        string_21 db 'No moves left. Press R to restart.', 0x00

