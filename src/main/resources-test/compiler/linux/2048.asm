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
        ; 48:2 for index < exponent
        ; move value.2{r0}, value.1{r2}
        mov ax, si
        ; move index.2{r2}, index.1{r3}
        mov sil, dl
        jmp _for_4
_for_4_body:
        ; move value.3{r3}, value.2{r0}
        mov dx, ax
        ; shiftleft value.3{r3}, 1
        sal dx, 1
        ; add index.3{r2}, 1
        add sil, 1
        ; move value.2{r0}, value.3{r3}
        mov ax, dx
_for_4:
        ; branch index.2{r2} lt exponent{r1}: for_4_body
        cmp sil, dil
        jb _for_4_body
        ; 51:9 return value
        add rsp, 8
        ret

        ; u8 spawnTile
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
        ; 56:2 for index < 16
        jmp _for_5
_for_5_body:
        ; 57:3 if [...] == 0
        ; cast t.7.1{r1}(i64), index.2{r0}(u8)
        movzx rdi, al
        ; addrof t.6.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rsi, rdi
        ; load t.5.1{r1}, [t.6.2{r2}]
        mov dil, [rsi]
        ; branch t.5.1{r1} notequals 0: for_5_continue
        cmp dil, 0
        jne _for_5_continue
        ; add emptyCount.4{r8}, 1
        add bl, 1
_for_5_continue:
        ; add index.6{r0}, 1
        add al, 1
_for_5:
        ; branch index.2{r0} lt 16: for_5_body
        cmp al, 16
        jb _for_5_body
        ; branch emptyCount.2{r8} equals 0: if_7_then
        cmp bl, 0
        je _if_7_then
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
        ; const index.3{r1}, 0
        mov dil, 0
        ; 66:2 for index < 16
        jmp _for_8
_for_8_body:
        ; 67:3 if [...] != 0
        ; cast t.13.1{r2}(i64), index.4{r1}(u8)
        movzx rsi, dil
        ; addrof t.12.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.12.2{r3}, t.13.1{r2}
        add rdx, rsi
        ; load t.11.1{r2}, [t.12.2{r3}]
        mov sil, [rdx]
        ; branch t.11.1{r2} notequals 0: for_8_continue
        cmp sil, 0
        jne _for_8_continue
        ; branch chosen.2{r8} equals 0: if_10_then
        cmp bl, 0
        je _if_10_then
        ; sub chosen.4{r8}, 1
        sub bl, 1
_for_8_continue:
        ; add index.8{r1}, 1
        add dil, 1
        jmp _for_8
_if_7_then:
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
_for_8:
        ; branch index.4{r1} gteq 16: for_8_break, for_8_body
        cmp dil, 16
        jae _for_8_break
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], index.4{r1}
        mov [r12], dil
        jmp _for_8_body
_for_8_break:
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
_if_10_then:
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], index.4{r1}
        mov [r12], dil
        ; const tile.1{r8}, 1
        mov bl, 1
        ; 72:4 if random16([]) % 10 == 0
        ; call t.15.1{r0} = random16[] -> i16
        call _random16
        ; mod t.14.1{r3}, t.14.1{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move t.14.1{r1}, t.14.1{r3}
        mov di, dx
        ; branch t.14.1{r1} equals 0: if_11_then
        cmp di, 0
        je _if_11_then
        ; move tile.2{r1}, tile.1{r8}
        mov dil, bl
        jmp _if_11_end
_if_11_then:
        ; const tile.3{r1}, 2
        mov dil, 2
_if_11_end:
        ; addrof memVarAddr{r9}, index.4
        lea r12, [rsp+32]
        ; load index.4{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; cast t.17.1{r2}(i64), index.4{r0}(u8)
        movzx rsi, al
        ; addrof t.16.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.16.2{r3}, t.17.1{r2}
        add rdx, rsi
        ; store [t.16.2{r3}], tile.2{r1}
        mov [rdx], dil
        ; 76:11 return index
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
        ; 88:2 for position < 4
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
        jmp _for_12
_for_12_body:
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
        ; addrof sourceTile.1{r7}, tiles
        lea r10, [var_1]
        ; add sourceTile.2{r7}, t.14.1{r6}
        add r10, r9
        ; load tile.1{r6}, [sourceTile.2{r7}]
        mov r9b, [r10]
        ; 91:3 if tile != 0
        ; branch tile.1{r6} notequals 0: if_13_then
        cmp r9b, 0
        jne _if_13_then
        ; addrof memVarAddr{r9}, target.3
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], target.3{r3}
        mov [r12], dl
        ; move previousMerged.3{r3}, previousMerged.2{r4}
        mov dl, cl
        ; addrof memVarAddr{r9}, previousMerged.3
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], previousMerged.3{r3}
        mov [r12], dl
        ; move moved.3{r3}, moved.2{r5}
        mov dl, r8b
        ; addrof memVarAddr{r9}, moved.3
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], moved.3{r3}
        mov [r12], dl
        ; move source.2{r4}, source.2{r0}
        mov cl, al
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
        jmp _if_13_end
_if_13_then:
        ; const t.15.1{r1}, 0
        mov dil, 0
        ; store [sourceTile.2{r7}], t.15.1{r1}
        mov [r10], dil
        ; const merged.1{r7}, 0
        mov r10b, 0
        ; 94:4 if target != first && !previousMerged
        ; branch target.2{r3} notequals first{r8}: and_15
        cmp dl, bl
        jne _and_15
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
        ; store [memVarAddr{r9}], target.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; move merged.2{r1}, merged.2{r7}
        mov dil, r10b
        ; move moved.4{r3}, moved.4{r5}
        mov dl, r8b
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov sil, cl
        jmp _if_14_end
