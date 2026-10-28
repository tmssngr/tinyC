format pe64 console
include 'win64ax.inc'

STD_IN_HANDLE = -10
STD_OUT_HANDLE = -11
STD_ERR_HANDLE = -12

entry start

section '.text' code readable executable

start:
        ; alignment
        and rsp, -16
        call init
        call _main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length.1{r2}, length.1{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar@u8
        ;   rsp+64: arg chr
_printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; move t.1.1{r1}, t.1.1{r7}
        mov rcx, r12
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printUint@i32
        ;   rsp+48: arg number
_printUint@i32:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(i32)
        movsxd rcx, ecx
        ; call printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 32
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 33:2 while true
        ; move number.1{r3}, number{r1}
        mov r8, rcx
_while_1:
        ; sub pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r4}, number.1{r3}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r4}
        mov rax, r9
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r4}, remainder.1{r2}
        mov r9, rdx
        ; move number.2{r0}, number.2{r3}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r3}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r4}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r4}(i64), pos.3{r6}(u8)
        movzx r9, bl
        ; addrof t.6.1{r5}, buffer
        lea r10, [rsp+40]
        ; add t.6.2{r5}, t.7.1{r4}
        add r10, r9
        ; store [t.6.2{r5}], digit.1{r0}
        mov [r10], al
        ; 39:3 if number == 0
        ; branch number.2{r3} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; addrof t.8.1{r3}, buffer
        lea r8, [rsp+40]
        ; move t.8.2{r1}, t.8.2{r5}
        mov rcx, r10
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov dl, al
        ; sub t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r2}, 0
        mov rdx, 0
        ; 73:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_3
_for_3_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_3:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_3_body
        cmp dl, 0
        jne _for_3_body
        ; 76:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.1.1{r0}, salt{r1}
        mov eax, ecx
        ; addrof a.2.1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.2.1{r1}], t.1.1{r0}
        mov [rcx], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.5.1{r1}, __random__
        lea rcx, [var_0]
        ; load r.1{r1}, [a.5.1{r1}]
        mov ecx, [rcx]
        ; move t.6.1{r2}, r.1{r1}
        mov edx, ecx
        ; and t.6.1{r2}, 524287
        and edx, 524287
        ; mul b.1{r2}, 48271
        movsxd rdx, edx
        imul  rdx, 48271
        ; shiftright t.7.1{r1}, 15
        sar ecx, 15
        ; mul c.1{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; move t.8.1{r3}, c.1{r1}
        mov r8d, ecx
        ; and t.8.1{r3}, 65535
        and r8d, 65535
        ; shiftleft d.1{r3}, 15
        sal r8d, 15
        ; shiftright t.10.1{r1}, 16
        sar ecx, 16
        ; add t.9.1{r1}, b.1{r2}
        add ecx, edx
        ; add e.1{r1}, d.1{r3}
        add ecx, r8d
        ; move t.12.1{r2}, e.1{r1}
        mov edx, ecx
        ; and t.12.1{r2}, 2147483647
        and edx, 2147483647
        ; shiftright t.13.1{r1}, 31
        sar ecx, 31
        ; add t.11.1{r2}, t.13.1{r1}
        add edx, ecx
        ; addrof a.14.1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.14.1{r1}], t.11.1{r2}
        mov [rcx], edx
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r2}
        mov eax, edx
        add rsp, 8
        ret

        ; i16 random16
_random16:
        sub rsp, 8
        sub rsp, 32
        ; 20:25 return (i16) & 32767
        ; call t.2.1{r0} = random[] -> i32
        call _random
        ; cast t.1.1{r1}(i16), t.2.1{r0}(i32)
        mov cx, ax
        ; move t.0.1{r0}, t.1.1{r1}
        mov ax, cx
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 32
        add rsp, 8
        ret

        ; i32 tileValue@u8
        ;   rsp+16: arg exponent
_tileValue@u8:
        sub rsp, 8
        ; const value.1{r2}, 1
        mov edx, 1
        ; const index.1{r3}, 0
        mov r8b, 0
        ; 46:2 for index < exponent
        ; move value.2{r0}, value.1{r2}
        mov eax, edx
        ; move index.2{r2}, index.1{r3}
        mov dl, r8b
        jmp _for_4
_for_4_body:
        ; move value.3{r3}, value.2{r0}
        mov r8d, eax
        ; shiftleft value.3{r3}, 1
        sal r8d, 1
        ; add index.3{r2}, 1
        add dl, 1
        ; move value.2{r0}, value.3{r3}
        mov eax, r8d
_for_4:
        ; branch index.2{r2} lt exponent{r1}: for_4_body
        cmp dl, cl
        jb _for_4_body
        ; 49:9 return value
        add rsp, 8
        ret

        ; void spawnTile
        ;   rsp+48: var index.4
_spawnTile:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const emptyCount.1{r6}, 0
        mov bl, 0
        ; const index.1{r0}, 0
        mov al, 0
        ; 54:2 for index < 16
        jmp _for_5
_for_5_body:
        ; 55:3 if [...] == 0
        ; cast t.7.1{r1}(i64), index.2{r0}(u8)
        movzx rcx, al
        ; addrof t.6.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rdx, rcx
        ; load t.5.1{r1}, [t.6.2{r2}]
        mov cl, [rdx]
        ; branch t.5.1{r1} notequals 0: for_5_continue
        cmp cl, 0
        jne _for_5_continue
        ; add emptyCount.4{r6}, 1
        add bl, 1
_for_5_continue:
        ; add index.6{r0}, 1
        add al, 1
_for_5:
        ; branch index.2{r0} lt 16: for_5_body
        cmp al, 16
        jb _for_5_body
        ; branch emptyCount.2{r6} equals 0: spawnTile_ret
        cmp bl, 0
        je _spawnTile_ret
        ; call t.9.1{r0} = random16[] -> i16
        call _random16
        ; cast t.10.1{r6}(i16), emptyCount.2{r6}(u8)
        movzx bx, bl
        ; mod t.8.1{r2}, t.8.1{r0}, t.10.1{r6}
        movsx rax, ax
        movsx rbx, bx
        cqo
        idiv rbx
        ; move t.8.1{r1}, t.8.1{r2}
        mov cx, dx
        ; cast chosen.1{r6}(u8), t.8.1{r1}(i16)
        mov bl, cl
        ; const index.3{r0}, 0
        mov al, 0
        ; 64:2 for index < 16
        jmp _for_8
_for_8_body:
        ; 65:3 if [...] != 0
        ; cast t.13.1{r1}(i64), index.4{r0}(u8)
        movzx rcx, al
        ; addrof t.12.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.12.2{r2}, t.13.1{r1}
        add rdx, rcx
        ; load t.11.1{r1}, [t.12.2{r2}]
        mov cl, [rdx]
        ; branch t.11.1{r1} notequals 0: for_8_continue
        cmp cl, 0
        jne _for_8_continue
        ; branch chosen.2{r6} equals 0: if_10_then
        cmp bl, 0
        je _if_10_then
        ; sub chosen.4{r6}, 1
        sub bl, 1
_for_8_continue:
        ; add index.8{r0}, 1
        add al, 1
_for_8:
        ; branch index.4{r0} gteq 16: spawnTile_ret, for_8_body
        cmp al, 16
        jae _spawnTile_ret
        ; addrof memVarAddr{r7}, index.4
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], index.4{r0}
        mov [r12], al
        jmp _for_8_body
