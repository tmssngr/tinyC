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
        ; 69:2 for *str != 0
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
        ; 72:9 return length
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
        ; 32:2 for index < exponent
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
        ; 35:9 return value
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
        ; 40:2 for index < 16
        jmp _for_5
_for_5_body:
        ; 41:3 if [...] == 0
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
        ; 50:2 for index < 16
        jmp _for_8
_for_8_body:
        ; 51:3 if [...] != 0
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
        ; 56:4 if random16([]) % 10 == 0
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
        ; 60:4 return
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
        ;   rsp+60: var t.19.1
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
        ; 71:2 for position < 4
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], position.2{r1}
        mov [r12], cl
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
        ; load position.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp _for_12
_for_12_body:
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], position.2{r0}
        mov [r12], al
        ; move source.2{r0}, source.2{r4}
        mov al, r9b
        ; move previousMerged.2{r4}, previousMerged.2{r2}
        mov r9b, dl
        ; move step{r2}, step{r5}
        mov dl, r10b
        ; move moved.2{r5}, moved.2{r3}
        mov r10b, r8b
        ; move target.2{r3}, target.2{r1}
        mov r8b, cl
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
        ; 74:3 if tile != 0
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
        ; 77:4 if target != first && !previousMerged
        ; branch target.2{r3} notequals first{r6}: and_15
        cmp r8b, bl
        jne _and_15
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
        ; 80:5 if *previousTile == tile
        ; load t.16.1{r2}, [previousTile.2{r3}]
        mov dl, [r8]
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch t.16.1{r2} equals tile.1{r1}: if_16_then
        cmp dl, cl
        je _if_16_then
        ; addrof memVarAddr{r7}, previousMerged.4
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], previousMerged.4{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, moved.4
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], moved.4{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, merged.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], merged.2{r0}
        mov [r12], al
        ; move merged.2{r1}, merged.2{r0}
        mov cl, al
        ; move moved.4{r3}, moved.4{r5}
        mov r8b, r10b
        ; addrof memVarAddr{r7}, previousMerged.4
        lea r12, [rsp+55]
        ; move previousMerged.4{r2}, previousMerged.4{r4}
        mov dl, r9b
        jmp _if_14_end
_if_16_then:
        ; move nextTile.1{r0}, tile.1{r1}
        mov al, cl
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], tile.1{r1}
        mov [r12], cl
        ; add nextTile.1{r0}, 1
        add al, 1
        ; store [previousTile.2{r3}], nextTile.1{r0}
        mov [r8], al
        ; addrof a.18.1{r2}, score
        lea rdx, [var_2]
        ; load t.19.1{r2}, [a.18.1{r2}]
        mov edx, [rdx]
        ; addrof memVarAddr{r7}, t.19.1
        lea r12, [rsp+60]
        ; store [memVarAddr{r7}], t.19.1{r2}
        mov [r12], edx
        ; move nextTile.1{r1}, nextTile.1{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, nextTile.1
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], nextTile.1{r0}
        mov [r12], al
        ; call t.20.1{r0} = tileValue@u8[nextTile.1{r1}] -> i32
        call _tileValue@u8
        ; addrof memVarAddr{r7}, t.19.1
        lea r12, [rsp+60]
        ; load t.19.1{r1}, [memVarAddr{r7}]
        mov ecx, [r12]
        ; add t.17.1{r1}, t.20.1{r0}
        add ecx, eax
        ; addrof a.21.1{r2}, score
        lea rdx, [var_2]
        ; store [a.21.1{r2}], t.17.1{r1}
        mov [rdx], ecx
        ; 84:6 if nextTile == 11
        ; addrof memVarAddr{r7}, nextTile.1
        lea r12, [rsp+58]
        ; load nextTile.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch nextTile.1{r1} notequals 11: if_17_end
        cmp cl, 11
        jne _if_17_end
        ; const t.22.1{r1}, 1
        mov cl, 1
        ; addrof a.23.1{r2}, gameState
        lea rdx, [var_3]
        ; store [a.23.1{r2}], t.22.1{r1}
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
        ; cast t.25.1{r2}(i64), target.2{r1}(u8)
        movzx rdx, cl
        ; addrof t.24.1{r4}, tiles
        lea r9, [var_1]
        ; add t.24.2{r4}, t.25.1{r2}
        add r9, rdx
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; store [t.24.2{r4}], tile.1{r2}
        mov [r9], dl
        ; 94:5 if target != source
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
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
        ; load position.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; add position.5{r0}, 1
        add al, 1