_and_15:
        ; branch previousMerged.2{r4} equals 0: if_14_then
        cmp cl, 0
        je _if_14_then
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
        ; store [memVarAddr{r9}], target.2{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; move merged.2{r1}, merged.2{r7}
        mov dil, r10b
        ; move moved.4{r3}, moved.4{r5}
        mov dl, r8b
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov sil, cl
        jmp _if_14_end
_if_14_then:
        ; move previous.1{r1}, target.2{r3}
        mov dil, dl
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], target.2{r3}
        mov [r12], dl
        ; sub previous.1{r1}, step{r2}
        sub dil, sil
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], step{r2}
        mov [r12], sil
        ; cast t.16.1{r2}(i64), previous.1{r1}(u8)
        movzx rsi, dil
        ; addrof previousTile.1{r3}, tiles
        lea rdx, [var_1]
        ; add previousTile.2{r3}, t.16.1{r2}
        add rdx, rsi
        ; 97:5 if *previousTile == tile
        ; load t.17.1{r2}, [previousTile.2{r3}]
        mov sil, [rdx]
        ; branch t.17.1{r2} equals tile.1{r6}: if_16_then
        cmp sil, r9b
        je _if_16_then
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
        ; store [memVarAddr{r9}], merged.2{r7}
        mov [r12], r10b
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], tile.1{r6}
        mov [r12], r9b
        ; move merged.2{r1}, merged.2{r7}
        mov dil, r10b
        ; move moved.4{r3}, moved.4{r5}
        mov dl, r8b
        ; addrof memVarAddr{r9}, previousMerged.4
        lea r12, [rsp+41]
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov sil, cl
        jmp _if_14_end
_if_16_then:
        ; cast t.19.1{r2}(i64), source.2{r0}(u8)
        movzx rsi, al
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; addrof t.18.1{r0}, moveTargets
        lea rax, [var_3]
        ; add t.18.2{r0}, t.19.1{r2}
        add rax, rsi
        ; store [t.18.2{r0}], previous.1{r1}
        mov [rax], dil
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
        ; call t.20.1{r0} = tileValue@u8[nextTile.1{r1}] -> i16
        call _tileValue@u8
        ; cast mergedScore.1{r1}(i32), t.20.1{r0}(i16)
        movsx edi, ax
        ; addrof a.22.1{r2}, score
        lea rsi, [var_6]
        ; load t.23.1{r2}, [a.22.1{r2}]
        mov esi, [rsi]
        ; add t.21.1{r2}, mergedScore.1{r1}
        add esi, edi
        ; addrof a.24.1{r1}, score
        lea rdi, [var_6]
        ; store [a.24.1{r1}], t.21.1{r2}
        mov [rdi], esi
        ; 103:6 if nextTile == 11
        ; load nextTile.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; branch nextTile.1{r1} notequals 11: if_17_end
        cmp dil, 11
        jne _if_17_end
        ; const t.25.1{r1}, 1
        mov dil, 1
        ; addrof a.26.1{r2}, gameState
        lea rsi, [var_7]
        ; store [a.26.1{r2}], t.25.1{r1}
        mov [rsi], dil
_if_17_end:
        ; const merged.3{r1}, 1
        mov dil, 1
        ; const previousMerged.6{r2}, 1
        mov sil, 1
        ; const moved.7{r3}, 1
        mov dl, 1
_if_14_end:
        ; branch merged.2{r1} equals 0: if_18_then
        cmp dil, 0
        je _if_18_then
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
        jmp _if_13_end
_if_18_then:
        ; addrof memVarAddr{r9}, target.2
        lea r12, [rsp+35]
        ; load target.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; cast t.28.1{r2}(i64), source.2{r4}(u8)
        movzx rsi, cl
        ; addrof t.27.1{r5}, moveTargets
        lea r8, [var_3]
        ; add t.27.2{r5}, t.28.1{r2}
        add r8, rsi
        ; store [t.27.2{r5}], target.2{r1}
        mov [r8], dil
        ; cast t.30.1{r2}(i64), target.2{r1}(u8)
        movzx rsi, dil
        ; addrof t.29.1{r5}, tiles
        lea r8, [var_1]
        ; add t.29.2{r5}, t.30.1{r2}
        add r8, rsi
        ; addrof memVarAddr{r9}, tile.1
        lea r12, [rsp+37]
        ; load tile.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; store [t.29.2{r5}], tile.1{r2}
        mov [r8], sil
        ; 114:5 if target != source
        ; branch target.2{r1} equals source.2{r4}: if_19_end
        cmp dil, cl
        je _if_19_end
        ; const moved.6{r2}, 1
        mov sil, 1
        ; move moved.5{r3}, moved.6{r2}
        mov dl, sil
_if_19_end:
        ; addrof memVarAddr{r9}, step
        lea r12, [rsp+33]
        ; load step{r5}, [memVarAddr{r9}]
        mov r8b, [r12]
        ; add target.7{r1}, step{r5}
        add dil, r8b
        ; const previousMerged.5{r2}, 0
        mov sil, 0
_if_13_end:
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
_for_12:
        ; branch position.2{r6} lt 4: for_12_body
        cmp r9b, 4
        jb _for_12_body
        ; 123:9 return moved
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
        ; const index.1{r0}, 0
        mov al, 0
        ; 127:2 for index < 16
        jmp _for_20
_for_20_body:
        ; cast t.8.1{r3}(i64), index.2{r0}(u8)
        movzx rdx, al
        ; addrof t.7.1{r4}, tiles
        lea rcx, [var_1]
        ; add t.7.2{r4}, t.8.1{r3}
        add rcx, rdx
        ; load t.6.1{r3}, [t.7.2{r4}]
        mov dl, [rcx]
        ; cast t.10.1{r4}(i64), index.2{r0}(u8)
        movzx rcx, al
        ; addrof t.9.1{r5}, moveTiles
        lea r8, [var_2]
        ; add t.9.2{r5}, t.10.1{r4}
        add r8, rcx
        ; store [t.9.2{r5}], t.6.1{r3}
        mov [r8], dl
        ; move t.12.1{r3}, t.12.1{r4}
        mov rdx, rcx
        ; addrof t.11.1{r4}, moveTargets
        lea rcx, [var_3]
        ; add t.11.2{r4}, t.12.1{r3}
        add rcx, rdx
        ; store [t.11.2{r4}], index.2{r0}
        mov [rcx], al
        ; add index.3{r0}, 1
        add al, 1
_for_20:
        ; branch index.2{r0} lt 16: for_20_body
        cmp al, 16
        jb _for_20_body
        ; const moved.1{r0}, 0
        mov al, 0
        ; const line.1{r3}, 0
        mov dl, 0
        ; 132:2 for line < 4
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
        jmp _for_21
_for_21_body:
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
        ; 135:3 if direction == 1
        ; branch direction{r8} equals 1: if_22_then
        cmp bl, 1
        je _if_22_then
        ; branch direction{r8} notequals 2: if_23_else, if_23_then
        cmp bl, 2
        jne _if_23_else
        jmp _if_23_then