_if_10_then:
        ; addrof memVarAddr{r7}, index.4
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], index.4{r0}
        mov [r12], al
        ; const tile.1{r6}, 1
        mov bl, 1
        ; 70:4 if random16([]) % 10 == 0
        ; call t.15.1{r0} = random16[] -> i16
        call _random16
        ; mod t.14.1{r2}, t.14.1{r0}, 10
        movsx rax, ax
        cqo
        mov rcx, 10
        idiv rcx
        ; move t.14.1{r3}, t.14.1{r2}
        mov r8w, dx
        ; branch t.14.1{r3} equals 0: if_11_then
        cmp r8w, 0
        je _if_11_then
        ; move tile.2{r0}, tile.1{r6}
        mov al, bl
        jmp _if_11_end
_if_11_then:
        ; const tile.3{r0}, 2
        mov al, 2
_if_11_end:
        ; addrof memVarAddr{r7}, index.4
        lea r12, [rsp+48]
        ; load index.4{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.17.1{r1}(i64), index.4{r1}(u8)
        movzx rcx, cl
        ; addrof t.16.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.16.2{r2}, t.17.1{r1}
        add rdx, rcx
        ; store [t.16.2{r2}], tile.2{r0}
        mov [rdx], al
        ; 74:4 return
_spawnTile_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool slideLine@u8@u8
        ;   rsp+80: arg first
        ;   rsp+88: arg step
        ;   rsp+48: var source.2
        ;   rsp+49: var target.2
        ;   rsp+50: var position.2
        ;   rsp+51: var tile.1
        ;   rsp+52: var target.3
        ;   rsp+53: var previousMerged.3
        ;   rsp+54: var moved.3
        ;   rsp+55: var previousMerged.4
        ;   rsp+56: var moved.4
        ;   rsp+57: var merged.2
        ;   rsp+58: var nextTile.1
_slideLine@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move first{r6}, first{r1}
        mov bl, cl
        ; move source.1{r0}, first{r6}
        mov al, bl
        ; move target.1{r3}, first{r6}
        mov r8b, bl
        ; const previousMerged.1{r4}, 0
        mov r9b, 0
        ; const moved.1{r5}, 0
        mov r10b, 0
        ; const position.1{r1}, 0
        mov cl, 0
        ; 85:2 for position < 4
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], position.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; move position.2{r6}, position.2{r1}
        mov bl, cl
        ; move target.2{r1}, target.2{r3}
        mov cl, r8b
        ; move moved.2{r3}, moved.2{r5}
        mov r8b, r10b
        ; move step{r5}, step{r2}
        mov r10b, dl
        ; move previousMerged.2{r2}, previousMerged.2{r4}
        mov dl, r9b
        ; move source.2{r4}, source.2{r0}
        mov r9b, al
        ; move moved.2{r0}, moved.2{r3}
        mov al, r8b
        jmp _for_12
_for_12_body:
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], position.2{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; load first{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; move target.2{r3}, target.2{r1}
        mov r8b, cl
        ; move moved.2{r1}, moved.2{r0}
        mov cl, al
        ; move source.2{r0}, source.2{r4}
        mov al, r9b
        ; move previousMerged.2{r4}, previousMerged.2{r2}
        mov r9b, dl
        ; move step{r2}, step{r5}
        mov dl, r10b
        ; move moved.2{r5}, moved.2{r1}
        mov r10b, cl
        ; cast t.13.1{r1}(i64), source.2{r0}(u8)
        movzx rcx, al
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], source.2{r0}
        mov [r12], al
        ; addrof sourceTile.1{r0}, tiles
        lea rax, [var_1]
        ; add sourceTile.2{r0}, t.13.1{r1}
        add rax, rcx
        ; load tile.1{r1}, [sourceTile.2{r0}]
        mov cl, [rax]
        ; 88:3 if tile != 0
        ; branch tile.1{r1} notequals 0: if_13_then
        cmp cl, 0
        jne _if_13_then
        ; move target.3{r0}, target.2{r3}
        mov al, r8b
        ; addrof memVarAddr{r7}, target.3
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], target.3{r0}
        mov [r12], al
        ; move previousMerged.3{r0}, previousMerged.2{r4}
        mov al, r9b
        ; addrof memVarAddr{r7}, previousMerged.3
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], previousMerged.3{r0}
        mov [r12], al
        ; move moved.3{r0}, moved.2{r5}
        mov al, r10b
        ; addrof memVarAddr{r7}, moved.3
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], moved.3{r0}
        mov [r12], al
        ; move moved.3{r3}, moved.3{r0}
        mov r8b, al
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; move step{r5}, step{r2}
        mov r10b, dl
        ; addrof memVarAddr{r7}, target.3
        lea r12, [rsp+52]
        ; load target.3{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, previousMerged.3
        lea r12, [rsp+53]
        ; load previousMerged.3{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        jmp _if_13_end
_if_13_then:
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], tile.1{r1}
        mov [r12], cl
        ; const t.14.1{r1}, 0
        mov cl, 0
        ; store [sourceTile.2{r0}], t.14.1{r1}
        mov [rax], cl
        ; const merged.1{r0}, 0
        mov al, 0
        ; 91:4 if target != first && !previousMerged
        ; branch target.2{r3} notequals first{r6}: and_15
        cmp r8b, bl
        jne _and_15
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], step{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], target.2{r3}
        mov [r12], r8b
        ; move merged.2{r1}, merged.2{r0}
        mov cl, al
        ; move moved.4{r3}, moved.4{r5}
        mov r8b, r10b
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov dl, r9b
        jmp _if_14_end
_and_15:
        ; branch previousMerged.2{r4} equals 0: if_14_then
        cmp r9b, 0
        je _if_14_then
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], step{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], target.2{r3}
        mov [r12], r8b
        ; move merged.2{r1}, merged.2{r0}
        mov cl, al
        ; move moved.4{r3}, moved.4{r5}
        mov r8b, r10b
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov dl, r9b
        jmp _if_14_end
_if_14_then:
        ; move previous.1{r1}, target.2{r3}
        mov cl, r8b
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], target.2{r3}
        mov [r12], r8b
        ; sub previous.1{r1}, step{r2}
        sub cl, dl
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], step{r2}
        mov [r12], dl
        ; cast t.15.1{r2}(i64), previous.1{r1}(u8)
        movzx rdx, cl
        ; addrof previousTile.1{r3}, tiles
        lea r8, [var_1]
        ; add previousTile.2{r3}, t.15.1{r2}
        add r8, rdx
        ; 94:5 if *previousTile == tile
        ; load t.16.1{r2}, [previousTile.2{r3}]
        mov dl, [r8]
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch t.16.1{r2} equals tile.1{r6}: if_16_then
        cmp dl, bl
        je _if_16_then
        ; move previousMerged.4{r2}, previousMerged.2{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, previousMerged.4
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], previousMerged.4{r2}
        mov [r12], dl
        ; move moved.4{r2}, moved.2{r5}
        mov dl, r10b
        ; addrof memVarAddr{r7}, moved.4
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], moved.4{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, merged.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], merged.2{r0}
        mov [r12], al
        ; move merged.2{r1}, merged.2{r0}
        mov cl, al
        ; move moved.4{r3}, moved.4{r2}
        mov r8b, dl
        ; addrof memVarAddr{r7}, previousMerged.4
        lea r12, [rsp+55]
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov dl, r9b
        jmp _if_14_end
