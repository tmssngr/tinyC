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

        ; i16 tileValue@u8
        ;   rsp+16: arg exponent
_tileValue@u8:
        sub rsp, 8
        ; const value.1{r2}, 1
        mov dx, 1
        ; const index.1{r3}, 0
        mov r8b, 0
        ; 45:2 for index < exponent
        ; move value.2{r0}, value.1{r2}
        mov ax, dx
        ; move index.2{r2}, index.1{r3}
        mov dl, r8b
        jmp _for_4
_for_4_body:
        ; move value.3{r3}, value.2{r0}
        mov r8w, ax
        ; shiftleft value.3{r3}, 1
        sal r8w, 1
        ; add index.3{r2}, 1
        add dl, 1
        ; move value.2{r0}, value.3{r3}
        mov ax, r8w
_for_4:
        ; branch index.2{r2} lt exponent{r1}: for_4_body
        cmp dl, cl
        jb _for_4_body
        ; 48:9 return value
        add rsp, 8
        ret

        ; u8 spawnTile
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
        ; 53:2 for index < 16
        jmp _for_5
_for_5_body:
        ; 54:3 if [...] == 0
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
        ; branch emptyCount.2{r6} equals 0: if_7_then
        cmp bl, 0
        je _if_7_then
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
        ; const index.3{r1}, 0
        mov cl, 0
        ; 63:2 for index < 16
        jmp _for_8
_for_8_body:
        ; 64:3 if [...] != 0
        ; cast t.13.1{r2}(i64), index.4{r1}(u8)
        movzx rdx, cl
        ; addrof t.12.1{r3}, tiles
        lea r8, [var_1]
        ; add t.12.2{r3}, t.13.1{r2}
        add r8, rdx
        ; load t.11.1{r2}, [t.12.2{r3}]
        mov dl, [r8]
        ; branch t.11.1{r2} notequals 0: for_8_continue
        cmp dl, 0
        jne _for_8_continue
        ; branch chosen.2{r6} equals 0: if_10_then
        cmp bl, 0
        je _if_10_then
        ; sub chosen.4{r6}, 1
        sub bl, 1
_for_8_continue:
        ; add index.8{r1}, 1
        add cl, 1
        jmp _for_8
_if_7_then:
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
_for_8:
        ; branch index.4{r1} gteq 16: for_8_break, for_8_body
        cmp cl, 16
        jae _for_8_break
        ; addrof memVarAddr{r7}, index.4
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], index.4{r1}
        mov [r12], cl
        jmp _for_8_body
_for_8_break:
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
_if_10_then:
        ; addrof memVarAddr{r7}, index.4
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], index.4{r1}
        mov [r12], cl
        ; const tile.1{r6}, 1
        mov bl, 1
        ; 69:4 if random16([]) % 10 == 0
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
        ; move tile.2{r1}, tile.1{r6}
        mov cl, bl
        jmp _if_11_end
_if_11_then:
        ; const tile.3{r1}, 2
        mov cl, 2
_if_11_end:
        ; addrof memVarAddr{r7}, index.4
        lea r12, [rsp+48]
        ; load index.4{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.17.1{r2}(i64), index.4{r0}(u8)
        movzx rdx, al
        ; addrof t.16.1{r3}, tiles
        lea r8, [var_1]
        ; add t.16.2{r3}, t.17.1{r2}
        add r8, rdx
        ; store [t.16.2{r3}], tile.2{r1}
        mov [r8], cl
        ; 73:11 return index
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
        ; cast t.14.1{r1}(i64), source.2{r0}(u8)
        movzx rcx, al
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], source.2{r0}
        mov [r12], al
        ; addrof sourceTile.1{r0}, tiles
        lea rax, [var_1]
        ; add sourceTile.2{r0}, t.14.1{r1}
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
        ; const t.15.1{r1}, 0
        mov cl, 0
        ; store [sourceTile.2{r0}], t.15.1{r1}
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
        ; cast t.16.1{r2}(i64), previous.1{r1}(u8)
        movzx rdx, cl
        ; addrof previousTile.1{r3}, tiles
        lea r8, [var_1]
        ; add previousTile.2{r3}, t.16.1{r2}
        add r8, rdx
        ; 94:5 if *previousTile == tile
        ; load t.17.1{r2}, [previousTile.2{r3}]
        mov dl, [r8]
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch t.17.1{r2} equals tile.1{r6}: if_16_then
        cmp dl, bl
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
        ; move t.18.1{r0}, previous.1{r1}
        mov al, cl
        ; or t.18.1{r0}, 128
        or al, 128
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.20.1{r4}(i64), source.2{r2}(u8)
        movzx r9, dl
        ; addrof t.19.1{r2}, moveTargets
        lea rdx, [var_3]
        ; add t.19.2{r2}, t.20.1{r4}
        add rdx, r9
        ; store [t.19.2{r2}], t.18.1{r0}
        mov [rdx], al
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
        ; addrof memVarAddr{r7}, nextTile.1
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], nextTile.1{r1}
        mov [r12], cl
        ; call t.21.1{r0} = tileValue@u8[nextTile.1{r1}] -> i16
        call _tileValue@u8
        ; cast mergedScore.1{r1}(i32), t.21.1{r0}(i16)
        movsx ecx, ax
        ; addrof a.23.1{r2}, score
        lea rdx, [var_4]
        ; load t.24.1{r2}, [a.23.1{r2}]
        mov edx, [rdx]
        ; add t.22.1{r2}, mergedScore.1{r1}
        add edx, ecx
        ; addrof a.25.1{r1}, score
        lea rcx, [var_4]
        ; store [a.25.1{r1}], t.22.1{r2}
        mov [rcx], edx
        ; 101:6 if nextTile == 11
        ; load nextTile.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch nextTile.1{r1} notequals 11: if_17_end
        cmp cl, 11
        jne _if_17_end
        ; const t.26.1{r1}, 1
        mov cl, 1
        ; addrof a.27.1{r2}, gameState
        lea rdx, [var_5]
        ; store [a.27.1{r2}], t.26.1{r1}
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
        ; cast t.29.1{r2}(i64), source.2{r4}(u8)
        movzx rdx, r9b
        ; addrof t.28.1{r5}, moveTargets
        lea r10, [var_3]
        ; add t.28.2{r5}, t.29.1{r2}
        add r10, rdx
        ; store [t.28.2{r5}], target.2{r1}
        mov [r10], cl
        ; cast t.31.1{r2}(i64), target.2{r1}(u8)
        movzx rdx, cl
        ; addrof t.30.1{r5}, tiles
        lea r10, [var_1]
        ; add t.30.2{r5}, t.31.1{r2}
        add r10, rdx
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; store [t.30.2{r5}], tile.1{r2}
        mov [r10], dl
        ; 112:5 if target != source
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
        ; 121:9 return moved
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
        ; 125:2 for index < 16
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
        ; 130:2 for line < 4
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
        ; 133:3 if direction == 1
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
        ; 145:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=145:16], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=145:23]])
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
        ; 149:9 return moved
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
        ; 153:2 for index < 16
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
        ; 155:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_27_then
        cmp dl, 0
        je _if_27_then
        ; 158:3 if index & 3 != 3 && [...] == tile
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

        ; void printTile@u8
        ;   rsp+48: arg exponent