_if_22_then:
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
        jmp _if_22_end
_if_23_else:
        ; branch direction{r8} notequals 3: slide@u8.no_critical_edge_17, if_24_then
        cmp bl, 3
        jne _slide@u8.no_critical_edge_17
        jmp _if_24_then
_if_23_then:
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
        jmp _if_22_end
_slide@u8.no_critical_edge_17:
        ; move first.3{r1}, first.1{r3}
        mov dil, dl
        ; move step.3{r2}, step.1{r4}
        mov sil, cl
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], line.2{r0}
        mov [r12], al
        jmp _if_22_end
_if_24_then:
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
_if_22_end:
        ; 147:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=147:16], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=147:23]])
        ; call t.13.1{r0} = slideLine@u8@u8[first.3{r1}, step.3{r2}] -> bool
        call _slideLine@u8@u8
        ; branch t.13.1{r0} notequals 0: if_25_then
        cmp al, 0
        jne _if_25_then
        ; addrof memVarAddr{r9}, moved.2
        lea r12, [rsp+33]
        ; load moved.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move moved.4{r1}, moved.2{r0}
        mov dil, al
        jmp _for_21_continue
_if_25_then:
        ; const moved.5{r1}, 1
        mov dil, 1
_for_21_continue:
        ; addrof memVarAddr{r9}, line.2
        lea r12, [rsp+34]
        ; load line.2{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; add line.5{r2}, 1
        add sil, 1
        ; move moved.2{r0}, moved.4{r1}
        mov al, dil
_for_21:
        ; branch line.2{r2} lt 4: for_21_body
        cmp sil, 4
        jb _for_21_body
        ; 151:9 return moved
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
        ; 155:2 for index < 16
        jmp _for_26
_for_26_body:
        ; cast t.3.1{r2}(i64), index.2{r1}(u8)
        movzx rsi, dil
        ; addrof t.2.1{r3}, tiles
        lea rdx, [var_1]
        ; add t.2.2{r3}, t.3.1{r2}
        add rdx, rsi
        ; load tile.1{r2}, [t.2.2{r3}]
        mov sil, [rdx]
        ; 157:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_27_then
        cmp sil, 0
        je _if_27_then
        ; 160:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r3}, index.2{r1}
        mov dl, dil
        ; and t.4.1{r3}, 3
        and dl, 3
        ; branch t.4.1{r3} equals 3: if_28_end
        cmp dl, 3
        je _if_28_end
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
        ; branch t.5.1{r3} equals tile.1{r2}: if_28_then, if_28_end
        cmp dl, sil
        je _if_28_then
_if_28_end:
        ; branch index.2{r1} gteq 12: for_26_continue
        cmp dil, 12
        jae _for_26_continue
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
        ; branch t.9.1{r3} equals tile.1{r2}: if_30_then, for_26_continue
        cmp dl, sil
        je _if_30_then
_for_26_continue:
        ; add index.5{r1}, 1
        add dil, 1
_for_26:
        ; branch index.2{r1} lt 16: for_26_body
        cmp dil, 16
        jb _for_26_body
        ; const {r0}, 0
        mov al, 0
        jmp _canMove_ret
_if_27_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
_if_28_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
_if_30_then:
        ; const {r0}, 1
        mov al, 1
_canMove_ret:
        add rsp, 8
        ret

        ; u8* tileText@u8
        ;   rsp+0: arg exponent
_tileText@u8:
        sub rsp, 8
        ; branch exponent{r1} equals 0: if_32_then
        cmp dil, 0
        je _if_32_then
        ; branch exponent{r1} notequals 1: if_33_else, if_33_then
        cmp dil, 1
        jne _if_33_else
        jmp _if_33_then
_if_32_then:
        ; 172:10 return string
        ; const t.1.1{r0}, [string-0]
        lea rax, [string_0]
        jmp _tileText@u8_ret
_if_33_else:
        ; branch exponent{r1} notequals 2: if_34_else, if_34_then
        cmp dil, 2
        jne _if_34_else
        jmp _if_34_then
_if_33_then:
        ; 175:10 return string
        ; const t.2.1{r1}, [string-1]
        lea rdi, [string_1]
        ; move t.2.1{r0}, t.2.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_34_else:
        ; branch exponent{r1} notequals 3: if_35_else, if_35_then
        cmp dil, 3
        jne _if_35_else
        jmp _if_35_then
_if_34_then:
        ; 178:10 return string
        ; const t.3.1{r1}, [string-2]
        lea rdi, [string_2]
        ; move t.3.1{r0}, t.3.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_35_else:
        ; branch exponent{r1} notequals 4: if_36_else, if_36_then
        cmp dil, 4
        jne _if_36_else
        jmp _if_36_then
_if_35_then:
        ; 181:10 return string
        ; const t.4.1{r1}, [string-3]
        lea rdi, [string_3]
        ; move t.4.1{r0}, t.4.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_36_else:
        ; branch exponent{r1} notequals 5: if_37_else, if_37_then
        cmp dil, 5
        jne _if_37_else
        jmp _if_37_then
_if_36_then:
        ; 184:10 return string
        ; const t.5.1{r1}, [string-4]
        lea rdi, [string_4]
        ; move t.5.1{r0}, t.5.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_37_else:
        ; branch exponent{r1} notequals 6: if_38_else, if_38_then
        cmp dil, 6
        jne _if_38_else
        jmp _if_38_then
_if_37_then:
        ; 187:10 return string
        ; const t.6.1{r1}, [string-5]
        lea rdi, [string_5]
        ; move t.6.1{r0}, t.6.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_38_else:
        ; branch exponent{r1} notequals 7: if_39_else, if_39_then
        cmp dil, 7
        jne _if_39_else
        jmp _if_39_then
_if_38_then:
        ; 190:10 return string
        ; const t.7.1{r1}, [string-6]
        lea rdi, [string_6]
        ; move t.7.1{r0}, t.7.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_39_else:
        ; branch exponent{r1} notequals 8: if_40_else, if_40_then
        cmp dil, 8
        jne _if_40_else
        jmp _if_40_then
_if_39_then:
        ; 193:10 return string
        ; const t.8.1{r1}, [string-7]
        lea rdi, [string_7]
        ; move t.8.1{r0}, t.8.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_40_else:
        ; branch exponent{r1} notequals 9: if_41_else, if_41_then
        cmp dil, 9
        jne _if_41_else
        jmp _if_41_then