_for_12:
        ; branch position.2{r0} lt 4: for_12_body
        cmp al, 4
        jb _for_12_body
        ; 103:9 return moved
        ; move moved.2{r0}, moved.2{r3}
        mov al, r8b
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
        ; const moved.1{r0}, 0
        mov al, 0
        ; const line.1{r3}, 0
        mov r8b, 0
        ; 108:2 for line < 4
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
        jmp _for_20
_for_20_body:
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
        ; 111:3 if direction == 1
        ; branch direction{r6} equals 1: if_21_then
        cmp bl, 1
        je _if_21_then
        ; branch direction{r6} notequals 2: if_22_else, if_22_then
        cmp bl, 2
        jne _if_22_else
        jmp _if_22_then
_if_21_then:
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
        jmp _if_21_end
_if_22_else:
        ; branch direction{r6} notequals 3: slide@u8.no_critical_edge_13, if_23_then
        cmp bl, 3
        jne _slide@u8.no_critical_edge_13
        jmp _if_23_then
_if_22_then:
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
        jmp _if_21_end
_slide@u8.no_critical_edge_13:
        ; move first.3{r1}, first.1{r3}
        mov cl, r8b
        ; move step.3{r2}, step.1{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp _if_21_end
_if_23_then:
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
_if_21_end:
        ; 123:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=3, scope=function, type=u8, varIsArray=false, location=123:17], ExprVarAccess[varName=step, index=4, scope=function, type=u8, varIsArray=false, location=123:24]])
        ; call t.5.1{r0} = slideLine@u8@u8[first.3{r1}, step.3{r2}] -> bool
        call _slideLine@u8@u8
        ; branch t.5.1{r0} notequals 0: if_24_then
        cmp al, 0
        jne _if_24_then
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; load moved.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move moved.4{r1}, moved.2{r0}
        mov cl, al
        jmp _for_20_continue
_if_24_then:
        ; const moved.5{r1}, 1
        mov cl, 1
_for_20_continue:
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; load line.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add line.5{r2}, 1
        add dl, 1
        ; move moved.2{r0}, moved.4{r1}
        mov al, cl
_for_20:
        ; branch line.2{r2} lt 4: for_20_body
        cmp dl, 4
        jb _for_20_body
        ; 127:9 return moved
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
        ; 131:2 for index < 16
        jmp _for_25
_for_25_body:
        ; cast t.3.1{r2}(i64), index.2{r1}(u8)
        movzx rdx, cl
        ; addrof t.2.1{r3}, tiles
        lea r8, [var_1]
        ; add t.2.2{r3}, t.3.1{r2}
        add r8, rdx
        ; load tile.1{r2}, [t.2.2{r3}]
        mov dl, [r8]
        ; 133:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_26_then
        cmp dl, 0
        je _if_26_then
        ; 136:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r3}, index.2{r1}
        mov r8b, cl
        ; and t.4.1{r3}, 3
        and r8b, 3
        ; branch t.4.1{r3} equals 3: if_27_end
        cmp r8b, 3
        je _if_27_end
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
        ; branch t.5.1{r3} equals tile.1{r2}: if_27_then, if_27_end
        cmp r8b, dl
        je _if_27_then
_if_27_end:
        ; branch index.2{r1} gteq 12: for_25_continue
        cmp cl, 12
        jae _for_25_continue
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
        ; branch t.9.1{r3} equals tile.1{r2}: if_29_then, for_25_continue
        cmp r8b, dl
        je _if_29_then
_for_25_continue:
        ; add index.5{r1}, 1
        add cl, 1
_for_25:
        ; branch index.2{r1} lt 16: for_25_body
        cmp cl, 16
        jb _for_25_body
        ; const {r0}, 0
        mov al, 0
        jmp _canMove_ret
_if_26_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
_if_27_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
_if_29_then:
        ; const {r0}, 1
        mov al, 1