_printTile@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move exponent{r6}, exponent{r1}
        mov bl, cl
        ; branch exponent{r6} equals 0: if_32_then
        cmp bl, 0
        je _if_32_then
        ; branch exponent{r6} notequals 1: if_33_else, if_33_then
        cmp bl, 1
        jne _if_33_else
        jmp _if_33_then
_if_32_then:
        ; const t.1.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.1.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_33_else:
        ; branch exponent{r6} notequals 2: if_34_else, if_34_then
        cmp bl, 2
        jne _if_34_else
        jmp _if_34_then
_if_33_then:
        ; const t.2.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_34_else:
        ; branch exponent{r6} notequals 3: if_35_else, if_35_then
        cmp bl, 3
        jne _if_35_else
        jmp _if_35_then
_if_34_then:
        ; const t.3.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_35_else:
        ; branch exponent{r6} notequals 4: if_36_else, if_36_then
        cmp bl, 4
        jne _if_36_else
        jmp _if_36_then
_if_35_then:
        ; const t.4.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.4.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_36_else:
        ; branch exponent{r6} notequals 5: if_37_else, if_37_then
        cmp bl, 5
        jne _if_37_else
        jmp _if_37_then
_if_36_then:
        ; const t.5.1{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.5.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_37_else:
        ; branch exponent{r6} notequals 6: if_38_else, if_38_then
        cmp bl, 6
        jne _if_38_else
        jmp _if_38_then
_if_37_then:
        ; const t.6.1{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_38_else:
        ; branch exponent{r6} notequals 7: if_39_else, if_39_then
        cmp bl, 7
        jne _if_39_else
        jmp _if_39_then
_if_38_then:
        ; const t.7.1{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_39_else:
        ; branch exponent{r6} notequals 8: if_40_else, if_40_then
        cmp bl, 8
        jne _if_40_else
        jmp _if_40_then
_if_39_then:
        ; const t.8.1{r1}, [string-7]
        lea rcx, [string_7]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_40_else:
        ; branch exponent{r6} notequals 9: if_41_else, if_41_then
        cmp bl, 9
        jne _if_41_else
        jmp _if_41_then
_if_40_then:
        ; const t.9.1{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString@@u8[t.9.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_41_else:
        ; branch exponent{r6} notequals 10: if_42_else, if_42_then
        cmp bl, 10
        jne _if_42_else
        jmp _if_42_then
_if_41_then:
        ; const t.10.1{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_42_else:
        ; branch exponent{r6} notequals 11: if_43_else, if_43_then
        cmp bl, 11
        jne _if_43_else
        jmp _if_43_then
_if_42_then:
        ; const t.11.1{r1}, [string-10]
        lea rcx, [string_10]
        ; call printString@@u8[t.11.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_43_else:
        ; const t.13.1{r1}, [string-12]
        lea rcx, [string_12]
        ; call printString@@u8[t.13.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
_if_43_then:
        ; const t.12.1{r1}, [string-11]
        lea rcx, [string_11]
        ; call printString@@u8[t.12.1{r1}]
        call _printString@@u8
_printTile@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void drawTileAt@i16@i16@u8
        ;   rsp+64: arg row
        ;   rsp+72: arg column
        ;   rsp+80: arg exponent
_drawTileAt@i16@i16@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bx, cx
        ; branch exponent{r3} notequals 0: if_44_end, drawTileAt@i16@i16@u8_ret
        cmp r8b, 0
        jne _if_44_end
        ; addrof memVarAddr{r7}, exponent
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], exponent{r3}
        mov [r12], r8b
        jmp _drawTileAt@i16@i16@u8_ret
_if_44_end:
        ; addrof memVarAddr{r7}, exponent
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], exponent{r3}
        mov [r12], r8b
        ; move row{r1}, row{r6}
        mov cx, bx
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r2}
        mov [r12], dx
        ; call setCursor@i16@i16[row{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.3.1{r1}, [string-13]
        lea rcx, [string_13]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; move t.4.1{r1}, row{r6}
        mov cx, bx
        ; add t.4.1{r1}, 1
        add cx, 1
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; call setCursor@i16@i16[t.4.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const arg.3.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; addrof memVarAddr{r7}, exponent
        lea r12, [rsp+80]
        ; load exponent{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move exponent{r1}, exponent{r3}
        mov cl, r8b
        ; call printTile@u8[exponent{r1}]
        call _printTile@u8
        ; const arg.5.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.5.0{r1}]
        call _printChar@u8
        ; move t.5.1{r1}, row{r6}
        mov cx, bx
        ; add t.5.1{r1}, 2
        add cx, 2
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; call setCursor@i16@i16[t.5.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.6.1{r1}, [string-13]
        lea rcx, [string_13]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawTileAt@i16@i16@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; u8 tileRow@u8
        ;   rsp+16: arg index
_tileRow@u8:
        sub rsp, 8
        ; 226:19 return index & 12 + 3
        ; and t.2.1{r1}, 12
        and cl, 12
        ; move t.1.1{r0}, t.2.1{r1}
        mov al, cl
        ; add t.1.1{r0}, 3
        add al, 3
        add rsp, 8
        ret

        ; u8 tileColumn@u8
        ;   rsp+16: arg index
_tileColumn@u8:
        sub rsp, 8
        ; and column.1{r1}, 3
        and cl, 3
        ; 231:36 return column << 3 + 1 + column
        ; move t.4.1{r2}, column.1{r1}
        mov dl, cl
        ; shiftleft t.4.1{r2}, 3
        shl dl, 3
        ; add t.3.1{r2}, 1
        add dl, 1
        ; move t.2.1{r0}, t.3.1{r2}
        mov al, dl
        ; add t.2.1{r0}, column.1{r1}
        add al, cl
        add rsp, 8
        ret

        ; void clearTileTrail@u8@u8@u8@u8
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+96: arg direction
        ;   rsp+104: arg distance
        ;   rsp+48: var column.3
        ;   rsp+49: var height.5
        ;   rsp+56: var spaces.2
        ;   rsp+64: var row.5
_clearTileTrail@u8@u8@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const width.1{r6}, 8
        mov bl, 8
        ; const height.1{r0}, 3
        mov al, 3
        ; 237:2 if direction < 2
        ; branch direction{r3} lt 2: if_45_then
        cmp r8b, 2
        jb _if_45_then
        ; branch distance{r4} gteq height.1{r0}: if_48_end, if_48_then
        cmp r9b, al
        jae _if_48_end
        jmp _if_48_then
_if_45_then:
        ; branch distance{r4} gteq width.1{r6}: if_46_end, if_46_then
        cmp r9b, bl
        jae _if_46_end
        jmp _if_46_then
_if_48_then:
        ; move height.3{r0}, distance{r4}
        mov al, r9b
        jmp _if_48_end
_if_46_then:
        ; move width.4{r6}, distance{r4}
        mov bl, r9b
        jmp _if_46_end
_if_48_end:
        ; branch direction{r3} notequals 2: clearTileTrail@u8@u8@u8@u8.no_critical_edge_15, if_49_then
        cmp r8b, 2
        jne _clearTileTrail@u8@u8@u8@u8.no_critical_edge_15
        jmp _if_49_then
_if_46_end:
        ; branch direction{r3} notequals 0: clearTileTrail@u8@u8@u8@u8.no_critical_edge_17, if_47_then
        cmp r8b, 0
        jne _clearTileTrail@u8@u8@u8@u8.no_critical_edge_17
        jmp _if_47_then
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_15:
        ; move row.3{r3}, row{r1}
        mov r8b, cl
        ; move column.3{r4}, column{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], height.5{r0}
        mov [r12], al
        jmp _if_45_end
_if_49_then:
        ; const t.11.1{r3}, 3
        mov r8b, 3
        ; sub t.10.1{r3}, height.2{r0}
        sub r8b, al
        ; move row.4{r4}, row{r1}
        mov r9b, cl
        ; add row.4{r4}, t.10.1{r3}
        add r9b, r8b
        ; move row.3{r3}, row.4{r4}
        mov r8b, r9b
        ; move column.3{r4}, column{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], height.5{r0}
        mov [r12], al
        jmp _if_45_end
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_17:
        ; move row.3{r3}, row{r1}
        mov r8b, cl
        ; move column.3{r4}, column{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], height.5{r0}
        mov [r12], al
        jmp _if_45_end
_if_47_then:
        ; const t.9.1{r3}, 8
        mov r8b, 8
        ; sub t.8.1{r3}, width.3{r6}
        sub r8b, bl
        ; move column.4{r4}, column{r2}
        mov r9b, dl
        ; add column.4{r4}, t.8.1{r3}
        add r9b, r8b
        ; move row.3{r3}, row{r1}
        mov r8b, cl
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], height.5{r0}
        mov [r12], al
_if_45_end:
        ; const spaces.1{r0}, [string-14]
        lea rax, [string_14]
        ; const t.14.1{r5}, 8
        mov r10b, 8
        ; sub t.13.1{r5}, width.5{r6}
        sub r10b, bl
        ; cast t.12.1{r6}(i64), t.13.1{r5}(u8)
        movzx rbx, r10b
        ; move spaces.2{r1}, spaces.1{r0}
        mov rcx, rax
        ; add spaces.2{r1}, t.12.1{r6}
        add rcx, rbx
        ; addrof memVarAddr{r7}, spaces.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], spaces.2{r1}
        mov [r12], rcx
        ; const line.1{r6}, 0
        mov bl, 0
        ; 255:2 for line < height
        ; move row.5{r0}, row.3{r3}
        mov al, r8b
        ; addrof memVarAddr{r7}, column.3
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], column.3{r4}
        mov [r12], r9b
        jmp _for_50
_for_50_body:
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], height.5{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, column.3
        lea r12, [rsp+48]
        ; load column.3{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; cast t.15.1{r1}(i16), row.5{r0}(u8)
        movzx cx, al
        ; addrof memVarAddr{r7}, row.5
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row.5{r0}
        mov [r12], al
        ; cast t.16.1{r2}(i16), column.3{r4}(u8)
        movzx dx, r9b
        ; call setCursor@i16@i16[t.15.1{r1}, t.16.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r7}, spaces.2
        lea r12, [rsp+56]
        ; load spaces.2{r1}, [memVarAddr{r7}]
        mov rcx, [r12]
        ; call printString@@u8[spaces.2{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r7}, row.5
        lea r12, [rsp+64]
        ; load row.5{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; add row.6{r0}, 1
        add al, 1
        ; move line.3{r1}, line.2{r6}
        mov cl, bl
        ; add line.3{r1}, 1
        add cl, 1
        ; move line.2{r6}, line.3{r1}
        mov bl, cl
_for_50:
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+49]
        ; load height.5{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch line.2{r6} lt height.5{r1}: for_50_body
        cmp bl, cl
        jb _for_50_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool drawMoveFrame@u8@u8@u8@bool
        ;   rsp+80: arg direction
        ;   rsp+88: arg previous
        ;   rsp+96: arg travel
        ;   rsp+104: arg erase
        ;   rsp+48: var horizontal.1
        ;   rsp+49: var forward.1
        ;   rsp+50: var count.2
        ;   rsp+51: var index.2
        ;   rsp+52: var exponent.1
        ;   rsp+53: var target.1
        ;   rsp+54: var distance.4
        ;   rsp+55: var oldOffset.2
        ;   rsp+56: var pending.9
        ;   rsp+57: var offset.2
        ;   rsp+58: var column.3
        ;   rsp+60: var t.52.1
_drawMoveFrame@u8@u8@u8@bool:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move direction{r6}, direction{r1}
        mov bl, cl
        ; lt horizontal.1{r0}, direction{r6}, 2
        cmp bl, 2
        setb al
        ; move t.17.1{r5}, direction{r6}
        mov r10b, bl
        ; and t.17.1{r5}, 1
        and r10b, 1
        ; notequals forward.1{r5}, t.17.1{r5}, 0
        cmp r10b, 0
        setne r10b
        ; const pending.1{r1}, 0
        mov cl, 0
        ; addrof memVarAddr{r7}, direction
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], direction{r6}
        mov [r12], bl
        ; const count.1{r6}, 0
        mov bl, 0
        ; 267:2 for count < 16
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], previous{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, travel
        lea r12, [rsp+96]
        ; store [memVarAddr{r7}], travel{r3}
        mov [r12], r8b
        ; move pending.2{r0}, pending.2{r1}
        mov al, cl
        ; move count.2{r1}, count.2{r6}
        mov cl, bl
        jmp _for_51
_for_51_body:
        ; move count.2{r6}, count.2{r1}
        mov bl, cl
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; load forward.1{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; move pending.2{r1}, pending.2{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; load previous{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, travel
        lea r12, [rsp+96]
        ; load travel{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; load horizontal.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; move index.1{r4}, count.2{r6}
        mov r9b, bl
        ; 269:3 if !forward
        ; branch forward.1{r5} notequals 0: if_52_end
        cmp r10b, 0
        jne _if_52_end
        ; const t.18.1{r4}, 15
        mov r9b, 15
        ; sub index.3{r4}, count.2{r6}
        sub r9b, bl
_if_52_end:
        ; addrof memVarAddr{r7}, count.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], count.2{r6}
        mov [r12], bl
        ; cast t.20.1{r6}(i64), index.2{r4}(u8)
        movzx rbx, r9b
        ; addrof memVarAddr{r7}, travel
        lea r12, [rsp+96]
        ; store [memVarAddr{r7}], travel{r3}
        mov [r12], r8b
        ; addrof t.19.1{r3}, moveTiles
        lea r8, [var_2]
        ; add t.19.2{r3}, t.20.1{r6}
        add r8, rbx
        ; load exponent.1{r3}, [t.19.2{r3}]
        mov r8b, [r8]
        ; 274:3 if exponent == 0
        ; branch exponent.1{r3} notequals 0: if_53_end
        cmp r8b, 0
        jne _if_53_end
        ; move pending.4{r6}, pending.2{r1}
        mov bl, cl
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], previous{r2}
        mov [r12], dl
        jmp _for_51_continue
_if_53_end:
        ; cast t.23.1{r6}(i64), index.2{r4}(u8)
        movzx rbx, r9b
        ; addrof memVarAddr{r7}, exponent.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], exponent.1{r3}
        mov [r12], r8b
        ; addrof t.22.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.22.2{r3}, t.23.1{r6}
        add r8, rbx
        ; load t.21.1{r6}, [t.22.2{r3}]
        mov bl, [r8]
        ; and target.1{r6}, 15
        and bl, 15
        ; move distance.1{r3}, index.2{r4}
        mov r8b, r9b
        ; sub distance.1{r3}, target.1{r6}
        sub r8b, bl
        ; 280:3 if forward
        ; branch forward.1{r5} equals 0: if_54_end
        cmp r10b, 0
        je _if_54_end
        ; move distance.3{r3}, target.1{r6}
        mov r8b, bl
        ; sub distance.3{r3}, index.2{r4}
        sub r8b, r9b
_if_54_end:
        ; branch horizontal.1{r0} notequals 0: if_55_then
        cmp al, 0
        jne _if_55_then
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        jmp _if_55_end
_if_55_then:
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        ; move t.24.1{r0}, distance.2{r3}
        mov al, r8b
        ; shiftleft t.24.1{r0}, 3
        shl al, 3
        ; add distance.5{r3}, t.24.1{r0}
        add r8b, al
_if_55_end:
        ; move oldOffset.1{r0}, previous{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], previous{r2}
        mov [r12], dl
        ; 289:3 if oldOffset > distance
        ; branch oldOffset.1{r0} lteq distance.4{r3}: if_56_end
        cmp al, r8b
        jbe _if_56_end
        ; move oldOffset.3{r0}, distance.4{r3}
        mov al, r8b
_if_56_end:
        ; addrof memVarAddr{r7}, travel
        lea r12, [rsp+96]
        ; load travel{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], index.2{r4}
        mov [r12], r9b
        ; move travel{r4}, travel{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, travel
        lea r12, [rsp+96]
        ; 295:3 if offset >= distance
        ; branch offset.1{r2} gteq distance.4{r3}: if_57_then
        cmp dl, r8b
        jae _if_57_then
        ; const pending.8{r4}, 1
        mov r9b, 1
        ; addrof memVarAddr{r7}, distance.4
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], distance.4{r3}
        mov [r12], r8b
        jmp _if_57_end
_if_57_then:
        ; move offset.3{r2}, distance.4{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, distance.4
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], distance.4{r3}
        mov [r12], r8b
        ; move pending.9{r4}, pending.2{r1}
        mov r9b, cl
_if_57_end:
        ; branch oldOffset.2{r0} equals offset.2{r2}: and_59
        cmp al, dl
        je _and_59
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], pending.9{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; load erase{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        jmp _if_58_end
_and_59:
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; load erase{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch erase{r3} equals 0: or_60
        cmp r8b, 0
        je _or_60
        ; move pending.4{r6}, pending.9{r4}
        mov bl, r9b
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        jmp _for_51_continue
_or_60:
        ; cast t.27.1{r1}(i64), target.1{r6}(u8)
        movzx rcx, bl
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r6}
        mov [r12], bl
        ; addrof t.26.1{r6}, tiles
        lea rbx, [var_1]
        ; add t.26.2{r6}, t.27.1{r1}
        add rbx, rcx
        ; load t.25.1{r6}, [t.26.2{r6}]
        mov bl, [rbx]
        ; addrof memVarAddr{r7}, exponent.1
        lea r12, [rsp+52]
        ; load exponent.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch exponent.1{r1} notequals t.25.1{r6}: drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        cmp cl, bl
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        ; move pending.4{r6}, pending.9{r4}
        mov bl, r9b
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        jmp _for_51_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46:
        ; addrof memVarAddr{r7}, exponent.1
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], exponent.1{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], pending.9{r4}
        mov [r12], r9b
_if_58_end:
        ; move displacement.1{r6}, offset.2{r2}
        mov bl, dl
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], offset.2{r2}
        mov [r12], dl
        ; 307:3 if erase
        ; branch erase{r3} notequals 0: if_61_then
        cmp r8b, 0
        jne _if_61_then
        ; addrof memVarAddr{r7}, oldOffset.2
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], oldOffset.2{r0}
        mov [r12], al
        jmp _if_61_end
_if_61_then:
        ; move displacement.3{r6}, oldOffset.2{r0}
        mov bl, al
        ; addrof memVarAddr{r7}, oldOffset.2
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], oldOffset.2{r0}
        mov [r12], al
_if_61_end:
        ; branch forward.1{r5} notequals 0: drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41, if_62_then
        cmp r10b, 0
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        jmp _if_62_then
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41:
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        jmp _if_62_end
_if_62_then:
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r5}
        mov [r12], r10b
        ; const t.28.1{r0}, 0
        mov al, 0
        ; sub displacement.5{r0}, displacement.2{r6}
        sub al, bl
        ; move displacement.4{r6}, displacement.5{r0}
        mov bl, al
_if_62_end:
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; load index.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.29.1{r4}, index.2{r0}
        mov r9b, al
        ; and t.29.1{r4}, 12
        and r9b, 12
        ; add row.1{r4}, 3
        add r9b, 3
        ; move column.1{r5}, index.2{r0}
        mov r10b, al
        ; and column.1{r5}, 3
        and r10b, 3
        ; move t.31.1{r0}, column.1{r5}
        mov al, r10b
        ; shiftleft t.31.1{r0}, 3
        shl al, 3
        ; add t.30.1{r0}, 1
        add al, 1
        ; add column.2{r5}, t.30.1{r0}
        add r10b, al
        ; 319:3 if horizontal
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; load horizontal.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch horizontal.1{r0} notequals 0: if_63_then
        cmp al, 0
        jne _if_63_then
        ; move row.2{r0}, row.1{r4}
        mov al, r9b
        ; add row.2{r0}, displacement.4{r6}
        add al, bl
        ; move row.3{r6}, row.2{r0}
        mov bl, al
        ; move column.3{r2}, column.2{r5}
        mov dl, r10b
        jmp _if_63_end
_if_63_then:
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        ; move column.4{r0}, column.2{r5}
        mov al, r10b
        ; add column.4{r0}, displacement.4{r6}
        add al, bl
        ; move row.3{r6}, row.1{r4}
        mov bl, r9b
        ; move column.3{r2}, column.4{r0}
        mov dl, al
_if_63_end:
        ; branch erase{r3} equals 0: if_64_else, if_64_then
        cmp r8b, 0
        je _if_64_else
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        jmp _if_64_then
_if_64_else:
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        ; cast t.33.1{r1}(i16), row.3{r6}(u8)
        movzx cx, bl
        ; cast t.34.1{r2}(i16), column.3{r2}(u8)
        movzx dx, dl
        ; addrof memVarAddr{r7}, exponent.1
        lea r12, [rsp+52]
        ; load exponent.1{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call drawTileAt@i16@i16@u8[t.33.1{r1}, t.34.1{r2}, exponent.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; 331:4 if offset == distance
        ; addrof memVarAddr{r7}, distance.4
        lea r12, [rsp+54]
        ; load distance.4{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+57]
        ; load offset.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch offset.2{r0} notequals distance.4{r6}: drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42, if_65_then
        cmp al, bl
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42
        jmp _if_65_then
_if_64_then:
        ; addrof memVarAddr{r7}, column.3
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], column.3{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+57]
        ; load offset.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.32.1{r4}, offset.2{r0}
        mov r9b, al
        ; addrof memVarAddr{r7}, oldOffset.2
        lea r12, [rsp+55]
        ; load oldOffset.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; sub t.32.1{r4}, oldOffset.2{r0}
        sub r9b, al
        ; move row.3{r1}, row.3{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, direction
        lea r12, [rsp+80]
        ; load direction{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call clearTileTrail@u8@u8@u8@u8[row.3{r1}, column.3{r2}, direction{r3}, t.32.1{r4}]
        call _clearTileTrail@u8@u8@u8@u8
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; load pending.9{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp _for_51_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42:
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; load pending.9{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp _for_51_continue
_if_65_then:
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; load pending.9{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; 332:5 if [...] & 128 != 0
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; load index.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.38.1{r2}(i64), index.2{r0}(u8)
        movzx rdx, al
        ; addrof t.37.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.37.2{r3}, t.38.1{r2}
        add r8, rdx
        ; load t.36.1{r2}, [t.37.2{r3}]
        mov dl, [r8]
        ; and t.35.1{r2}, 128
        and dl, 128
        ; branch t.35.1{r2} notequals 0: if_66_then
        cmp dl, 0
        jne _if_66_then
        ; 336:10 if [...] & 64 != 0
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.51.1{r2}(i64), target.1{r1}(u8)
        movzx rdx, cl
        ; addrof t.50.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.50.2{r3}, t.51.1{r2}
        add r8, rdx
        ; load t.49.1{r2}, [t.50.2{r3}]
        mov dl, [r8]
        ; and t.48.1{r2}, 64
        and dl, 64
        ; branch t.48.1{r2} equals 0: for_51_continue, if_67_then
        cmp dl, 0
        je _for_51_continue
        jmp _if_67_then
_if_66_then:
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.42.1{r2}(i64), target.1{r1}(u8)
        movzx rdx, cl
        ; addrof t.41.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.41.2{r3}, t.42.1{r2}
        add r8, rdx
        ; load t.40.1{r2}, [t.41.2{r3}]
        mov dl, [r8]
        ; or t.39.1{r2}, 64
        or dl, 64
        ; cast t.44.1{r3}(i64), target.1{r1}(u8)
        movzx r8, cl
        ; addrof t.43.1{r4}, moveTargets
        lea r9, [var_3]
        ; add t.43.2{r4}, t.44.1{r3}
        add r9, r8
        ; store [t.43.2{r4}], t.39.1{r2}
        mov [r9], dl
        ; const t.45.1{r2}, 0
        mov dl, 0
        ; cast t.47.1{r0}(i64), index.2{r0}(u8)
        movzx rax, al
        ; addrof t.46.1{r3}, moveTiles
        lea r8, [var_2]
        ; add t.46.2{r3}, t.47.1{r0}
        add r8, rax
        ; store [t.46.2{r3}], t.45.1{r2}
        mov [r8], dl
        jmp _for_51_continue
_if_67_then:
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], index.2{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r1}
        mov [r12], cl
        ; call t.53.1{r0} = tileRow@u8[target.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.52.1{r1}(i16), t.53.1{r0}(u8)
        movzx cx, al
        ; addrof memVarAddr{r7}, t.52.1
        lea r12, [rsp+60]
        ; store [memVarAddr{r7}], t.52.1{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; call t.55.1{r0} = tileColumn@u8[target.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.54.1{r2}(i16), t.55.1{r0}(u8)
        movzx dx, al
        ; load target.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.58.1{r0}(i64), target.1{r0}(u8)
        movzx rax, al
        ; addrof t.57.1{r4}, tiles
        lea r9, [var_1]
        ; add t.57.2{r4}, t.58.1{r0}
        add r9, rax
        ; load t.56.1{r3}, [t.57.2{r4}]
        mov r8b, [r9]
        ; addrof memVarAddr{r7}, t.52.1
        lea r12, [rsp+60]
        ; load t.52.1{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; call drawTileAt@i16@i16@u8[t.52.1{r1}, t.54.1{r2}, t.56.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; const t.59.1{r1}, 0
        mov cl, 0
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; load index.2{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.61.1{r2}(i64), index.2{r2}(u8)
        movzx rdx, dl
        ; addrof t.60.1{r3}, moveTiles
        lea r8, [var_2]
        ; add t.60.2{r3}, t.61.1{r2}
        add r8, rdx
        ; store [t.60.2{r3}], t.59.1{r1}
        mov [r8], cl
_for_51_continue:
        ; addrof memVarAddr{r7}, count.2
        lea r12, [rsp+50]
        ; load count.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add count.5{r1}, 1
        add cl, 1
        ; move pending.2{r0}, pending.4{r6}
        mov al, bl
_for_51:
        ; branch count.2{r1} lt 16: for_51_body
        cmp cl, 16
        jb _for_51_body
        ; 343:9 return pending
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void animateMove@u8
        ;   rsp+64: arg direction
        ;   rsp+48: var pending.2
        ;   rsp+49: var previous.1
        ;   rsp+50: var travel.3
        ;   rsp+51: var speed.3
        ;   rsp+52: var pending.3
        ;   rsp+53: var target.1
        ;   rsp+54: var t.21.1
_animateMove@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move direction{r6}, direction{r1}
        mov bl, cl
        ; const travel.1{r0}, 0
        mov al, 0
        ; const speed.1{r5}, 1
        mov r10b, 1
        ; const pending.1{r4}, 1
        mov r9b, 1
        ; 352:2 while pending
        ; addrof memVarAddr{r7}, pending.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], pending.2{r4}
        mov [r12], r9b
        ; move pending.2{r3}, pending.2{r4}
        mov r8b, r9b
        ; move speed.2{r2}, speed.2{r5}
        mov dl, r10b
        jmp _while_68
_while_68_body:
        ; move speed.2{r5}, speed.2{r2}
        mov r10b, dl
        ; move previous.1{r2}, travel.2{r0}
        mov dl, al
        ; move travel.3{r3}, travel.2{r0}
        mov r8b, al
        ; add travel.3{r3}, speed.2{r5}
        add r8b, r10b
        ; move speed.3{r0}, speed.2{r5}
        mov al, r10b
        ; add speed.3{r0}, 1
        add al, 1
        ; addrof memVarAddr{r7}, speed.3
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], speed.3{r0}
        mov [r12], al
        ; const t.7.1{r4}, 1
        mov r9b, 1
        ; move direction{r1}, direction{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, previous.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], previous.1{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, travel.3
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], travel.3{r3}
        mov [r12], r8b
        ; call _ = drawMoveFrame@u8@u8@u8@bool[direction{r1}, previous.1{r2}, travel.3{r3}, t.7.1{r4}] -> bool
        call _drawMoveFrame@u8@u8@u8@bool
        ; const t.8.1{r4}, 0
        mov r9b, 0
        ; move direction{r1}, direction{r6}
        mov cl, bl
        ; addrof memVarAddr{r7}, previous.1
        lea r12, [rsp+49]
        ; load previous.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, travel.3
        lea r12, [rsp+50]
        ; load travel.3{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; call pending.3{r0} = drawMoveFrame@u8@u8@u8@bool[direction{r1}, previous.1{r2}, travel.3{r3}, t.8.1{r4}] -> bool
        call _drawMoveFrame@u8@u8@u8@bool
        ; addrof memVarAddr{r7}, pending.3
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], pending.3{r0}
        mov [r12], al
        ; call waitFrame[]
        call _waitFrame
        ; addrof memVarAddr{r7}, travel.3
        lea r12, [rsp+50]
        ; load travel.3{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move travel.2{r0}, travel.3{r3}
        mov al, r8b
        ; addrof memVarAddr{r7}, speed.3
        lea r12, [rsp+51]
        ; load speed.3{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, pending.3
        lea r12, [rsp+52]
        ; load pending.3{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
_while_68:
        ; branch pending.2{r3} notequals 0: while_68_body
        cmp r8b, 0
        jne _while_68_body
        ; const index.1{r6}, 0
        mov bl, 0
        ; 362:2 for index < 16
        jmp _for_69
_for_69_body:
        ; cast t.11.1{r0}(i64), index.2{r6}(u8)
        movzx rax, bl
        ; addrof t.10.1{r2}, moveTargets
        lea rdx, [var_3]
        ; add t.10.2{r2}, t.11.1{r0}
        add rdx, rax
        ; load t.9.1{r0}, [t.10.2{r2}]
        mov al, [rdx]
        ; move target.1{r1}, t.9.1{r0}
        mov cl, al
        ; and target.1{r1}, 15
        and cl, 15
        ; 364:3 if [...] != 0 && [...] != [...]
        ; cast t.14.1{r0}(i64), index.2{r6}(u8)
        movzx rax, bl
        ; addrof t.13.1{r2}, moveTiles
        lea rdx, [var_2]
        ; add t.13.2{r2}, t.14.1{r0}
        add rdx, rax
        ; load t.12.1{r0}, [t.13.2{r2}]
        mov al, [rdx]
        ; branch t.12.1{r0} equals 0: for_69_continue
        cmp al, 0
        je _for_69_continue
        ; cast t.17.1{r0}(i64), index.2{r6}(u8)
        movzx rax, bl
        ; addrof t.16.1{r2}, moveTiles
        lea rdx, [var_2]
        ; add t.16.2{r2}, t.17.1{r0}
        add rdx, rax
        ; load t.15.1{r0}, [t.16.2{r2}]
        mov al, [rdx]
        ; cast t.20.1{r2}(i64), target.1{r1}(u8)
        movzx rdx, cl
        ; addrof t.19.1{r3}, tiles
        lea r8, [var_1]
        ; add t.19.2{r3}, t.20.1{r2}
        add r8, rdx
        ; load t.18.1{r2}, [t.19.2{r3}]
        mov dl, [r8]
        ; branch t.15.1{r0} equals t.18.1{r2}: for_69_continue
        cmp al, dl
        je _for_69_continue
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r1}
        mov [r12], cl
        ; call t.23.1{r0} = tileRow@u8[target.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.22.1{r0}(i16), t.23.1{r0}(u8)
        movzx ax, al
        ; move t.21.1{r1}, t.22.1{r0}
        mov cx, ax
        ; add t.21.1{r1}, 1
        add cx, 1
        ; addrof memVarAddr{r7}, t.21.1
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t.21.1{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; call t.26.1{r0} = tileColumn@u8[target.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.25.1{r0}(i16), t.26.1{r0}(u8)
        movzx ax, al
        ; move t.24.1{r2}, t.25.1{r0}
        mov dx, ax
        ; add t.24.1{r2}, 1
        add dx, 1
        ; addrof memVarAddr{r7}, t.21.1
        lea r12, [rsp+54]
        ; load t.21.1{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; call setCursor@i16@i16[t.21.1{r1}, t.24.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.29.1{r0}(i64), target.1{r1}(u8)
        movzx rax, cl
        ; addrof t.28.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.28.2{r2}, t.29.1{r0}
        add rdx, rax
        ; load t.27.1{r1}, [t.28.2{r2}]
        mov cl, [rdx]
        ; call printTile@u8[t.27.1{r1}]
        call _printTile@u8
_for_69_continue:
        ; move index.4{r0}, index.2{r6}
        mov al, bl
        ; add index.4{r0}, 1
        add al, 1
        ; move index.2{r6}, index.4{r0}
        mov bl, al
_for_69:
        ; branch index.2{r6} lt 16: for_69_body
        cmp bl, 16
        jb _for_69_body
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
        ; const t.0.1{r1}, [string-15]
        lea rcx, [string_15]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void clearBoard
_clearBoard:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const row.1{r6}, 0
        mov bx, 0
        ; 404:2 for row < 15
        jmp _for_72
_for_72_body:
        ; move t.1.1{r1}, row.2{r6}
        mov cx, bx
        ; add t.1.1{r1}, 3
        add cx, 3
        ; const arg.0.1{r2}, 1
        mov dx, 1
        ; call setCursor@i16@i16[t.1.1{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.2.1{r1}, [string-16]
        lea rcx, [string_16]
        ; call printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; move row.3{r0}, row.2{r6}
        mov ax, bx
        ; add row.3{r0}, 1
        add ax, 1
        ; move row.2{r6}, row.3{r0}
        mov bx, ax
_for_72:
        ; branch row.2{r6} lt 15: for_72_body
        cmp bx, 15
        jl _for_72_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
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
        ; 414:2 for boardRow < 4
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
        jmp _for_73
_for_73_body:
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r2}
        mov [r12], dl
        ; const column.1{r0}, 1
        mov ax, 1
        ; const boardColumn.1{r4}, 0
        mov r9b, 0
        ; 416:3 for boardColumn < 4
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
        ; move boardColumn.2{r3}, boardColumn.2{r0}
        mov r8b, al
        jmp _for_74
_for_74_body:
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], boardColumn.2{r3}
        mov [r12], r8b
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
_for_74:
        ; branch boardColumn.2{r3} lt 4: for_74_body
        cmp r8b, 4
        jb _for_74_body
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
_for_73:
        ; branch boardRow.2{r2} lt 4: for_73_body
        cmp dl, 4
        jb _for_73_body
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
        ; const t.0.1{r1}, [string-17]
        lea rcx, [string_17]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r6}, score
        lea rbx, [var_4]
        ; load t.2.1{r1}, [a.1.1{r6}]
        mov ecx, [rbx]
        ; call printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-18]
        lea rcx, [string_18]
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
        ; const t.0.1{r1}, [string-19]
        lea rcx, [string_19]
        ; call printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 19
        mov cx, 19
        ; const arg.2.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 436:2 if gameState == 1
        ; addrof a.1.1{r6}, gameState
        lea rbx, [var_5]
        ; load t.2.1{r6}, [a.1.1{r6}]
        mov bl, [rbx]
        ; branch t.2.1{r6} equals 1: if_75_then
        cmp bl, 1
        je _if_75_then
        ; 439:7 if gameState == 2
        ; addrof a.4.1{r6}, gameState
        lea rbx, [var_5]
        ; load t.5.1{r6}, [a.4.1{r6}]
        mov bl, [rbx]
        ; branch t.5.1{r6} notequals 2: drawStatus_ret, if_76_then
        cmp bl, 2
        jne _drawStatus_ret
        jmp _if_76_then
_if_75_then:
        ; const t.3.1{r1}, [string-20]
        lea rcx, [string_20]
        ; call printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
_if_76_then:
        ; const t.6.1{r1}, [string-21]
        lea rcx, [string_21]
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
        ; 445:2 for index < 16
        jmp _for_77
_for_77_body:
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
_for_77:
        ; branch index.2{r6} lt 16: for_77_body
        cmp bl, 16
        jb _for_77_body
        ; const t.4.1{r6}, 0
        mov ebx, 0
        ; addrof a.5.1{r0}, score
        lea rax, [var_4]
        ; store [a.5.1{r0}], t.4.1{r6}
        mov [rax], ebx
        ; call drawScore[]
        call _drawScore
        ; const t.6.1{r6}, 0
        mov bl, 0
        ; addrof a.7.1{r0}, gameState
        lea rax, [var_5]
        ; store [a.7.1{r0}], t.6.1{r6}
        mov [rax], bl
        ; call _ = spawnTile[] -> u8
        call _spawnTile
        ; call _ = spawnTile[] -> u8
        call _spawnTile
        ; call drawBoard[]
        call _drawBoard
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
        ;   rsp+48: var t.12.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.3.1{r6}, 0
        mov ebx, 0
        ; addrof a.4.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.4.1{r0}], t.3.1{r6}
        mov [rax], ebx
        ; addrof a.6.1{r0}, score
        lea rax, [var_4]
        ; store [a.6.1{r0}], t.5.1{r6}
        mov [rax], ebx
        ; const t.7.1{r6}, 0
        mov bl, 0
        ; addrof a.8.1{r0}, gameState
        lea rax, [var_5]
        ; store [a.8.1{r0}], t.7.1{r6}
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
        ; 462:2 while true
        jmp _while_78
_if_79_end:
        ; branch key.1{r6} equals 114: if_80_then
        cmp bx, 114
        je _if_80_then
        ; branch key.1{r6} equals 82: if_80_then
        cmp bx, 82
        je _if_80_then
        ; 471:3 if gameState != 0
        ; addrof a.9.1{r0}, gameState
        lea rax, [var_5]
        ; load t.10.1{r0}, [a.9.1{r0}]
        mov al, [rax]
        ; branch t.10.1{r0} notequals 0: while_78
        cmp al, 0
        jne _while_78
        ; branch key.1{r6} equals -8117: if_83_then, or_85
        cmp bx, -8117
        je _if_83_then
        jmp _or_85
_if_80_then:
        ; call newGame[]
        call _newGame
        jmp _while_78
_or_85:
        ; branch key.1{r6} equals 97: if_83_then
        cmp bx, 97
        je _if_83_then
        ; branch key.1{r6} equals 65: if_83_then
        cmp bx, 65
        je _if_83_then
        ; branch key.1{r6} equals -8115: if_86_then
        cmp bx, -8115
        je _if_86_then
        ; branch key.1{r6} equals 100: if_86_then, or_87
        cmp bx, 100
        je _if_86_then
        jmp _or_87
_if_83_then:
        ; const direction.2{r6}, 0
        mov bl, 0
        jmp _if_83_end
_or_87:
        ; branch key.1{r6} equals 68: if_86_then
        cmp bx, 68
        je _if_86_then
        ; branch key.1{r6} equals -8120: if_89_then
        cmp bx, -8120
        je _if_89_then
        ; branch key.1{r6} equals 119: if_89_then, or_90
        cmp bx, 119
        je _if_89_then
        jmp _or_90
_if_86_then:
        ; const direction.4{r6}, 1
        mov bl, 1
        jmp _if_83_end
_or_90:
        ; branch key.1{r6} equals 87: if_89_then
        cmp bx, 87
        je _if_89_then
        ; branch key.1{r6} equals -8112: if_92_then
        cmp bx, -8112
        je _if_92_then
        ; branch key.1{r6} equals 115: if_92_then, or_93
        cmp bx, 115
        je _if_92_then
        jmp _or_93
_if_89_then:
        ; const direction.5{r6}, 2
        mov bl, 2
        jmp _if_83_end
_or_93:
        ; branch key.1{r6} notequals 83: while_78, if_92_then
        cmp bx, 83
        jne _while_78
_if_92_then:
        ; const direction.6{r6}, 3
        mov bl, 3
_if_83_end:
        ; 491:3 if !slide@u8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=491:13]])
        ; move direction.3{r1}, direction.3{r6}
        mov cl, bl
        ; call t.11.1{r0} = slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.11.1{r0} equals 0: while_78
        cmp al, 0
        je _while_78
        ; move direction.3{r1}, direction.3{r6}
        mov cl, bl
        ; call animateMove@u8[direction.3{r1}]
        call _animateMove@u8
        ; call spawned.1{r0} = spawnTile[] -> u8
        call _spawnTile
        ; move spawned.1{r6}, spawned.1{r0}
        mov bl, al
        ; 497:3 if spawned != 255
        ; branch spawned.1{r6} equals 255: if_96_end
        cmp bl, 255
        je _if_96_end
        ; move spawned.1{r1}, spawned.1{r6}
        mov cl, bl
        ; call t.13.1{r0} = tileRow@u8[spawned.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.12.1{r1}(i16), t.13.1{r0}(u8)
        movzx cx, al
        ; addrof memVarAddr{r7}, t.12.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], t.12.1{r1}
        mov [r12], cx
        ; move spawned.1{r1}, spawned.1{r6}
        mov cl, bl
        ; call t.15.1{r0} = tileColumn@u8[spawned.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.14.1{r2}(i16), t.15.1{r0}(u8)
        movzx dx, al
        ; cast t.18.1{r6}(i64), spawned.1{r6}(u8)
        movzx rbx, bl
        ; addrof t.17.1{r0}, tiles
        lea rax, [var_1]
        ; add t.17.2{r0}, t.18.1{r6}
        add rax, rbx
        ; load t.16.1{r3}, [t.17.2{r0}]
        mov r8b, [rax]
        ; load t.12.1{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; call drawTileAt@i16@i16@u8[t.12.1{r1}, t.14.1{r2}, t.16.1{r3}]
        call _drawTileAt@i16@i16@u8
_if_96_end:
        ; 500:3 if gameState == 0 && !canMove([])
        ; addrof a.19.1{r6}, gameState
        lea rbx, [var_5]
        ; load t.20.1{r6}, [a.19.1{r6}]
        mov bl, [rbx]
        ; branch t.20.1{r6} notequals 0: if_97_end
        cmp bl, 0
        jne _if_97_end
        ; call t.21.1{r0} = canMove[] -> bool
        call _canMove
        ; branch t.21.1{r0} notequals 0: if_97_end
        cmp al, 0
        jne _if_97_end
        ; const t.22.1{r6}, 2
        mov bl, 2
        ; addrof a.23.1{r0}, gameState
        lea rax, [var_5]
        ; store [a.23.1{r0}], t.22.1{r6}
        mov [rax], bl
_if_97_end:
        ; call drawScore[]
        call _drawScore
        ; 504:3 if gameState != 0
        ; addrof a.24.1{r6}, gameState
        lea rbx, [var_5]
        ; load t.25.1{r6}, [a.24.1{r6}]
        mov bl, [rbx]
        ; branch t.25.1{r6} equals 0: if_99_end
        cmp bl, 0
        je _if_99_end
        ; call drawStatus[]
        call _drawStatus
_if_99_end:
        ; const arg.13.0{r1}, 21
        mov cx, 21
        ; const arg.13.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.13.0{r1}, arg.13.1{r2}]
        call _setCursor@i16@i16
_while_78:
        ; call key.1{r0} = getChar[] -> i16
        call _getChar
        ; move key.1{r6}, key.1{r0}
        mov bx, ax
        ; 464:3 if key == 27
        ; branch key.1{r6} notequals 27: if_79_end
        cmp bx, 27
        jne _if_79_end
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
        mov  ecx, 25
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
        ; variable 4: score (i32/4)
        var_4 rb 4
        ; variable 5: gameState (u8/1)
        var_5 rb 1

section '.data' data readable
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
        string_14 db '        ', 0x00
        string_15 db 'Arrows/WASD  R restart  Esc quit', 0x00
        string_16 db '                                   ', 0x00
        string_17 db '2048  Score: ', 0x00
        string_18 db '          ', 0x00
        string_19 db '                                      ', 0x00
        string_20 db '2048! Press R to play again.', 0x00
        string_21 db 'No moves left. Press R to restart.', 0x00

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