_if_40_then:
        ; 196:10 return string
        ; const t.9.1{r1}, [string-8]
        lea rdi, [string_8]
        ; move t.9.1{r0}, t.9.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_41_else:
        ; branch exponent{r1} notequals 10: if_42_else, if_42_then
        cmp dil, 10
        jne _if_42_else
        jmp _if_42_then
_if_41_then:
        ; 199:10 return string
        ; const t.10.1{r1}, [string-9]
        lea rdi, [string_9]
        ; move t.10.1{r0}, t.10.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_42_else:
        ; branch exponent{r1} notequals 11: if_32_end, if_43_then
        cmp dil, 11
        jne _if_32_end
        jmp _if_43_then
_if_42_then:
        ; 202:10 return string
        ; const t.11.1{r1}, [string-10]
        lea rdi, [string_10]
        ; move t.11.1{r0}, t.11.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_32_end:
        ; 207:9 return string
        ; const t.13.1{r1}, [string-12]
        lea rdi, [string_12]
        ; move t.13.1{r0}, t.13.1{r1}
        mov rax, rdi
        jmp _tileText@u8_ret
_if_43_then:
        ; 205:10 return string
        ; const t.12.1{r1}, [string-11]
        lea rdi, [string_11]
        ; move t.12.1{r0}, t.12.1{r1}
        mov rax, rdi
_tileText@u8_ret:
        add rsp, 8
        ret

        ; void drawTileRow@i16@@u8
        ;   rsp+0: arg offset
        ;   rsp+8: arg text
_drawTileRow@i16@@u8:
        sub rsp, 24
        ; const index.1{r0}, 0
        mov al, 0
        ; 211:2 for index < 8
        jmp _for_44
_for_44_body:
        ; cast t.5.1{r3}(i64), index.2{r0}(u8)
        movzx rdx, al
        ; move t.4.1{r4}, text{r2}
        mov rcx, rsi
        ; add t.4.2{r4}, t.5.1{r3}
        add rcx, rdx
        ; load t.3.1{r3}, [t.4.2{r4}]
        mov dl, [rcx]
        ; cast t.7.1{r4}(i64), offset.1{r1}(i16)
        movsx rcx, di
        ; addrof t.6.1{r5}, boardFrame
        lea r8, [var_4]
        ; add t.6.2{r5}, t.7.1{r4}
        add r8, rcx
        ; store [t.6.2{r5}], t.3.1{r3}
        mov [r8], dl
        ; add offset.2{r1}, 1
        add di, 1
        ; add index.3{r0}, 1
        add al, 1
_for_44:
        ; branch index.2{r0} lt 8: for_44_body
        cmp al, 8
        jb _for_44_body
        add rsp, 24
        ret

        ; void drawTileAt@i16@i16@u8
        ;   rsp+32: arg row
        ;   rsp+34: arg column
        ;   rsp+36: arg exponent
        ;   rsp+38: var offset.1
        ;   rsp+40: var offset.2
_drawTileAt@i16@i16@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move exponent{r8}, exponent{r3}
        mov bl, dl
        ; branch exponent{r8} equals 0: drawTileAt@i16@i16@u8_ret
        cmp bl, 0
        je _drawTileAt@i16@i16@u8_ret
        ; move t.8.1{r0}, row{r1}
        mov ax, di
        ; sub t.8.1{r0}, 3
        sub ax, 3
        ; mul t.7.1{r0}, 35
        movsx rax, ax
        imul  rax, 35
        ; add t.6.1{r0}, column{r2}
        add ax, si
        ; move offset.1{r1}, t.6.1{r0}
        mov di, ax
        ; sub offset.1{r1}, 1
        sub di, 1
        ; const t.9.1{r2}, [string-13]
        lea rsi, [string_13]
        ; addrof memVarAddr{r9}, offset.1
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], offset.1{r1}
        mov [r12], di
        ; call drawTileRow@i16@@u8[offset.1{r1}, t.9.1{r2}]
        call _drawTileRow@i16@@u8
        ; load offset.1{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move offset.2{r0}, offset.1{r1}
        mov ax, di
        ; add offset.2{r0}, 35
        add ax, 35
        ; const t.10.1{r2}, 124
        mov sil, 124
        ; cast t.12.1{r3}(i64), offset.2{r0}(i16)
        movsx rdx, ax
        ; addrof t.11.1{r4}, boardFrame
        lea rcx, [var_4]
        ; add t.11.2{r4}, t.12.1{r3}
        add rcx, rdx
        ; store [t.11.2{r4}], t.10.1{r2}
        mov [rcx], sil
        ; move t.17.1{r3}, offset.2{r0}
        mov dx, ax
        ; addrof memVarAddr{r9}, offset.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], offset.2{r0}
        mov [r12], ax
        ; add t.17.1{r3}, 8
        add dx, 8
        ; move t.16.1{r0}, t.17.1{r3}
        mov ax, dx
        ; sub t.16.1{r0}, 1
        sub ax, 1
        ; cast t.15.1{r0}(i64), t.16.1{r0}(i16)
        movsx rax, ax
        ; addrof t.14.1{r3}, boardFrame
        lea rdx, [var_4]
        ; add t.14.2{r3}, t.15.1{r0}
        add rdx, rax
        ; store [t.14.2{r3}], t.13.1{r2}
        mov [rdx], sil
        ; move exponent{r1}, exponent{r8}
        mov dil, bl
        ; call text.1{r0} = tileText@u8[exponent{r1}] -> u8*
        call _tileText@u8
        ; const index.1{r8}, 0
        mov bl, 0
        ; 227:2 for index < 6
        ; load offset.2{r5}, [memVarAddr{r9}]
        mov r8w, [r12]
        jmp _for_46