_canMove_ret:
        add rsp, 8
        ret

        ; void printTile@u8
        ;   rsp+48: arg exponent
_printTile@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move exponent{r6}, exponent{r1}
        mov bl, cl
        ; branch exponent{r6} equals 0: if_31_then
        cmp bl, 0
        je _if_31_then
        ; branch exponent{r6} notequals 1: if_32_else, if_32_then
        cmp bl, 1
        jne _if_32_else
        jmp _if_32_then
_if_31_then:
        ; const t.1.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.1.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_32_else:
        ; branch exponent{r6} notequals 2: if_33_else, if_33_then
        cmp bl, 2
        jne _if_33_else
        jmp _if_33_then
_if_32_then:
        ; const t.2.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_33_else:
        ; branch exponent{r6} notequals 3: if_34_else, if_34_then
        cmp bl, 3
        jne _if_34_else
        jmp _if_34_then
_if_33_then:
        ; const t.3.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_34_else:
        ; branch exponent{r6} notequals 4: if_35_else, if_35_then
        cmp bl, 4
        jne _if_35_else
        jmp _if_35_then
_if_34_then:
        ; const t.4.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.4.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_35_else:
        ; branch exponent{r6} notequals 5: if_36_else, if_36_then
        cmp bl, 5
        jne _if_36_else
        jmp _if_36_then