_if_16_then:
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.18.1{r2}(i64), source.2{r0}(u8)
        movzx rdx, al
        ; addrof t.17.1{r0}, moveTargets
        lea rax, [var_3]
        ; add t.17.2{r0}, t.18.1{r2}
        add rax, rdx
        ; store [t.17.2{r0}], previous.1{r1}
        mov [rax], cl
        ; move nextTile.1{r1}, tile.1{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], tile.1{r6}
        mov [r12], bl
        ; add nextTile.1{r1}, 1
        add cl, 1
        ; store [previousTile.2{r3}], nextTile.1{r1}
        mov [r8], cl
        ; addrof a.20.1{r6}, score
        lea rbx, [var_6]
        ; load t.21.1{r6}, [a.20.1{r6}]
        mov ebx, [rbx]
        ; addrof memVarAddr{r7}, nextTile.1
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], nextTile.1{r1}
        mov [r12], cl
        ; call t.22.1{r0} = tileValue@u8[nextTile.1{r1}] -> i32
        call _tileValue@u8
        ; move t.19.1{r1}, t.21.1{r6}
        mov ecx, ebx
        ; add t.19.1{r1}, t.22.1{r0}
        add ecx, eax
        ; addrof a.23.1{r2}, score
        lea rdx, [var_6]
        ; store [a.23.1{r2}], t.19.1{r1}
        mov [rdx], ecx
        ; 99:6 if nextTile == 11
        ; load nextTile.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch nextTile.1{r1} notequals 11: if_17_end
        cmp cl, 11
        jne _if_17_end
        ; const t.24.1{r1}, 1
        mov cl, 1
        ; addrof a.25.1{r2}, gameState
        lea rdx, [var_7]
        ; store [a.25.1{r2}], t.24.1{r1}
        mov [rdx], cl
_if_17_end:
        ; const merged.3{r1}, 1
        mov cl, 1
        ; const previousMerged.6{r2}, 1
        mov dl, 1
        ; const moved.7{r3}, 1
        mov r8b, 1
_if_14_end:
        ; branch merged.2{r1} equals 0: if_18_then
        cmp cl, 0
        je _if_18_then
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; load target.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; load step{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        jmp _if_13_end
_if_18_then:
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; load target.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; cast t.27.1{r2}(i64), source.2{r4}(u8)
        movzx rdx, r9b
        ; addrof t.26.1{r5}, moveTargets
        lea r10, [var_3]
        ; add t.26.2{r5}, t.27.1{r2}
        add r10, rdx
        ; store [t.26.2{r5}], target.2{r1}
        mov [r10], cl
        ; cast t.29.1{r2}(i64), target.2{r1}(u8)
        movzx rdx, cl
        ; addrof t.28.1{r5}, tiles
        lea r10, [var_1]
        ; add t.28.2{r5}, t.29.1{r2}
        add r10, rdx
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; store [t.28.2{r5}], tile.1{r2}
        mov [r10], dl
        ; 110:5 if target != source
        ; branch target.2{r1} equals source.2{r4}: if_19_end
        cmp cl, r9b
        je _if_19_end
        ; const moved.6{r2}, 1
        mov dl, 1
        ; move moved.5{r3}, moved.6{r2}
        mov r8b, dl
_if_19_end:
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; load step{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; add target.7{r1}, step{r5}
        add cl, r10b
        ; const previousMerged.5{r2}, 0
        mov dl, 0
_if_13_end:
        ; add source.4{r4}, step{r5}
        add r9b, r10b
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; load position.2{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; add position.5{r6}, 1
        add bl, 1
        ; move moved.2{r0}, moved.3{r3}
        mov al, r8b
_for_12:
        ; branch position.2{r6} lt 4: for_12_body
        cmp bl, 4
        jb _for_12_body
        ; 119:9 return moved
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool slide@u8
        ;   rsp+64: arg direction
        ;   rsp+48: var moved.2
        ;   rsp+49: var line.2
_slide@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move direction{r6}, direction{r1}
        mov bl, cl
        ; const index.1{r0}, 0
        mov al, 0
        ; 123:2 for index < 16
        jmp _for_20
_for_20_body:
        ; cast t.8.1{r3}(i64), index.2{r0}(u8)
        movzx r8, al
        ; addrof t.7.1{r4}, tiles
        lea r9, [var_1]
        ; add t.7.2{r4}, t.8.1{r3}
        add r9, r8
        ; load t.6.1{r3}, [t.7.2{r4}]
        mov r8b, [r9]
        ; cast t.10.1{r4}(i64), index.2{r0}(u8)
        movzx r9, al
        ; addrof t.9.1{r5}, moveTiles
        lea r10, [var_2]
        ; add t.9.2{r5}, t.10.1{r4}
        add r10, r9
        ; store [t.9.2{r5}], t.6.1{r3}
        mov [r10], r8b
        ; move t.12.1{r3}, t.12.1{r4}
        mov r8, r9
        ; addrof t.11.1{r4}, moveTargets
        lea r9, [var_3]
        ; add t.11.2{r4}, t.12.1{r3}
        add r9, r8
        ; store [t.11.2{r4}], index.2{r0}
        mov [r9], al
        ; add index.3{r0}, 1
        add al, 1
_for_20:
        ; branch index.2{r0} lt 16: for_20_body
        cmp al, 16
        jb _for_20_body
        ; const moved.1{r0}, 0
        mov al, 0
        ; const line.1{r3}, 0
        mov r8b, 0
        ; 128:2 for line < 4
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], moved.2{r0}
        mov [r12], al
        ; move line.2{r0}, line.1{r3}
        mov al, r8b
        ; move line.2{r2}, line.2{r0}
        mov dl, al
        ; load moved.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp _for_21
_for_21_body:
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], moved.2{r0}
        mov [r12], al
        ; move line.2{r0}, line.2{r2}
        mov al, dl
        ; move first.1{r3}, line.2{r0}
        mov r8b, al
        ; shiftleft first.1{r3}, 2
        shl r8b, 2
        ; const step.1{r4}, 1
        mov r9b, 1
        ; 131:3 if direction == 1
        ; branch direction{r6} equals 1: if_22_then
        cmp bl, 1
        je _if_22_then
        ; branch direction{r6} notequals 2: if_23_else, if_23_then
        cmp bl, 2
        jne _if_23_else
        jmp _if_23_then
_if_22_then:
        ; add first.2{r3}, 3
        add r8b, 3
        ; const step.2{r4}, 255
        mov r9b, 255
        ; move first.3{r1}, first.2{r3}
        mov cl, r8b
        ; move step.3{r2}, step.2{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp _if_22_end
_if_23_else:
        ; branch direction{r6} notequals 3: slide@u8.no_critical_edge_17, if_24_then
        cmp bl, 3
        jne _slide@u8.no_critical_edge_17
        jmp _if_24_then
_if_23_then:
        ; move first.4{r3}, line.2{r0}
        mov r8b, al
        ; const step.4{r4}, 4
        mov r9b, 4
        ; move first.3{r1}, first.4{r3}
        mov cl, r8b
        ; move step.3{r2}, step.4{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp _if_22_end
_slide@u8.no_critical_edge_17:
        ; move first.3{r1}, first.1{r3}
        mov cl, r8b
        ; move step.3{r2}, step.1{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp _if_22_end
_if_24_then:
        ; move first.5{r3}, line.2{r0}
        mov r8b, al
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        ; add first.5{r3}, 12
        add r8b, 12
        ; const step.5{r0}, 252
        mov al, 252
        ; move first.3{r1}, first.5{r3}
        mov cl, r8b
        ; move step.3{r2}, step.5{r0}
        mov dl, al
_if_22_end:
        ; 143:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=143:17], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=143:24]])
        ; call t.13.1{r0} = slideLine@u8@u8[first.3{r1}, step.3{r2}] -> bool
        call _slideLine@u8@u8
        ; branch t.13.1{r0} notequals 0: if_25_then
        cmp al, 0
        jne _if_25_then
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; load moved.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move moved.4{r1}, moved.2{r0}
        mov cl, al
        jmp _for_21_continue