_for_46_body:
        ; addrof memVarAddr{r9}, offset.2
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], offset.2{r5}
        mov [r12], r8w
        ; cast t.20.1{r3}(i64), index.2{r8}(u8)
        movzx rdx, bl
        ; move t.19.1{r4}, text.1{r0}
        mov rcx, rax
        ; add t.19.2{r4}, t.20.1{r3}
        add rcx, rdx
        ; load t.18.1{r3}, [t.19.2{r4}]
        mov dl, [rcx]
        ; cast t.25.1{r4}(i16), index.2{r8}(u8)
        movzx cx, bl
        ; move t.24.1{r6}, offset.2{r5}
        mov r9w, r8w
        ; add t.24.1{r6}, t.25.1{r4}
        add r9w, cx
        ; move t.23.1{r4}, t.24.1{r6}
        mov cx, r9w
        ; add t.23.1{r4}, 1
        add cx, 1
        ; cast t.22.1{r4}(i64), t.23.1{r4}(i16)
        movsx rcx, cx
        ; addrof t.21.1{r6}, boardFrame
        lea r9, [var_4]
        ; add t.21.2{r6}, t.22.1{r4}
        add r9, rcx
        ; store [t.21.2{r6}], t.18.1{r3}
        mov [r9], dl
        ; add index.3{r8}, 1
        add bl, 1
_for_46:
        ; branch index.2{r8} lt 6: for_46_body
        cmp bl, 6
        jb _for_46_body
        ; move t.26.1{r1}, offset.2{r5}
        mov di, r8w
        ; add t.26.1{r1}, 35
        add di, 35
        ; const t.27.1{r2}, [string-13]
        lea rsi, [string_13]
        ; call drawTileRow@i16@@u8[t.26.1{r1}, t.27.1{r2}]
        call _drawTileRow@i16@@u8
_drawTileAt@i16@i16@u8_ret:
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
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
        ; const t.0.1{r1}, [string-14]
        lea rdi, [string_14]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 8
        ret

        ; void clearBoard
_clearBoard:
        sub rsp, 8
        ; const offset.1{r0}, 0
        mov ax, 0
        ; 242:2 for offset < 525
        jmp _for_47
_for_47_body:
        ; const t.1.1{r1}, 32
        mov dil, 32
        ; cast t.3.1{r2}(i64), offset.2{r0}(i16)
        movsx rsi, ax
        ; addrof t.2.1{r3}, boardFrame
        lea rdx, [var_4]
        ; add t.2.2{r3}, t.3.1{r2}
        add rdx, rsi
        ; store [t.2.2{r3}], t.1.1{r1}
        mov [rdx], dil
        ; add offset.3{r0}, 1
        add ax, 1
_for_47:
        ; branch offset.2{r0} lt 525: for_47_body
        cmp ax, 525
        jl _for_47_body
        add rsp, 8
        ret

        ; void presentBoard
        ;   rsp+32: var row.2
        ;   rsp+34: var column.2
        ;   rsp+36: var character.1
        ;   rsp+37: var printing.4
        ;   rsp+38: var printing.5
_presentBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const offset.1{r8}, 0
        mov bx, 0
        ; const row.1{r0}, 0
        mov ax, 0
        ; 249:2 for row < 15
        jmp _for_48
_for_48_body:
        ; const printing.1{r3}, 0
        mov dl, 0
        ; const column.1{r4}, 0
        mov cx, 0
        ; 251:3 for column < 35
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], ax
        ; move printing.2{r0}, printing.2{r3}
        mov al, dl
        ; move column.2{r3}, column.2{r4}
        mov dx, cx
        jmp _for_49
_for_49_body:
        ; move column.2{r4}, column.2{r3}
        mov cx, dx
        ; move printing.2{r3}, printing.2{r0}
        mov dl, al
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; cast t.6.1{r5}(i64), offset.3{r8}(i16)
        movsx r8, bx
        ; addrof t.5.1{r6}, boardFrame
        lea r9, [var_4]
        ; add t.5.2{r6}, t.6.1{r5}
        add r9, r8
        ; load character.1{r1}, [t.5.2{r6}]
        mov dil, [r9]
        ; 253:4 if character != [...]
        ; addrof t.8.1{r6}, displayedFrame
        lea r9, [var_5]
        ; add t.8.2{r6}, t.9.1{r5}
        add r9, r8
        ; load t.7.1{r5}, [t.8.2{r6}]
        mov r8b, [r9]
        ; branch character.1{r1} equals t.7.1{r5}: if_50_else, if_50_then
        cmp dil, r8b
        je _if_50_else
        ; addrof memVarAddr{r9}, character.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], character.1{r1}
        mov [r12], dil
        jmp _if_50_then
_if_50_else:
        ; const printing.3{r3}, 0
        mov dl, 0
        ; addrof memVarAddr{r9}, printing.4
        lea r12, [rsp+37]
        ; store [memVarAddr{r9}], printing.4{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column.2{r4}
        mov [r12], cx
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, printing.4
        lea r12, [rsp+37]
        ; move printing.4{r0}, printing.4{r3}
        mov al, dl
        jmp _if_50_end
_if_50_then:
        ; addrof memVarAddr{r9}, character.1
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], character.1{r1}
        mov [r12], dil
        ; branch printing.2{r3} equals 0: if_51_then
        cmp dl, 0
        je _if_51_then
        ; addrof memVarAddr{r9}, printing.5
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], printing.5{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column.2{r4}
        mov [r12], cx
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], ax
        jmp _if_51_end
_if_51_then:
        ; move t.10.1{r1}, row.2{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], row.2{r0}
        mov [r12], ax
        ; add t.10.1{r1}, 3
        add di, 3
        ; move t.11.1{r2}, column.2{r4}
        mov si, cx
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], column.2{r4}
        mov [r12], cx
        ; add t.11.1{r2}, 1
        add si, 1
        ; call setCursor@i16@i16[t.10.1{r1}, t.11.1{r2}]
        call _setCursor@i16@i16
        ; const printing.6{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r9}, printing.5
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], printing.5{r0}
        mov [r12], al