_if_35_then:
        ; const t.5.1{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.5.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_36_else:
        ; branch exponent{r6} notequals 6: if_37_else, if_37_then
        cmp bl, 6
        jne _if_37_else
        jmp _if_37_then
_if_36_then:
        ; const t.6.1{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_37_else:
        ; branch exponent{r6} notequals 7: if_38_else, if_38_then
        cmp bl, 7
        jne _if_38_else
        jmp _if_38_then
_if_37_then:
        ; const t.7.1{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_38_else:
        ; branch exponent{r6} notequals 8: if_39_else, if_39_then
        cmp bl, 8
        jne _if_39_else
        jmp _if_39_then
_if_38_then:
        ; const t.8.1{r1}, [string-7]
        lea rcx, [string_7]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_39_else:
        ; branch exponent{r6} notequals 9: if_40_else, if_40_then
        cmp bl, 9
        jne _if_40_else
        jmp _if_40_then
_if_39_then:
        ; const t.9.1{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString@@u8[t.9.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_40_else:
        ; branch exponent{r6} notequals 10: if_41_else, if_41_then
        cmp bl, 10
        jne _if_41_else
        jmp _if_41_then
_if_40_then:
        ; const t.10.1{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_41_else:
        ; branch exponent{r6} notequals 11: if_42_else, if_42_then
        cmp bl, 11
        jne _if_42_else
        jmp _if_42_then
_if_41_then:
        ; const t.11.1{r1}, [string-10]
        lea rcx, [string_10]
        ; call printString@@u8[t.11.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_42_else:
        ; const t.13.1{r1}, [string-12]
        lea rcx, [string_12]
        ; call printString@@u8[t.13.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_42_then:
        ; const t.12.1{r1}, [string-11]
        lea rcx, [string_11]
        ; call printString@@u8[t.12.1{r1}]
        call _printString@@u8
_printTile@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void drawFrame
_drawFrame:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const arg.0.0{r1}, 1
        mov cx, 1
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.2.1{r1}, [string-13]
        lea rcx, [string_13]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; const row.1{r6}, 3
        mov bx, 3
        ; const index.1{r7}, 0
        mov r12b, 0
        ; 196:2 for index < 4
        jmp _for_43
_for_43_body:
        ; move row.2{r1}, row.2{r6}
        mov cx, bx
        ; const arg.2.1{r2}, 1
        mov dx, 1
        ; call setCursor@i16@i16[row.2{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; const t.3.1{r1}, [string-14]
        lea rcx, [string_14]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; move t.4.1{r1}, row.2{r6}
        mov cx, bx
        ; add t.4.1{r1}, 1
        add cx, 1
        ; const arg.4.1{r2}, 1
        mov dx, 1
        ; call setCursor@i16@i16[t.4.1{r1}, arg.4.1{r2}]
        call _setCursor@i16@i16
        ; const t.5.1{r1}, [string-15]
        lea rcx, [string_15]
        ; call printString@@u8[t.5.1{r1}]
        call _printString@@u8
        ; move t.6.1{r1}, row.2{r6}
        mov cx, bx
        ; add t.6.1{r1}, 2
        add cx, 2
        ; const arg.6.1{r2}, 1
        mov dx, 1
        ; call setCursor@i16@i16[t.6.1{r1}, arg.6.1{r2}]
        call _setCursor@i16@i16
        ; const t.7.1{r1}, [string-15]
        lea rcx, [string_15]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; add row.3{r6}, 3
        add bx, 3
        ; add index.3{r7}, 1
        add r12b, 1
_for_43:
        ; branch index.2{r7} lt 4: for_43_body
        cmp r12b, 4
        jb _for_43_body
        ; move row.2{r1}, row.2{r6}
        mov cx, bx
        ; const arg.8.1{r2}, 1
        mov dx, 1
        ; call setCursor@i16@i16[row.2{r1}, arg.8.1{r2}]
        call _setCursor@i16@i16
        ; const t.8.1{r1}, [string-14]
        lea rcx, [string_14]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
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
        ; const index.1{r6}, 0
        mov bl, 0
        ; const row.1{r0}, 5
        mov ax, 5
        ; const boardRow.1{r3}, 0
        mov r8b, 0
        ; 212:2 for boardRow < 4
        ; move row.2{r1}, row.1{r0}
        mov cx, ax
        ; move boardRow.2{r0}, boardRow.1{r3}
        mov al, r8b
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r0}
        mov [r12], al
        ; move boardRow.2{r2}, boardRow.2{r0}
        mov dl, al
        jmp _for_44
_for_44_body:
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r2}
        mov [r12], dl
        ; const column.1{r0}, 2
        mov ax, 2
        ; const boardColumn.1{r3}, 0
        mov r8b, 0
        ; 214:3 for boardColumn < 4
        ; move column.2{r2}, column.1{r0}
        mov dx, ax
        ; move boardColumn.2{r0}, boardColumn.1{r3}
        mov al, r8b
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
        jmp _for_45
_for_45_body:
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], boardColumn.2{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], column.2{r2}
        mov [r12], dx
        ; call setCursor@i16@i16[row.2{r1}, column.2{r2}]
        call _setCursor@i16@i16
        ; cast t.7.1{r0}(i64), index.3{r6}(u8)
        movzx rax, bl
        ; addrof t.6.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.6.2{r2}, t.7.1{r0}
        add rdx, rax
        ; load t.5.1{r1}, [t.6.2{r2}]
        mov cl, [rdx]
        ; call printTile@u8[t.5.1{r1}]
        call _printTile@u8
        ; move index.4{r0}, index.3{r6}
        mov al, bl
        ; add index.4{r0}, 1
        add al, 1
        ; load column.2{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; move column.3{r1}, column.2{r2}
        mov cx, dx
        ; add column.3{r1}, 9
        add cx, 9
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; load boardColumn.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; add boardColumn.3{r3}, 1
        add r8b, 1
        ; move index.3{r6}, index.4{r0}
        mov bl, al
        ; move column.2{r2}, column.3{r1}
        mov dx, cx
_for_45:
        ; branch boardColumn.2{r3} lt 4: for_45_body
        cmp r8b, 4
        jb _for_45_body
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; move row.4{r0}, row.2{r1}
        mov ax, cx
        ; add row.4{r0}, 3
        add ax, 3
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; load boardRow.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; add boardRow.4{r2}, 1
        add dl, 1
        ; move row.2{r1}, row.4{r0}
        mov cx, ax
_for_44:
        ; branch boardRow.2{r2} lt 4: for_44_body
        cmp dl, 4
        jb _for_44_body
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
        ; const t.0.1{r1}, [string-16]
        lea rcx, [string_16]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r6}, score
        lea rbx, [var_2]
        ; load t.2.1{r1}, [a.1.1{r6}]
        mov ecx, [rbx]
        ; call printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-17]
        lea rcx, [string_17]
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
        ; const arg.0.0{r1}, 18
        mov cx, 18
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-18]
        lea rcx, [string_18]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 18
        mov cx, 18
        ; const arg.2.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 235:2 if gameState == 1
        ; addrof a.1.1{r6}, gameState
        lea rbx, [var_3]
        ; load t.2.1{r6}, [a.1.1{r6}]
        mov bl, [rbx]
        ; branch t.2.1{r6} equals 1: if_46_then
        cmp bl, 1
        je _if_46_then
        ; 238:7 if gameState == 2
        ; addrof a.4.1{r6}, gameState
        lea rbx, [var_3]
        ; load t.5.1{r6}, [a.4.1{r6}]
        mov bl, [rbx]
        ; branch t.5.1{r6} notequals 2: drawStatus_ret, if_47_then
        cmp bl, 2
        jne _drawStatus_ret
        jmp _if_47_then
_if_46_then:
        ; const t.3.1{r1}, [string-19]
        lea rcx, [string_19]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
_if_47_then:
        ; const t.6.1{r1}, [string-20]
        lea rcx, [string_20]
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
        ; 244:2 for index < 16
        jmp _for_48
_for_48_body:
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
_for_48:
        ; branch index.2{r6} lt 16: for_48_body
        cmp bl, 16
        jb _for_48_body
        ; const t.4.1{r6}, 0
        mov ebx, 0
        ; addrof a.5.1{r0}, score
        lea rax, [var_2]
        ; store [a.5.1{r0}], t.4.1{r6}
        mov [rax], ebx
        ; const t.6.1{r6}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_3]
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
        lea rax, [var_2]
        ; store [a.5.1{r0}], t.4.1{r6}
        mov [rax], ebx
        ; const t.6.1{r6}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_3]
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
        ; 261:2 while true
        jmp _while_49
_if_50_end:
        ; branch key.1{r6} equals 114: if_51_then
        cmp bx, 114
        je _if_51_then
        ; branch key.1{r6} equals 82: if_51_then
        cmp bx, 82
        je _if_51_then
        ; 270:3 if gameState != 0
        ; addrof a.8.1{r0}, gameState
        lea rax, [var_3]
        ; load t.9.1{r0}, [a.8.1{r0}]
        mov al, [rax]
        ; branch t.9.1{r0} notequals 0: while_49
        cmp al, 0
        jne _while_49
        ; const direction.1{r0}, 255
        mov al, 255
        ; addrof memVarAddr{r7}, direction.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], direction.1{r0}
        mov [r12], al
        ; 275:3 if key == -8117 || key == 97 || key == 65
        ; branch key.1{r6} equals -8117: if_54_then, or_56
        cmp bx, -8117
        je _if_54_then
        jmp _or_56
_if_51_then:
        ; call newGame[]
        call _newGame
        jmp _while_49
_or_56:
        ; branch key.1{r6} equals 97: if_54_then
        cmp bx, 97
        je _if_54_then
        ; branch key.1{r6} equals 65: if_54_then
        cmp bx, 65
        je _if_54_then
        ; branch key.1{r6} equals -8115: if_57_then
        cmp bx, -8115
        je _if_57_then
        ; branch key.1{r6} equals 100: if_57_then, or_58
        cmp bx, 100
        je _if_57_then
        jmp _or_58
_if_54_then:
        ; const direction.2{r6}, 0
        mov bl, 0
        ; move direction.3{r1}, direction.2{r6}
        mov cl, bl
        jmp _if_54_end
_or_58:
        ; branch key.1{r6} equals 68: if_57_then
        cmp bx, 68
        je _if_57_then
        ; branch key.1{r6} equals -8120: if_60_then
        cmp bx, -8120
        je _if_60_then
        ; branch key.1{r6} equals 119: if_60_then, or_61
        cmp bx, 119
        je _if_60_then
        jmp _or_61
_if_57_then:
        ; const direction.4{r6}, 1
        mov bl, 1
        ; move direction.3{r1}, direction.4{r6}
        mov cl, bl
        jmp _if_54_end
_or_61:
        ; branch key.1{r6} equals 87: if_60_then
        cmp bx, 87
        je _if_60_then
        ; branch key.1{r6} equals -8112: if_63_then
        cmp bx, -8112
        je _if_63_then
        ; branch key.1{r6} equals 115: if_63_then, or_64
        cmp bx, 115
        je _if_63_then
        jmp _or_64
_if_60_then:
        ; const direction.5{r6}, 2
        mov bl, 2
        ; move direction.3{r1}, direction.5{r6}
        mov cl, bl
        jmp _if_54_end
_or_64:
        ; branch key.1{r6} equals 83: if_63_then
        cmp bx, 83
        je _if_63_then
        ; addrof memVarAddr{r7}, direction.1
        lea r12, [rsp+48]
        ; load direction.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; move direction.3{r1}, direction.1{r6}
        mov cl, bl
        jmp _if_54_end
_if_63_then:
        ; const direction.6{r6}, 3
        mov bl, 3
        ; move direction.3{r1}, direction.6{r6}
        mov cl, bl
_if_54_end:
        ; branch direction.3{r1} equals 255: while_49
        cmp cl, 255
        je _while_49
        ; call t.10.1{r0} = slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.10.1{r0} equals 0: while_49
        cmp al, 0
        je _while_49
        ; call spawnTile[]
        call _spawnTile
        ; 292:3 if gameState == 0 && !canMove([])
        ; addrof a.11.1{r6}, gameState
        lea rbx, [var_3]
        ; load t.12.1{r6}, [a.11.1{r6}]
        mov bl, [rbx]
        ; branch t.12.1{r6} notequals 0: if_68_end
        cmp bl, 0
        jne _if_68_end
        ; call t.13.1{r0} = canMove[] -> bool
        call _canMove
        ; branch t.13.1{r0} notequals 0: if_68_end
        cmp al, 0
        jne _if_68_end
        ; const t.14.1{r6}, 2
        mov bl, 2
        ; addrof a.15.1{r0}, gameState
        lea rax, [var_3]
        ; store [a.15.1{r0}], t.14.1{r6}
        mov [rax], bl
_if_68_end:
        ; call drawBoard[]
        call _drawBoard
        ; call drawScore[]
        call _drawScore
        ; 297:3 if gameState != 0
        ; addrof a.16.1{r6}, gameState
        lea rbx, [var_3]
        ; load t.17.1{r6}, [a.16.1{r6}]
        mov bl, [rbx]
        ; branch t.17.1{r6} equals 0: if_70_end
        cmp bl, 0
        je _if_70_end
        ; call drawStatus[]
        call _drawStatus
_if_70_end:
        ; const arg.10.0{r1}, 21
        mov cx, 21
        ; const arg.10.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.10.0{r1}, arg.10.1{r2}]
        call _setCursor@i16@i16
_while_49:
        ; call key.1{r0} = getChar[] -> i16
        call _getChar
        ; move key.1{r6}, key.1{r0}
        mov bx, ax
        ; 263:3 if key == 27
        ; branch key.1{r6} notequals 27: if_50_end
        cmp bx, 27
        jne _if_50_end
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
        ; variable 2: score (i32/4)
        var_2 rb 4
        ; variable 3: gameState (u8/1)
        var_3 rb 1

section '.data' data readable
        string_0 db '        ', 0x00
        string_1 db '   2    ', 0x00
        string_2 db '   4    ', 0x00
        string_3 db '   8    ', 0x00
        string_4 db '   16   ', 0x00
        string_5 db '   32   ', 0x00
        string_6 db '   64   ', 0x00
        string_7 db '  128   ', 0x00
        string_8 db '  256   ', 0x00
        string_9 db '  512   ', 0x00
        string_10 db '  1024  ', 0x00
        string_11 db '  2048  ', 0x00
        string_12 db '   ?    ', 0x00
        string_13 db 'Arrows/WASD  R restart  Esc quit', 0x00
        string_14 db '+--------+--------+--------+--------+', 0x00
        string_15 db '|        |        |        |        |', 0x00
        string_16 db '2048  Score: ', 0x00
        string_17 db '          ', 0x00
        string_18 db '                                      ', 0x00
        string_19 db '2048! Press R to play again.', 0x00
        string_20 db 'No moves left. Press R to restart.', 0x00

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        msvcrt,'MSVCRT.DLL'

import kernel32,\
       ExitProcess,'ExitProcess',\
       GetStdHandle,'GetStdHandle',\
       SetConsoleCursorPosition,'SetConsoleCursorPosition',\
       WriteFile,'WriteFile'

import msvcrt,\
       _getch,'_getch'