_if_25_then:
        ; const moved.5{r1}, 1
        mov cl, 1
_for_21_continue:
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; load line.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add line.5{r2}, 1
        add dl, 1
        ; move moved.2{r0}, moved.4{r1}
        mov al, cl
_for_21:
        ; branch line.2{r2} lt 4: for_21_body
        cmp dl, 4
        jb _for_21_body
        ; 147:9 return moved
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool canMove
_canMove:
        sub rsp, 8
        ; const index.1{r1}, 0
        mov cl, 0
        ; 151:2 for index < 16
        jmp _for_26
_for_26_body:
        ; cast t.3.1{r2}(i64), index.2{r1}(u8)
        movzx rdx, cl
        ; addrof t.2.1{r3}, tiles
        lea r8, [var_1]
        ; add t.2.2{r3}, t.3.1{r2}
        add r8, rdx
        ; load tile.1{r2}, [t.2.2{r3}]
        mov dl, [r8]
        ; 153:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_27_then
        cmp dl, 0
        je _if_27_then
        ; 156:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r3}, index.2{r1}
        mov r8b, cl
        ; and t.4.1{r3}, 3
        and r8b, 3
        ; branch t.4.1{r3} equals 3: if_28_end
        cmp r8b, 3
        je _if_28_end
        ; move t.8.1{r3}, index.2{r1}
        mov r8b, cl
        ; add t.8.1{r3}, 1
        add r8b, 1
        ; cast t.7.1{r3}(i64), t.8.1{r3}(u8)
        movzx r8, r8b
        ; addrof t.6.1{r4}, tiles
        lea r9, [var_1]
        ; add t.6.2{r4}, t.7.1{r3}
        add r9, r8
        ; load t.5.1{r3}, [t.6.2{r4}]
        mov r8b, [r9]
        ; branch t.5.1{r3} equals tile.1{r2}: if_28_then, if_28_end
        cmp r8b, dl
        je _if_28_then
_if_28_end:
        ; branch index.2{r1} gteq 12: for_26_continue
        cmp cl, 12
        jae _for_26_continue
        ; move t.12.1{r3}, index.2{r1}
        mov r8b, cl
        ; add t.12.1{r3}, 4
        add r8b, 4
        ; cast t.11.1{r3}(i64), t.12.1{r3}(u8)
        movzx r8, r8b
        ; addrof t.10.1{r4}, tiles
        lea r9, [var_1]
        ; add t.10.2{r4}, t.11.1{r3}
        add r9, r8
        ; load t.9.1{r3}, [t.10.2{r4}]
        mov r8b, [r9]
        ; branch t.9.1{r3} equals tile.1{r2}: if_30_then, for_26_continue
        cmp r8b, dl
        je _if_30_then
_for_26_continue:
        ; add index.5{r1}, 1
        add cl, 1
_for_26:
        ; branch index.2{r1} lt 16: for_26_body
        cmp cl, 16
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
        ;   rsp+16: arg exponent
_tileText@u8:
        sub rsp, 8
        ; branch exponent{r1} equals 0: if_32_then
        cmp cl, 0
        je _if_32_then
        ; branch exponent{r1} notequals 1: if_33_else, if_33_then
        cmp cl, 1
        jne _if_33_else
        jmp _if_33_then
_if_32_then:
        ; 168:10 return string
        ; const t.1.1{r0}, [string-0]
        lea rax, [string_0]
        jmp _tileText@u8_ret
_if_33_else:
        ; branch exponent{r1} notequals 2: if_34_else, if_34_then
        cmp cl, 2
        jne _if_34_else
        jmp _if_34_then
_if_33_then:
        ; 171:10 return string
        ; const t.2.1{r1}, [string-1]
        lea rcx, [string_1]
        ; move t.2.1{r0}, t.2.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_34_else:
        ; branch exponent{r1} notequals 3: if_35_else, if_35_then
        cmp cl, 3
        jne _if_35_else
        jmp _if_35_then
_if_34_then:
        ; 174:10 return string
        ; const t.3.1{r1}, [string-2]
        lea rcx, [string_2]
        ; move t.3.1{r0}, t.3.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_35_else:
        ; branch exponent{r1} notequals 4: if_36_else, if_36_then
        cmp cl, 4
        jne _if_36_else
        jmp _if_36_then
_if_35_then:
        ; 177:10 return string
        ; const t.4.1{r1}, [string-3]
        lea rcx, [string_3]
        ; move t.4.1{r0}, t.4.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_36_else:
        ; branch exponent{r1} notequals 5: if_37_else, if_37_then
        cmp cl, 5
        jne _if_37_else
        jmp _if_37_then
_if_36_then:
        ; 180:10 return string
        ; const t.5.1{r1}, [string-4]
        lea rcx, [string_4]
        ; move t.5.1{r0}, t.5.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_37_else:
        ; branch exponent{r1} notequals 6: if_38_else, if_38_then
        cmp cl, 6
        jne _if_38_else
        jmp _if_38_then
_if_37_then:
        ; 183:10 return string
        ; const t.6.1{r1}, [string-5]
        lea rcx, [string_5]
        ; move t.6.1{r0}, t.6.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_38_else:
        ; branch exponent{r1} notequals 7: if_39_else, if_39_then
        cmp cl, 7
        jne _if_39_else
        jmp _if_39_then
_if_38_then:
        ; 186:10 return string
        ; const t.7.1{r1}, [string-6]
        lea rcx, [string_6]
        ; move t.7.1{r0}, t.7.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_39_else:
        ; branch exponent{r1} notequals 8: if_40_else, if_40_then
        cmp cl, 8
        jne _if_40_else
        jmp _if_40_then
_if_39_then:
        ; 189:10 return string
        ; const t.8.1{r1}, [string-7]
        lea rcx, [string_7]
        ; move t.8.1{r0}, t.8.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_40_else:
        ; branch exponent{r1} notequals 9: if_41_else, if_41_then
        cmp cl, 9
        jne _if_41_else
        jmp _if_41_then
_if_40_then:
        ; 192:10 return string
        ; const t.9.1{r1}, [string-8]
        lea rcx, [string_8]
        ; move t.9.1{r0}, t.9.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_41_else:
        ; branch exponent{r1} notequals 10: if_42_else, if_42_then
        cmp cl, 10
        jne _if_42_else
        jmp _if_42_then
_if_41_then:
        ; 195:10 return string
        ; const t.10.1{r1}, [string-9]
        lea rcx, [string_9]
        ; move t.10.1{r0}, t.10.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_42_else:
        ; branch exponent{r1} notequals 11: if_32_end, if_43_then
        cmp cl, 11
        jne _if_32_end
        jmp _if_43_then