_if_51_end:
        ; addrof memVarAddr{r9}, character.1
        lea r12, [rsp+36]
        ; load character.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printChar@u8[character.1{r1}]
        call _printChar@u8
        ; cast t.13.1{r0}(i64), offset.3{r8}(i16)
        movsx rax, bx
        ; addrof t.12.1{r3}, displayedFrame
        lea rdx, [var_5]
        ; add t.12.2{r3}, t.13.1{r0}
        add rdx, rax
        ; load character.1{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; store [t.12.2{r3}], character.1{r1}
        mov [rdx], dil
        ; addrof memVarAddr{r9}, printing.5
        lea r12, [rsp+38]
        ; load printing.5{r0}, [memVarAddr{r9}]
        mov al, [r12]
_if_50_end:
        ; add offset.5{r8}, 1
        add bx, 1
        ; addrof memVarAddr{r9}, column.2
        lea r12, [rsp+34]
        ; load column.2{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; add column.5{r3}, 1
        add dx, 1
_for_49:
        ; branch column.2{r3} lt 35: for_49_body
        cmp dx, 35
        jl _for_49_body
        ; addrof memVarAddr{r9}, row.2
        lea r12, [rsp+32]
        ; load row.2{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; add row.4{r0}, 1
        add ax, 1
_for_48:
        ; branch row.2{r0} lt 15: for_48_body
        cmp ax, 15
        jl _for_48_body
        ; const arg.2.0{r1}, 21
        mov di, 21
        ; const arg.2.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
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
        ; 274:2 for boardRow < 4
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
        jmp _for_52
_for_52_body:
        ; addrof memVarAddr{r9}, boardRow.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], boardRow.2{r2}
        mov [r12], sil
        ; const column.1{r0}, 1
        mov ax, 1
        ; const boardColumn.1{r4}, 0
        mov cl, 0
        ; 276:3 for boardColumn < 4
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
        ; move boardColumn.2{r1}, boardColumn.2{r0}
        mov dil, al
        jmp _for_53
_for_53_body:
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], boardColumn.2{r1}
        mov [r12], dil
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
        ; add index.4{r8}, 1
        add bl, 1
        ; load column.2{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move column.3{r0}, column.2{r2}
        mov ax, si
        ; add column.3{r0}, 9
        add ax, 9
        ; addrof memVarAddr{r9}, boardColumn.2
        lea r12, [rsp+38]
        ; load boardColumn.2{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; add boardColumn.3{r1}, 1
        add dil, 1
        ; move column.2{r2}, column.3{r0}
        mov si, ax
_for_53:
        ; branch boardColumn.2{r1} lt 4: for_53_body
        cmp dil, 4
        jb _for_53_body
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
_for_52:
        ; branch boardRow.2{r2} lt 4: for_52_body
        cmp sil, 4
        jb _for_52_body
        ; call presentBoard[]
        call _presentBoard
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void animateSlide
        ;   rsp+32: var remaining.2
        ;   rsp+34: var source.2
_animateSlide:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const frame.1{r8}, 1
        mov bx, 1
        ; 318:2 for frame <= 8
        jmp _for_54
_for_54_body:
        ; const remaining.1{r0}, 8
        mov ax, 8
        ; sub remaining.2{r0}, frame.2{r8}
        sub ax, bx
        ; addrof memVarAddr{r9}, remaining.2
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], remaining.2{r0}
        mov [r12], ax
        ; call clearBoard[]
        call _clearBoard
        ; const source.1{r0}, 0
        mov al, 0
        ; 322:3 for source < 16
        jmp _for_55
_for_55_body:
        ; cast t.12.1{r4}(i64), source.2{r0}(u8)
        movzx rcx, al
        ; addrof t.11.1{r5}, moveTiles
        lea r8, [var_2]
        ; add t.11.2{r5}, t.12.1{r4}
        add r8, rcx
        ; load exponent.1{r3}, [t.11.2{r5}]
        mov dl, [r8]
        ; 324:4 if exponent == 0
        ; branch exponent.1{r3} notequals 0: if_56_end
        cmp dl, 0
        jne _if_56_end
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        jmp _for_55_continue
_if_56_end:
        ; cast t.14.1{r4}(i64), source.2{r0}(u8)
        movzx rcx, al
        ; addrof t.13.1{r5}, moveTargets
        lea r8, [var_3]
        ; add t.13.2{r5}, t.14.1{r4}
        add r8, rcx
        ; load target.1{r4}, [t.13.2{r5}]
        mov cl, [r8]
        ; move t.16.1{r5}, source.2{r0}
        mov r8b, al
        ; shiftright t.16.1{r5}, 2
        shr r8b, 2
        ; cast t.15.1{r5}(i16), t.16.1{r5}(u8)
        movzx r8w, r8b
        ; shiftleft sourceRow.1{r5}, 2
        sal r8w, 2
        ; move t.18.1{r6}, source.2{r0}
        mov r9b, al
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], source.2{r0}
        mov [r12], al
        ; and t.18.1{r6}, 3
        and r9b, 3
        ; cast t.17.1{r0}(i16), t.18.1{r6}(u8)
        movzx ax, r9b
        ; mul sourceColumn.1{r0}, 9
        movsx rax, ax
        imul  rax, 9
        ; move t.20.1{r6}, target.1{r4}
        mov r9b, cl
        ; shiftright t.20.1{r6}, 2
        shr r9b, 2
        ; cast t.19.1{r6}(i16), t.20.1{r6}(u8)
        movzx r9w, r9b
        ; shiftleft targetRow.1{r6}, 2
        sal r9w, 2
        ; and t.22.1{r4}, 3
        and cl, 3
        ; cast t.21.1{r4}(i16), t.22.1{r4}(u8)
        movzx cx, cl
        ; mul targetColumn.1{r4}, 9
        movsx rcx, cx
        imul  rcx, 9
        ; addrof memVarAddr{r9}, remaining.2
        lea r12, [rsp+32]
        ; load remaining.2{r7}, [memVarAddr{r9}]
        mov r10w, [r12]
        ; mul t.24.1{r5}, remaining.2{r7}
        movsx r8, r8w
        movsx r10, r10w
        imul  r8, r10
        ; mul t.25.1{r6}, frame.2{r8}
        movsx r9, r9w
        movsx rbx, bx
        imul  r9, rbx
        ; add t.23.1{r5}, t.25.1{r6}
        add r8w, r9w
        ; shiftright row.1{r5}, 3
        sar r8w, 3
        ; mul t.27.1{r0}, remaining.2{r7}
        movsx rax, ax
        movsx r10, r10w
        imul  rax, r10
        ; mul t.28.1{r4}, frame.2{r8}
        movsx rcx, cx
        movsx rbx, bx
        imul  rcx, rbx
        ; add t.26.1{r0}, t.28.1{r4}
        add ax, cx
        ; shiftright column.1{r0}, 3
        sar ax, 3
        ; move t.29.1{r1}, row.1{r5}
        mov di, r8w
        ; add t.29.1{r1}, 3
        add di, 3
        ; move t.30.1{r2}, column.1{r0}
        mov si, ax
        ; add t.30.1{r2}, 1
        add si, 1
        ; call drawTileAt@i16@i16@u8[t.29.1{r1}, t.30.1{r2}, exponent.1{r3}]
        call _drawTileAt@i16@i16@u8
_for_55_continue:
        ; addrof memVarAddr{r9}, source.2
        lea r12, [rsp+34]
        ; load source.2{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add source.4{r0}, 1
        add al, 1
_for_55:
        ; branch source.2{r0} lt 16: for_55_body
        cmp al, 16
        jb _for_55_body
        ; call presentBoard[]
        call _presentBoard
        ; call waitFrame[]
        call _waitFrame
        ; move frame.4{r0}, frame.2{r8}
        mov ax, bx
        ; add frame.4{r0}, 1
        add ax, 1
        ; move frame.2{r8}, frame.4{r0}
        mov bx, ax
_for_54:
        ; branch frame.2{r8} lteq 8: for_54_body
        cmp bx, 8
        jle _for_54_body
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
        ; const t.0.1{r1}, [string-15]
        lea rdi, [string_15]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r8}, score
        lea rbx, [var_6]
        ; load t.2.1{r1}, [a.1.1{r8}]
        mov edi, [rbx]
        ; call printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-16]
        lea rdi, [string_16]
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
        ; const t.0.1{r1}, [string-17]
        lea rdi, [string_17]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 19
        mov di, 19
        ; const arg.2.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 352:2 if gameState == 1
        ; addrof a.1.1{r8}, gameState
        lea rbx, [var_7]
        ; load t.2.1{r8}, [a.1.1{r8}]
        mov bl, [rbx]
        ; branch t.2.1{r8} equals 1: if_57_then
        cmp bl, 1
        je _if_57_then
        ; 355:7 if gameState == 2
        ; addrof a.4.1{r8}, gameState
        lea rbx, [var_7]
        ; load t.5.1{r8}, [a.4.1{r8}]
        mov bl, [rbx]
        ; branch t.5.1{r8} notequals 2: drawStatus_ret, if_58_then
        cmp bl, 2
        jne _drawStatus_ret
        jmp _if_58_then
_if_57_then:
        ; const t.3.1{r1}, [string-18]
        lea rdi, [string_18]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
_if_58_then:
        ; const t.6.1{r1}, [string-19]
        lea rdi, [string_19]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawStatus_ret:
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; u8 newGame
_newGame:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const index.1{r8}, 0
        mov bl, 0
        ; 361:2 for index < 16
        jmp _for_59
_for_59_body:
        ; const t.2.1{r0}, 0
        mov al, 0
        ; cast t.4.1{r1}(i64), index.2{r8}(u8)
        movzx rdi, bl
        ; addrof t.3.1{r2}, tiles
        lea rsi, [var_1]
        ; add t.3.2{r2}, t.4.1{r1}
        add rsi, rdi
        ; store [t.3.2{r2}], t.2.1{r0}
        mov [rsi], al
        ; add index.3{r8}, 1
        add bl, 1
_for_59:
        ; branch index.2{r8} lt 16: for_59_body
        cmp bl, 16
        jb _for_59_body
        ; const t.5.1{r8}, 0
        mov ebx, 0
        ; addrof a.6.1{r0}, score
        lea rax, [var_6]
        ; store [a.6.1{r0}], t.5.1{r8}
        mov [rax], ebx
        ; const t.7.1{r8}, 0
        mov bl, 0
        ; addrof a.8.1{r0}, gameState
        lea rax, [var_7]
        ; store [a.8.1{r0}], t.7.1{r8}
        mov [rax], bl
        ; call _ = spawnTile[] -> u8
        call _spawnTile
        ; call spawnedTileIndex.1{r0} = spawnTile[] -> u8
        call _spawnTile
        ; move spawnedTileIndex.1{r8}, spawnedTileIndex.1{r0}
        mov bl, al
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
        ; 372:9 return spawnedTileIndex
        ; move spawnedTileIndex.1{r0}, spawnedTileIndex.1{r8}
        mov al, bl
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void main
        ;   rsp+32: var key.1
_main:
        sub rsp, 8
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
        ; addrof a.9.1{r0}, score
        lea rax, [var_6]
        ; store [a.9.1{r0}], t.8.1{r8}
        mov [rax], ebx
        ; const t.10.1{r8}, 0
        mov bl, 0
        ; addrof a.11.1{r0}, gameState
        lea rax, [var_7]
        ; store [a.11.1{r0}], t.10.1{r8}
        mov [rax], bl
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov edi, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call drawFrame[]
        call _drawFrame
        ; call spawnedTileIndex.1{r0} = newGame[] -> u8
        call _newGame
        ; 379:2 while true
        ; move spawnedTileIndex.2{r8}, spawnedTileIndex.1{r0}
        mov bl, al
        jmp _while_60
_if_61_end:
        ; branch key.1{r0} equals 114: if_62_then
        cmp ax, 114
        je _if_62_then
        ; branch key.1{r0} equals 82: if_62_then
        cmp ax, 82
        je _if_62_then
        ; 391:3 if gameState != 0
        ; addrof a.18.1{r1}, gameState
        lea rdi, [var_7]
        ; load t.19.1{r1}, [a.18.1{r1}]
        mov dil, [rdi]
        ; branch t.19.1{r1} notequals 0: while_60
        cmp dil, 0
        jne _while_60
        ; branch key.1{r0} equals -8117: if_65_then, or_67
        cmp ax, -8117
        je _if_65_then
        ; addrof memVarAddr{r9}, key.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], key.1{r0}
        mov [r12], ax
        jmp _or_67
_if_62_then:
        ; call spawnedTileIndex.3{r0} = newGame[] -> u8
        call _newGame
        ; move spawnedTileIndex.2{r8}, spawnedTileIndex.3{r0}
        mov bl, al
        jmp _while_60
_or_67:
        ; addrof memVarAddr{r9}, key.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], key.1{r0}
        mov [r12], ax
        ; branch key.1{r0} equals 97: if_65_then
        cmp ax, 97
        je _if_65_then
        ; branch key.1{r0} equals 65: if_65_then
        cmp ax, 65
        je _if_65_then
        ; branch key.1{r0} equals -8115: if_68_then
        cmp ax, -8115
        je _if_68_then
        ; branch key.1{r0} equals 100: if_68_then, or_69
        cmp ax, 100
        je _if_68_then
        jmp _or_69
_if_65_then:
        ; const direction.2{r0}, 0
        mov al, 0
        ; move direction.3{r1}, direction.2{r0}
        mov dil, al
        jmp _if_65_end