_if_42_then:
        ; 198:10 return string
        ; const t.11.1{r1}, [string-10]
        lea rcx, [string_10]
        ; move t.11.1{r0}, t.11.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_32_end:
        ; 203:9 return string
        ; const t.13.1{r1}, [string-12]
        lea rcx, [string_12]
        ; move t.13.1{r0}, t.13.1{r1}
        mov rax, rcx
        jmp _tileText@u8_ret
_if_43_then:
        ; 201:10 return string
        ; const t.12.1{r1}, [string-11]
        lea rcx, [string_11]
        ; move t.12.1{r0}, t.12.1{r1}
        mov rax, rcx
_tileText@u8_ret:
        add rsp, 8
        ret

        ; void drawTileRow@i16@@u8
        ;   rsp+16: arg offset
        ;   rsp+24: arg text
_drawTileRow@i16@@u8:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov al, 0
        ; 207:2 for index < 8
        jmp _for_44
_for_44_body:
        ; cast t.5.1{r3}(i64), index.2{r0}(u8)
        movzx r8, al
        ; move t.4.1{r4}, text{r2}
        mov r9, rdx
        ; add t.4.2{r4}, t.5.1{r3}
        add r9, r8
        ; load t.3.1{r3}, [t.4.2{r4}]
        mov r8b, [r9]
        ; cast t.7.1{r4}(i64), offset.1{r1}(i16)
        movsx r9, cx
        ; addrof t.6.1{r5}, boardFrame
        lea r10, [var_4]
        ; add t.6.2{r5}, t.7.1{r4}
        add r10, r9
        ; store [t.6.2{r5}], t.3.1{r3}
        mov [r10], r8b
        ; add offset.2{r1}, 1
        add cx, 1
        ; add index.3{r0}, 1
        add al, 1
_for_44:
        ; branch index.2{r0} lt 8: for_44_body
        cmp al, 8
        jb _for_44_body
        add rsp, 8
        ret

        ; void drawTileAt@i16@i16@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+80: arg exponent
        ;   rsp+48: var offset.1
        ;   rsp+50: var offset.2
_drawTileAt@i16@i16@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move exponent{r6}, exponent{r3}
        mov bl, r8b
        ; branch exponent{r6} equals 0: drawTileAt@i16@i16@u8_ret
        cmp bl, 0
        je _drawTileAt@i16@i16@u8_ret
        ; move t.8.1{r0}, row{r1}
        mov ax, cx
        ; sub t.8.1{r0}, 3
        sub ax, 3
        ; mul t.7.1{r0}, 35
        movsx rax, ax
        imul  rax, 35
        ; add t.6.1{r0}, column{r2}
        add ax, dx
        ; move offset.1{r1}, t.6.1{r0}
        mov cx, ax
        ; sub offset.1{r1}, 1
        sub cx, 1
        ; const t.9.1{r2}, [string-13]
        lea rdx, [string_13]
        ; addrof memVarAddr{r7}, offset.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], offset.1{r1}
        mov [r12], cx
        ; call drawTileRow@i16@@u8[offset.1{r1}, t.9.1{r2}]
        call _drawTileRow@i16@@u8
        ; load offset.1{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; move offset.2{r0}, offset.1{r1}
        mov ax, cx
        ; add offset.2{r0}, 35
        add ax, 35
        ; const t.10.1{r2}, 124
        mov dl, 124
        ; cast t.12.1{r3}(i64), offset.2{r0}(i16)
        movsx r8, ax
        ; addrof t.11.1{r4}, boardFrame
        lea r9, [var_4]
        ; add t.11.2{r4}, t.12.1{r3}
        add r9, r8
        ; store [t.11.2{r4}], t.10.1{r2}
        mov [r9], dl
        ; move t.17.1{r3}, offset.2{r0}
        mov r8w, ax
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], offset.2{r0}
        mov [r12], ax
        ; add t.17.1{r3}, 8
        add r8w, 8
        ; move t.16.1{r0}, t.17.1{r3}
        mov ax, r8w
        ; sub t.16.1{r0}, 1
        sub ax, 1
        ; cast t.15.1{r0}(i64), t.16.1{r0}(i16)
        movsx rax, ax
        ; addrof t.14.1{r3}, boardFrame
        lea r8, [var_4]
        ; add t.14.2{r3}, t.15.1{r0}
        add r8, rax
        ; store [t.14.2{r3}], t.13.1{r2}
        mov [r8], dl
        ; move exponent{r1}, exponent{r6}
        mov cl, bl
        ; call text.1{r0} = tileText@u8[exponent{r1}] -> u8*
        call _tileText@u8
        ; const index.1{r6}, 0
        mov bl, 0
        ; 223:2 for index < 6
        ; load offset.2{r5}, [memVarAddr{r7}]
        mov r10w, [r12]
        jmp _for_46
_for_46_body:
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], offset.2{r5}
        mov [r12], r10w
        ; cast t.20.1{r3}(i64), index.2{r6}(u8)
        movzx r8, bl
        ; move t.19.1{r4}, text.1{r0}
        mov r9, rax
        ; add t.19.2{r4}, t.20.1{r3}
        add r9, r8
        ; load t.18.1{r3}, [t.19.2{r4}]
        mov r8b, [r9]
        ; cast t.25.1{r4}(i16), index.2{r6}(u8)
        movzx r9w, bl
        ; move t.24.1{r2}, offset.2{r5}
        mov dx, r10w
        ; add t.24.1{r2}, t.25.1{r4}
        add dx, r9w
        ; move t.23.1{r4}, t.24.1{r2}
        mov r9w, dx
        ; add t.23.1{r4}, 1
        add r9w, 1
        ; cast t.22.1{r4}(i64), t.23.1{r4}(i16)
        movsx r9, r9w
        ; addrof t.21.1{r2}, boardFrame
        lea rdx, [var_4]
        ; add t.21.2{r2}, t.22.1{r4}
        add rdx, r9
        ; store [t.21.2{r2}], t.18.1{r3}
        mov [rdx], r8b
        ; add index.3{r6}, 1
        add bl, 1
_for_46:
        ; branch index.2{r6} lt 6: for_46_body
        cmp bl, 6
        jb _for_46_body
        ; move t.26.1{r1}, offset.2{r5}
        mov cx, r10w
        ; add t.26.1{r1}, 35
        add cx, 35
        ; const t.27.1{r2}, [string-13]
        lea rdx, [string_13]
        ; call drawTileRow@i16@@u8[t.26.1{r1}, t.27.1{r2}]
        call _drawTileRow@i16@@u8
_drawTileAt@i16@i16@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void drawFrame
_drawFrame:
        sub rsp, 8
        sub rsp, 32
        ; const arg.0.0{r1}, 1
        mov cx, 1
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-14]
        lea rcx, [string_14]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void clearBoard
_clearBoard:
        sub rsp, 8
        ; const offset.1{r0}, 0
        mov ax, 0
        ; 238:2 for offset < 525
        jmp _for_47
_for_47_body:
        ; const t.1.1{r1}, 32
        mov cl, 32
        ; cast t.3.1{r2}(i64), offset.2{r0}(i16)
        movsx rdx, ax
        ; addrof t.2.1{r3}, boardFrame
        lea r8, [var_4]
        ; add t.2.2{r3}, t.3.1{r2}
        add r8, rdx
        ; store [t.2.2{r3}], t.1.1{r1}
        mov [r8], cl
        ; add offset.3{r0}, 1
        add ax, 1
_for_47:
        ; branch offset.2{r0} lt 525: for_47_body
        cmp ax, 525
        jl _for_47_body
        add rsp, 8
        ret

        ; void presentBoard
        ;   rsp+48: var row.2
        ;   rsp+50: var column.2
        ;   rsp+52: var character.1
        ;   rsp+53: var printing.4
        ;   rsp+54: var printing.5
_presentBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const offset.1{r6}, 0
        mov bx, 0
        ; const row.1{r0}, 0
        mov ax, 0
        ; 245:2 for row < 15
        jmp _for_48
_for_48_body:
        ; const printing.1{r3}, 0
        mov r8b, 0
        ; const column.1{r4}, 0
        mov r9w, 0
        ; 247:3 for column < 35
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], ax
        ; move printing.2{r0}, printing.2{r3}
        mov al, r8b
        ; move column.2{r3}, column.2{r4}
        mov r8w, r9w
        jmp _for_49
_for_49_body:
        ; move column.2{r4}, column.2{r3}
        mov r9w, r8w
        ; move printing.2{r3}, printing.2{r0}
        mov r8b, al
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.6.1{r5}(i64), offset.3{r6}(i16)
        movsx r10, bx
        ; addrof t.5.1{r2}, boardFrame
        lea rdx, [var_4]
        ; add t.5.2{r2}, t.6.1{r5}
        add rdx, r10
        ; load character.1{r1}, [t.5.2{r2}]
        mov cl, [rdx]
        ; 249:4 if character != [...]
        ; addrof t.8.1{r2}, displayedFrame
        lea rdx, [var_5]
        ; add t.8.2{r2}, t.9.1{r5}
        add rdx, r10
        ; load t.7.1{r5}, [t.8.2{r2}]
        mov r10b, [rdx]
        ; branch character.1{r1} equals t.7.1{r5}: if_50_else, if_50_then
        cmp cl, r10b
        je _if_50_else
        ; addrof memVarAddr{r7}, character.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], character.1{r1}
        mov [r12], cl
        jmp _if_50_then
_if_50_else:
        ; const printing.3{r3}, 0
        mov r8b, 0
        ; addrof memVarAddr{r7}, printing.4
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], printing.4{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], column.2{r4}
        mov [r12], r9w
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, printing.4
        lea r12, [rsp+53]
        ; move printing.4{r0}, printing.4{r3}
        mov al, r8b
        jmp _if_50_end
_if_50_then:
        ; addrof memVarAddr{r7}, character.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], character.1{r1}
        mov [r12], cl
        ; branch printing.2{r3} equals 0: if_51_then
        cmp r8b, 0
        je _if_51_then
        ; addrof memVarAddr{r7}, printing.5
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], printing.5{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], column.2{r4}
        mov [r12], r9w
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], ax
        jmp _if_51_end
_if_51_then:
        ; move t.10.1{r1}, row.2{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], ax
        ; add t.10.1{r1}, 3
        add cx, 3
        ; move t.11.1{r2}, column.2{r4}
        mov dx, r9w
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], column.2{r4}
        mov [r12], r9w
        ; add t.11.1{r2}, 1
        add dx, 1
        ; call setCursor@i16@i16[t.10.1{r1}, t.11.1{r2}]
        call _setCursor@i16@i16
        ; const printing.6{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r7}, printing.5
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], printing.5{r0}
        mov [r12], al
_if_51_end:
        ; addrof memVarAddr{r7}, character.1
        lea r12, [rsp+52]
        ; load character.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; call printChar@u8[character.1{r1}]
        call _printChar@u8
        ; cast t.13.1{r0}(i64), offset.3{r6}(i16)
        movsx rax, bx
        ; addrof t.12.1{r3}, displayedFrame
        lea r8, [var_5]
        ; add t.12.2{r3}, t.13.1{r0}
        add r8, rax
        ; load character.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; store [t.12.2{r3}], character.1{r1}
        mov [r8], cl
        ; addrof memVarAddr{r7}, printing.5
        lea r12, [rsp+54]
        ; load printing.5{r0}, [memVarAddr{r7}]
        mov al, [r12]
_if_50_end:
        ; add offset.5{r6}, 1
        add bx, 1
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+50]
        ; load column.2{r3}, [memVarAddr{r7}]
        mov r8w, [r12]
        ; add column.5{r3}, 1
        add r8w, 1
_for_49:
        ; branch column.2{r3} lt 35: for_49_body
        cmp r8w, 35
        jl _for_49_body
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; add row.4{r0}, 1
        add ax, 1
_for_48:
        ; branch row.2{r0} lt 15: for_48_body
        cmp ax, 15
        jl _for_48_body
        ; const arg.2.0{r1}, 21
        mov cx, 21
        ; const arg.2.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void drawBoard
        ;   rsp+48: var row.2
        ;   rsp+50: var boardRow.2
        ;   rsp+52: var column.2
        ;   rsp+54: var boardColumn.2
_drawBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call clearBoard[]
        call _clearBoard
        ; const index.1{r6}, 0
        mov bl, 0
        ; const row.1{r0}, 3
        mov ax, 3
        ; const boardRow.1{r4}, 0
        mov r9b, 0
        ; 270:2 for boardRow < 4
        ; move row.2{r1}, row.1{r0}
        mov cx, ax
        ; move boardRow.2{r0}, boardRow.1{r4}
        mov al, r9b
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r0}
        mov [r12], al
        ; move boardRow.2{r2}, boardRow.2{r0}
        mov dl, al
        jmp _for_52
_for_52_body:
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r2}
        mov [r12], dl
        ; const column.1{r0}, 1
        mov ax, 1
        ; const boardColumn.1{r4}, 0
        mov r9b, 0
        ; 272:3 for boardColumn < 4
        ; move column.2{r2}, column.1{r0}
        mov dx, ax
        ; move boardColumn.2{r0}, boardColumn.1{r4}
        mov al, r9b
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], boardColumn.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; move boardColumn.2{r1}, boardColumn.2{r0}
        mov cl, al
        jmp _for_53
_for_53_body:
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], boardColumn.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; cast t.7.1{r0}(i64), index.3{r6}(u8)
        movzx rax, bl
        ; addrof t.6.1{r4}, tiles
        lea r9, [var_1]
        ; add t.6.2{r4}, t.7.1{r0}
        add r9, rax
        ; load t.5.1{r3}, [t.6.2{r4}]
        mov r8b, [r9]
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dx
        ; call drawTileAt@i16@i16@u8[row.2{r1}, column.2{r2}, t.5.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; add index.4{r6}, 1
        add bl, 1
        ; load column.2{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; move column.3{r0}, column.2{r2}
        mov ax, dx
        ; add column.3{r0}, 9
        add ax, 9
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; load boardColumn.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add boardColumn.3{r1}, 1
        add cl, 1
        ; move column.2{r2}, column.3{r0}
        mov dx, ax
_for_53:
        ; branch boardColumn.2{r1} lt 4: for_53_body
        cmp cl, 4
        jb _for_53_body
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; move row.4{r0}, row.2{r1}
        mov ax, cx
        ; add row.4{r0}, 4
        add ax, 4
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; load boardRow.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add boardRow.4{r2}, 1
        add dl, 1
        ; move row.2{r1}, row.4{r0}
        mov cx, ax
_for_52:
        ; branch boardRow.2{r2} lt 4: for_52_body
        cmp dl, 4
        jb _for_52_body
        ; call presentBoard[]
        call _presentBoard
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void animateSlide
        ;   rsp+48: var remaining.2
        ;   rsp+50: var source.2
_animateSlide:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const frame.1{r6}, 1
        mov bx, 1
        ; 314:2 for frame <= 8
        jmp _for_54
_for_54_body:
        ; const remaining.1{r0}, 8
        mov ax, 8
        ; sub remaining.2{r0}, frame.2{r6}
        sub ax, bx
        ; addrof memVarAddr{r7}, remaining.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], remaining.2{r0}
        mov [r12], ax
        ; call clearBoard[]
        call _clearBoard
        ; const source.1{r0}, 0
        mov al, 0
        ; 318:3 for source < 16
        jmp _for_55
_for_55_body:
        ; cast t.12.1{r4}(i64), source.2{r0}(u8)
        movzx r9, al
        ; addrof t.11.1{r5}, moveTiles
        lea r10, [var_2]
        ; add t.11.2{r5}, t.12.1{r4}
        add r10, r9
        ; load exponent.1{r3}, [t.11.2{r5}]
        mov r8b, [r10]
        ; 320:4 if exponent == 0
        ; branch exponent.1{r3} notequals 0: if_56_end
        cmp r8b, 0
        jne _if_56_end
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], source.2{r0}
        mov [r12], al
        jmp _for_55_continue