_or_69:
        ; branch key.1{r0} equals 68: if_68_then
        cmp ax, 68
        je _if_68_then
        ; branch key.1{r0} equals -8120: if_71_then
        cmp ax, -8120
        je _if_71_then
        ; branch key.1{r0} equals 119: if_71_then, or_72
        cmp ax, 119
        je _if_71_then
        jmp _or_72
_if_68_then:
        ; const direction.4{r0}, 1
        mov al, 1
        ; move direction.3{r1}, direction.4{r0}
        mov dil, al
        jmp _if_65_end
_or_72:
        ; branch key.1{r0} equals 87: if_71_then
        cmp ax, 87
        je _if_71_then
        ; branch key.1{r0} equals -8112: if_74_then
        cmp ax, -8112
        je _if_74_then
        ; branch key.1{r0} equals 115: if_74_then, or_75
        cmp ax, 115
        je _if_74_then
        jmp _or_75
_if_71_then:
        ; const direction.5{r0}, 2
        mov al, 2
        ; move direction.3{r1}, direction.5{r0}
        mov dil, al
        jmp _if_65_end
_or_75:
        ; branch key.1{r0} notequals 83: while_60, if_74_then
        cmp ax, 83
        jne _while_60
_if_74_then:
        ; const direction.6{r0}, 3
        mov al, 3
        ; move direction.3{r1}, direction.6{r0}
        mov dil, al
_if_65_end:
        ; 411:3 if !slide@u8([ExprVarAccess[varName=direction, index=4, scope=function, type=u8, varIsArray=false, location=411:13]])
        ; call t.20.1{r0} = slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.20.1{r0} equals 0: while_60
        cmp al, 0
        je _while_60
        ; call animateSlide[]
        call _animateSlide
        ; call newTileIndex.1{r0} = spawnTile[] -> u8
        call _spawnTile
        ; 417:3 if newTileIndex != 255
        ; branch newTileIndex.1{r0} equals 255: if_78_end
        cmp al, 255
        je _if_78_end
        ; move spawnedTileIndex.8{r8}, newTileIndex.1{r0}
        mov bl, al
_if_78_end:
        ; 420:3 if gameState == 0 && !canMove([])
        ; addrof a.21.1{r0}, gameState
        lea rax, [var_7]
        ; load t.22.1{r0}, [a.21.1{r0}]
        mov al, [rax]
        ; branch t.22.1{r0} notequals 0: if_79_end
        cmp al, 0
        jne _if_79_end
        ; call t.23.1{r0} = canMove[] -> bool
        call _canMove
        ; branch t.23.1{r0} notequals 0: if_79_end
        cmp al, 0
        jne _if_79_end
        ; const t.24.1{r0}, 2
        mov al, 2
        ; addrof a.25.1{r1}, gameState
        lea rdi, [var_7]
        ; store [a.25.1{r1}], t.24.1{r0}
        mov [rdi], al
_if_79_end:
        ; call drawBoard[]
        call _drawBoard
        ; call drawScore[]
        call _drawScore
        ; 425:3 if gameState != 0
        ; addrof a.26.1{r0}, gameState
        lea rax, [var_7]
        ; load t.27.1{r0}, [a.26.1{r0}]
        mov al, [rax]
        ; branch t.27.1{r0} equals 0: while_60
        cmp al, 0
        je _while_60
        ; call drawStatus[]
        call _drawStatus
_while_60:
        ; move t.14.1{r0}, spawnedTileIndex.2{r8}
        mov al, bl
        ; shiftright t.14.1{r0}, 2
        shr al, 2
        ; cast t.13.1{r0}(i16), t.14.1{r0}(u8)
        movzx ax, al
        ; shiftleft t.12.1{r0}, 2
        sal ax, 2
        ; move row.1{r1}, t.12.1{r0}
        mov di, ax
        ; add row.1{r1}, 4
        add di, 4
        ; move t.17.1{r0}, spawnedTileIndex.2{r8}
        mov al, bl
        ; and t.17.1{r0}, 3
        and al, 3
        ; cast t.16.1{r0}(i16), t.17.1{r0}(u8)
        movzx ax, al
        ; mul t.15.1{r0}, 9
        movsx rax, ax
        imul  rax, 9
        ; move column.1{r2}, t.15.1{r0}
        mov si, ax
        ; add column.1{r2}, 5
        add si, 5
        ; call setCursor@i16@i16[row.1{r1}, column.1{r2}]
        call _setCursor@i16@i16
        ; call key.1{r0} = getChar[] -> i16
        call _getChar
        ; 384:3 if key == 27
        ; branch key.1{r0} notequals 27: if_61_end
        cmp ax, 27
        jne _if_61_end
        ; const arg.13.0{r1}, 21
        mov di, 21
        ; const arg.13.1{r2}, 0
        mov si, 0
        ; call setCursor@i16@i16[arg.13.0{r1}, arg.13.1{r2}]
        call _setCursor@i16@i16
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

        ; void waitFrame
_waitFrame:
        sub  rsp, 10h
        mov  qword [rsp], 0
        mov  qword [rsp+8], 20000000
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
        ; variable 4: boardFrame[] (u8*/525)
        var_4 rb 525
        ; variable 5: displayedFrame[] (u8*/525)
        var_5 rb 525
        ; variable 6: score (i32/4)
        var_6 rb 4
        ; variable 7: gameState (u8/1)
        var_7 rb 1

segment readable
        string_0 db '      ', 0x00
        string_1 db '   2  ', 0x00
        string_2 db '   4  ', 0x00
        string_3 db '   8  ', 0x00
        string_4 db '  16  ', 0x00
        string_5 db '  32  ', 0x00
        string_6 db '  64  ', 0x00
        string_7 db '  128 ', 0x00
        string_8 db '  256 ', 0x00
        string_9 db '  512 ', 0x00
        string_10 db ' 1024 ', 0x00
        string_11 db ' 2048 ', 0x00
        string_12 db '  ?   ', 0x00
        string_13 db '+------+', 0x00
        string_14 db 'Arrows/WASD  R restart  Esc quit', 0x00
        string_15 db '2048  Score: ', 0x00
        string_16 db '          ', 0x00
        string_17 db '                                      ', 0x00
        string_18 db '2048! Press R to play again.', 0x00
        string_19 db 'No moves left. Press R to restart.', 0x00