_if_56_end:
        ; cast t.14.1{r4}(i64), source.2{r0}(u8)
        movzx r9, al
        ; addrof t.13.1{r5}, moveTargets
        lea r10, [var_3]
        ; add t.13.2{r5}, t.14.1{r4}
        add r10, r9
        ; load target.1{r4}, [t.13.2{r5}]
        mov r9b, [r10]
        ; move t.16.1{r5}, source.2{r0}
        mov r10b, al
        ; shiftright t.16.1{r5}, 2
        shr r10b, 2
        ; cast t.15.1{r5}(i16), t.16.1{r5}(u8)
        movzx r10w, r10b
        ; shiftleft sourceRow.1{r5}, 2
        sal r10w, 2
        ; move t.18.1{r2}, source.2{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], source.2{r0}
        mov [r12], al
        ; and t.18.1{r2}, 3
        and dl, 3
        ; cast t.17.1{r0}(i16), t.18.1{r2}(u8)
        movzx ax, dl
        ; mul sourceColumn.1{r0}, 9
        movsx rax, ax
        imul  rax, 9
        ; move t.20.1{r2}, target.1{r4}
        mov dl, r9b
        ; shiftright t.20.1{r2}, 2
        shr dl, 2
        ; cast t.19.1{r2}(i16), t.20.1{r2}(u8)
        movzx dx, dl
        ; shiftleft targetRow.1{r2}, 2
        sal dx, 2
        ; and t.22.1{r4}, 3
        and r9b, 3
        ; cast t.21.1{r4}(i16), t.22.1{r4}(u8)
        movzx r9w, r9b
        ; mul targetColumn.1{r4}, 9
        movsx r9, r9w
        imul  r9, 9
        ; addrof memVarAddr{r7}, remaining.2
        lea r12, [rsp+48]
        ; load remaining.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; mul t.24.1{r5}, remaining.2{r1}
        movsx r10, r10w
        movsx rcx, cx
        imul  r10, rcx
        ; mul t.25.1{r2}, frame.2{r6}
        movsx rdx, dx
        movsx rbx, bx
        imul  rdx, rbx
        ; add t.23.1{r5}, t.25.1{r2}
        add r10w, dx
        ; shiftright row.1{r5}, 3
        sar r10w, 3
        ; mul t.27.1{r0}, remaining.2{r1}
        movsx rax, ax
        movsx rcx, cx
        imul  rax, rcx
        ; mul t.28.1{r4}, frame.2{r6}
        movsx r9, r9w
        movsx rbx, bx
        imul  r9, rbx
        ; add t.26.1{r0}, t.28.1{r4}
        add ax, r9w
        ; shiftright column.1{r0}, 3
        sar ax, 3
        ; move t.29.1{r1}, row.1{r5}
        mov cx, r10w
        ; add t.29.1{r1}, 3
        add cx, 3
        ; move t.30.1{r2}, column.1{r0}
        mov dx, ax
        ; add t.30.1{r2}, 1
        add dx, 1
        ; call drawTileAt@i16@i16@u8[t.29.1{r1}, t.30.1{r2}, exponent.1{r3}]
        call _drawTileAt@i16@i16@u8
_for_55_continue:
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+50]
        ; load source.2{r0}, [memVarAddr{r7}]
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
        ; move frame.4{r0}, frame.2{r6}
        mov ax, bx
        ; add frame.4{r0}, 1
        add ax, 1
        ; move frame.2{r6}, frame.4{r0}
        mov bx, ax
_for_54:
        ; branch frame.2{r6} lteq 8: for_54_body
        cmp bx, 8
        jle _for_54_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void drawScore
_drawScore:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const arg.0.0{r1}, 0
        mov cx, 0
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-15]
        lea rcx, [string_15]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r6}, score
        lea rbx, [var_6]
        ; load t.2.1{r1}, [a.1.1{r6}]
        mov ecx, [rbx]
        ; call printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-16]
        lea rcx, [string_16]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void drawStatus
_drawStatus:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const arg.0.0{r1}, 19
        mov cx, 19
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-17]
        lea rcx, [string_17]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 19
        mov cx, 19
        ; const arg.2.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 349:2 if gameState == 1
        ; addrof a.1.1{r6}, gameState
        lea rbx, [var_7]
        ; load t.2.1{r6}, [a.1.1{r6}]
        mov bl, [rbx]
        ; branch t.2.1{r6} equals 1: if_57_then
        cmp bl, 1
        je _if_57_then
        ; 352:7 if gameState == 2
        ; addrof a.4.1{r6}, gameState
        lea rbx, [var_7]
        ; load t.5.1{r6}, [a.4.1{r6}]
        mov bl, [rbx]
        ; branch t.5.1{r6} notequals 2: drawStatus_ret, if_58_then
        cmp bl, 2
        jne _drawStatus_ret
        jmp _if_58_then
_if_57_then:
        ; const t.3.1{r1}, [string-18]
        lea rcx, [string_18]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
_if_58_then:
        ; const t.6.1{r1}, [string-19]
        lea rcx, [string_19]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawStatus_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void newGame
_newGame:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const index.1{r6}, 0
        mov bl, 0
        ; 358:2 for index < 16
        jmp _for_59
_for_59_body:
        ; const t.1.1{r0}, 0
        mov al, 0
        ; cast t.3.1{r1}(i64), index.2{r6}(u8)
        movzx rcx, bl
        ; addrof t.2.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.2.2{r2}, t.3.1{r1}
        add rdx, rcx
        ; store [t.2.2{r2}], t.1.1{r0}
        mov [rdx], al
        ; add index.3{r6}, 1
        add bl, 1
_for_59:
        ; branch index.2{r6} lt 16: for_59_body
        cmp bl, 16
        jb _for_59_body
        ; const t.4.1{r6}, 0
        mov ebx, 0
        ; addrof a.5.1{r0}, score
        lea rax, [var_6]
        ; store [a.5.1{r0}], t.4.1{r6}
        mov [rax], ebx
        ; const t.6.1{r6}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_7]
        ; store [a.7.1{r0}], t.6.1{r6}
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
        mov cx, 21
        ; const arg.5.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.5.0{r1}, arg.5.1{r2}]
        call _setCursor@i16@i16
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void main
        ;   rsp+48: var direction.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.2.1{r6}, 0
        mov ebx, 0
        ; addrof a.3.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.3.1{r0}], t.2.1{r6}
        mov [rax], ebx
        ; addrof a.5.1{r0}, score
        lea rax, [var_6]
        ; store [a.5.1{r0}], t.4.1{r6}
        mov [rax], ebx
        ; const t.6.1{r6}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_7]
        ; store [a.7.1{r0}], t.6.1{r6}
        mov [rax], bl
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call drawFrame[]
        call _drawFrame
        ; call newGame[]
        call _newGame
        ; 375:2 while true
        jmp _while_60
_if_61_end:
        ; branch key.1{r6} equals 114: if_62_then
        cmp bx, 114
        je _if_62_then
        ; branch key.1{r6} equals 82: if_62_then
        cmp bx, 82
        je _if_62_then
        ; 384:3 if gameState != 0
        ; addrof a.8.1{r0}, gameState
        lea rax, [var_7]
        ; load t.9.1{r0}, [a.8.1{r0}]
        mov al, [rax]
        ; branch t.9.1{r0} notequals 0: while_60
        cmp al, 0
        jne _while_60
        ; const direction.1{r0}, 255
        mov al, 255
        ; addrof memVarAddr{r7}, direction.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], direction.1{r0}
        mov [r12], al
        ; 389:3 if key == -8117 || key == 97 || key == 65
        ; branch key.1{r6} equals -8117: if_65_then, or_67
        cmp bx, -8117
        je _if_65_then
        jmp _or_67
_if_62_then:
        ; call newGame[]
        call _newGame
        jmp _while_60
_or_67:
        ; branch key.1{r6} equals 97: if_65_then
        cmp bx, 97
        je _if_65_then
        ; branch key.1{r6} equals 65: if_65_then
        cmp bx, 65
        je _if_65_then
        ; branch key.1{r6} equals -8115: if_68_then
        cmp bx, -8115
        je _if_68_then
        ; branch key.1{r6} equals 100: if_68_then, or_69
        cmp bx, 100
        je _if_68_then
        jmp _or_69
_if_65_then:
        ; const direction.2{r6}, 0
        mov bl, 0
        ; move direction.3{r1}, direction.2{r6}
        mov cl, bl
        jmp _if_65_end
_or_69:
        ; branch key.1{r6} equals 68: if_68_then
        cmp bx, 68
        je _if_68_then
        ; branch key.1{r6} equals -8120: if_71_then
        cmp bx, -8120
        je _if_71_then
        ; branch key.1{r6} equals 119: if_71_then, or_72
        cmp bx, 119
        je _if_71_then
        jmp _or_72
_if_68_then:
        ; const direction.4{r6}, 1
        mov bl, 1
        ; move direction.3{r1}, direction.4{r6}
        mov cl, bl
        jmp _if_65_end
_or_72:
        ; branch key.1{r6} equals 87: if_71_then
        cmp bx, 87
        je _if_71_then
        ; branch key.1{r6} equals -8112: if_74_then
        cmp bx, -8112
        je _if_74_then
        ; branch key.1{r6} equals 115: if_74_then, or_75
        cmp bx, 115
        je _if_74_then
        jmp _or_75
_if_71_then:
        ; const direction.5{r6}, 2
        mov bl, 2
        ; move direction.3{r1}, direction.5{r6}
        mov cl, bl
        jmp _if_65_end
_or_75:
        ; branch key.1{r6} equals 83: if_74_then
        cmp bx, 83
        je _if_74_then
        ; addrof memVarAddr{r7}, direction.1
        lea r12, [rsp+48]
        ; load direction.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; move direction.3{r1}, direction.1{r6}
        mov cl, bl
        jmp _if_65_end
_if_74_then:
        ; const direction.6{r6}, 3
        mov bl, 3
        ; move direction.3{r1}, direction.6{r6}
        mov cl, bl
_if_65_end:
        ; branch direction.3{r1} equals 255: while_60
        cmp cl, 255
        je _while_60
        ; call t.10.1{r0} = slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.10.1{r0} equals 0: while_60
        cmp al, 0
        je _while_60
        ; call animateSlide[]
        call _animateSlide
        ; call spawnTile[]
        call _spawnTile
        ; 407:3 if gameState == 0 && !canMove([])
        ; addrof a.11.1{r6}, gameState
        lea rbx, [var_7]
        ; load t.12.1{r6}, [a.11.1{r6}]
        mov bl, [rbx]
        ; branch t.12.1{r6} notequals 0: if_79_end
        cmp bl, 0
        jne _if_79_end
        ; call t.13.1{r0} = canMove[] -> bool
        call _canMove
        ; branch t.13.1{r0} notequals 0: if_79_end
        cmp al, 0
        jne _if_79_end
        ; const t.14.1{r6}, 2
        mov bl, 2
        ; addrof a.15.1{r0}, gameState
        lea rax, [var_7]
        ; store [a.15.1{r0}], t.14.1{r6}
        mov [rax], bl
_if_79_end:
        ; call drawBoard[]
        call _drawBoard
        ; call drawScore[]
        call _drawScore
        ; 412:3 if gameState != 0
        ; addrof a.16.1{r6}, gameState
        lea rbx, [var_7]
        ; load t.17.1{r6}, [a.16.1{r6}]
        mov bl, [rbx]
        ; branch t.17.1{r6} equals 0: if_81_end
        cmp bl, 0
        je _if_81_end
        ; call drawStatus[]
        call _drawStatus
_if_81_end:
        ; const arg.11.0{r1}, 21
        mov cx, 21
        ; const arg.11.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.11.0{r1}, arg.11.1{r2}]
        call _setCursor@i16@i16
_while_60:
        ; call key.1{r0} = getChar[] -> i16
        call _getChar
        ; move key.1{r6}, key.1{r0}
        mov bx, ax
        ; 377:3 if key == 27
        ; branch key.1{r6} notequals 27: if_61_end
        cmp bx, 27
        jne _if_61_end
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

        ; i16 getChar
_getChar:
        push   rbx
        sub    rsp, 20h
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
        add    rsp, 20h
        pop    rbx
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
        sub  rsp, 28h
        mov  ecx, 20
        call [Sleep]
        add  rsp, 28h
        ret

init:
        sub rsp, 28h
          mov rcx, STD_IN_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdIn]
          mov qword [rcx], rax

          mov rcx, STD_OUT_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdOut]
          mov qword [rcx], rax

          mov rcx, STD_ERR_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdErr]
          mov qword [rcx], rax
        add rsp, 28h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
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

section '.data' data readable
        string_0 db '      ', 0x00
        string_1 db '  2   ', 0x00
        string_2 db '  4   ', 0x00
        string_3 db '  8   ', 0x00
        string_4 db '  16  ', 0x00
        string_5 db '  32  ', 0x00
        string_6 db '  64  ', 0x00
        string_7 db ' 128  ', 0x00
        string_8 db ' 256  ', 0x00
        string_9 db ' 512  ', 0x00
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

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        msvcrt,'MSVCRT.DLL'

import kernel32,\
       ExitProcess,'ExitProcess',\
       GetStdHandle,'GetStdHandle',\
       SetConsoleCursorPosition,'SetConsoleCursorPosition',\
       Sleep,'Sleep',\
       WriteFile,'WriteFile'

import msvcrt,\
       _getch,'_getch'
