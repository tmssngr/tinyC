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

        ; void _printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; call length.1{r0} = _strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length.1{r2}, length.1{r0}
        mov rdx, rax
        ; call _printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _printChar@u8
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
        ; call _printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _printUint@i32
        ;   rsp+48: arg number
_printUint@i32:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(i32)
        movsxd rcx, ecx
        ; call _printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void _printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 40
        sub rsp, 32
        ; const pos.1{r0}, 20
        mov al, 20
        ; 33:2 while true
        ; move number.1{r3}, number{r1}
        mov r8, rcx
        jmp while_1
_printUint@i64.no_critical_edge_4:
        ; move pos.2{r0}, pos.3{r4}
        mov al, r9b
while_1:
        ; move pos.3{r4}, pos.2{r0}
        mov r9b, al
        ; sub pos.3{r4}, 1
        sub r9b, 1
        ; move remainder.1{r5}, number.1{r3}
        mov r10, r8
        ; move remainder.1{r0}, remainder.1{r5}
        mov rax, r10
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r5}, remainder.1{r2}
        mov r10, rdx
        ; move number.2{r0}, number.2{r3}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r3}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r5}(i64)
        mov al, r10b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r1}(i64), pos.3{r4}(u8)
        movzx rcx, r9b
        ; addrof t.6.1{r2}, buffer
        lea rdx, [rsp+40]
        ; add t.6.2{r2}, t.7.1{r1}
        add rdx, rcx
        ; store [t.6.2{r2}], digit.1{r0}
        mov [rdx], al
        ; 39:3 if number == 0
        ; branch number.2{r3} notequals 0: _printUint@i64.no_critical_edge_4
        cmp r8, 0
        jne _printUint@i64.no_critical_edge_4
        ; move t.8.2{r1}, t.8.2{r2}
        mov rcx, rdx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov dl, al
        ; sub t.10.1{r2}, pos.3{r4}
        sub dl, r9b
        ; call _printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 40
        ret

        ; i64 _strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length.1{r0}, 0
        mov rax, 0
        ; 73:2 for *str != 0
        jmp for_3
for_3_body:
        ; add length.3{r0}, 1
        add rax, 1
        ; add str.2{r1}, 1
        add rcx, 1
for_3:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_3_body
        cmp dl, 0
        jne for_3_body
        ; 76:9 return length
        add rsp, 8
        ret

        ; void _printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call _printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void _initRandom@i32
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

        ; i32 _random
_random:
        sub rsp, 8
        ; addrof a.5.1{r0}, __random__
        lea rax, [var_0]
        ; load r.1{r0}, [a.5.1{r0}]
        mov eax, [rax]
        ; move t.6.1{r1}, r.1{r0}
        mov ecx, eax
        ; and t.6.1{r1}, 524287
        and ecx, 524287
        ; mul b.1{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; shiftright t.7.1{r0}, 15
        sar eax, 15
        ; mul c.1{r0}, 48271
        movsxd rax, eax
        imul  rax, 48271
        ; move t.8.1{r2}, c.1{r0}
        mov edx, eax
        ; and t.8.1{r2}, 65535
        and edx, 65535
        ; shiftleft d.1{r2}, 15
        sal edx, 15
        ; shiftright t.10.1{r0}, 16
        sar eax, 16
        ; add t.9.1{r0}, b.1{r1}
        add eax, ecx
        ; add e.1{r0}, d.1{r2}
        add eax, edx
        ; move t.12.1{r1}, e.1{r0}
        mov ecx, eax
        ; and t.12.1{r1}, 2147483647
        and ecx, 2147483647
        ; shiftright t.13.1{r0}, 31
        sar eax, 31
        ; add t.11.1{r1}, t.13.1{r0}
        add ecx, eax
        ; addrof a.14.1{r0}, __random__
        lea rax, [var_0]
        ; store [a.14.1{r0}], t.11.1{r1}
        mov [rax], ecx
        ; 16:9 return __random__
        ; move t.16.1{r0}, t.16.1{r1}
        mov eax, ecx
        add rsp, 8
        ret

        ; i16 _random16
_random16:
        sub rsp, 8
        sub rsp, 32
        ; 20:25 return (i16) & 32767
        ; call t.2.1{r0} = _random[] -> i32
        call _random
        ; cast t.1.1{r0}(i16), t.2.1{r0}(i32)
        ; and t.0.1{r0}, 32767
        and ax, 32767
        add rsp, 32
        add rsp, 8
        ret

        ; i16 _tileValue@u8
        ;   rsp+16: arg exponent
_tileValue@u8:
        sub rsp, 8
        ; const value.1{r0}, 1
        mov ax, 1
        ; const index.1{r2}, 0
        mov dl, 0
        ; 45:2 for index < exponent
        jmp for_4
for_4_body:
        ; shiftleft value.3{r0}, 1
        sal ax, 1
        ; add index.3{r2}, 1
        add dl, 1
for_4:
        ; branch index.2{r2} lt exponent{r1}: for_4_body
        cmp dl, cl
        jb for_4_body
        ; 48:9 return value
        add rsp, 8
        ret

        ; u8 _spawnTile
        ;   rsp+48: var tile.1
_spawnTile:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const emptyCount.1{r0}, 0
        mov al, 0
        ; const index.1{r1}, 0
        mov cl, 0
        ; 53:2 for index < 16
        ; move emptyCount.2{r6}, emptyCount.1{r0}
        mov bl, al
        jmp for_5
for_5_body:
        ; 54:3 if [...] == 0
        ; cast t.7.1{r1}(i64), index.2{r0}(u8)
        movzx rcx, al
        ; addrof t.6.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rdx, rcx
        ; load t.5.1{r1}, [t.6.2{r2}]
        mov cl, [rdx]
        ; branch t.5.1{r1} equals 0: if_6_then
        cmp cl, 0
        je if_6_then
        ; move emptyCount.3{r1}, emptyCount.2{r6}
        mov cl, bl
        jmp for_5_continue
if_6_then:
        ; move emptyCount.4{r1}, emptyCount.2{r6}
        mov cl, bl
        ; add emptyCount.4{r1}, 1
        add cl, 1
for_5_continue:
        ; add index.6{r0}, 1
        add al, 1
        ; move emptyCount.2{r6}, emptyCount.3{r1}
        mov bl, cl
for_5:
        ; branch index.2{r0} lt 16: for_5_body
        cmp al, 16
        jb for_5_body
        ; branch emptyCount.2{r6} equals 0: if_7_then
        cmp bl, 0
        je if_7_then
        ; call t.9.1{r0} = _random16[] -> i16
        call _random16
        ; cast t.10.1{r1}(i16), emptyCount.2{r6}(u8)
        movzx cx, bl
        ; mod t.8.1{r2}, t.8.1{r0}, t.10.1{r1}
        movsx rax, ax
        movsx rcx, cx
        cqo
        idiv rcx
        ; move t.8.1{r3}, t.8.1{r2}
        mov r8w, dx
        ; cast chosen.1{r0}(u8), t.8.1{r3}(i16)
        mov al, r8b
        ; const index.3{r1}, 0
        mov cl, 0
        ; 63:2 for index < 16
        ; move chosen.2{r2}, chosen.1{r0}
        mov dl, al
        ; move index.4{r6}, index.3{r1}
        mov bl, cl
        jmp for_8
for_8_body:
        ; 64:3 if [...] != 0
        ; cast t.13.1{r0}(i64), index.4{r6}(u8)
        movzx rax, bl
        ; addrof t.12.1{r1}, tiles
        lea rcx, [var_1]
        ; add t.12.2{r1}, t.13.1{r0}
        add rcx, rax
        ; load t.11.1{r0}, [t.12.2{r1}]
        mov al, [rcx]
        ; branch t.11.1{r0} equals 0: if_9_end
        cmp al, 0
        je if_9_end
        ; move chosen.3{r0}, chosen.2{r2}
        mov al, dl
        jmp for_8_continue
if_9_end:
        ; branch chosen.2{r2} equals 0: if_10_then
        cmp dl, 0
        je if_10_then
        ; move chosen.4{r0}, chosen.2{r2}
        mov al, dl
        ; sub chosen.4{r0}, 1
        sub al, 1
for_8_continue:
        ; move index.8{r1}, index.4{r6}
        mov cl, bl
        ; add index.8{r1}, 1
        add cl, 1
        ; move chosen.2{r2}, chosen.3{r0}
        mov dl, al
        ; move index.4{r6}, index.8{r1}
        mov bl, cl
        jmp for_8
if_7_then:
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
for_8:
        ; branch index.4{r6} lt 16: for_8_body
        cmp bl, 16
        jb for_8_body
        ; const {r0}, 255
        mov al, 255
        jmp _spawnTile_ret
if_10_then:
        ; const tile.1{r1}, 1
        mov cl, 1
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], tile.1{r1}
        mov [r12], cl
        ; 69:4 if _random16([]) % 10 == 0
        ; call t.15.1{r0} = _random16[] -> i16
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
        je if_11_then
        ; load tile.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp if_11_end
if_11_then:
        ; const tile.3{r0}, 2
        mov al, 2
if_11_end:
        ; cast t.17.1{r1}(i64), index.4{r6}(u8)
        movzx rcx, bl
        ; addrof t.16.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.16.2{r2}, t.17.1{r1}
        add rdx, rcx
        ; store [t.16.2{r2}], tile.2{r0}
        mov [rdx], al
        ; 73:11 return index
        ; move index.4{r0}, index.4{r6}
        mov al, bl
_spawnTile_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool _slideLine@u8@u8
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
        ; const moved.1{r4}, 0
        mov r9b, 0
        ; const position.1{r5}, 0
        mov r10b, 0
        ; 85:2 for position < 4
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], position.2{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; move moved.2{r6}, moved.2{r4}
        mov bl, r9b
        ; move step{r4}, step{r2}
        mov r9b, dl
        ; move moved.2{r2}, moved.2{r6}
        mov dl, bl
        ; move source.2{r3}, source.2{r0}
        mov r8b, al
        ; move previousMerged.2{r1}, previousMerged.2{r6}
        mov cl, bl
        jmp for_12
for_12_body:
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], position.2{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; load first{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; move moved.2{r5}, moved.2{r2}
        mov r10b, dl
        ; move step{r2}, step{r4}
        mov dl, r9b
        ; move moved.2{r4}, moved.2{r5}
        mov r9b, r10b
        ; move previousMerged.2{r5}, previousMerged.2{r1}
        mov r10b, cl
        ; move target.2{r1}, target.2{r0}
        mov cl, al
        ; move source.2{r0}, source.2{r3}
        mov al, r8b
        ; move previousMerged.2{r3}, previousMerged.2{r5}
        mov r8b, r10b
        ; cast t.14.1{r5}(i64), source.2{r0}(u8)
        movzx r10, al
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], source.2{r0}
        mov [r12], al
        ; addrof sourceTile.1{r0}, tiles
        lea rax, [var_1]
        ; add sourceTile.2{r0}, t.14.1{r5}
        add rax, r10
        ; load tile.1{r5}, [sourceTile.2{r0}]
        mov r10b, [rax]
        ; 88:3 if tile != 0
        ; branch tile.1{r5} notequals 0: if_13_then
        cmp r10b, 0
        jne if_13_then
        ; move target.3{r0}, target.2{r1}
        mov al, cl
        ; addrof memVarAddr{r7}, target.3
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], target.3{r0}
        mov [r12], al
        ; move previousMerged.3{r0}, previousMerged.2{r3}
        mov al, r8b
        ; addrof memVarAddr{r7}, previousMerged.3
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], previousMerged.3{r0}
        mov [r12], al
        ; move moved.3{r0}, moved.2{r4}
        mov al, r9b
        ; addrof memVarAddr{r7}, moved.3
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], moved.3{r0}
        mov [r12], al
        ; move previousMerged.3{r1}, previousMerged.3{r3}
        mov cl, r8b
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move step{r4}, step{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, target.3
        lea r12, [rsp+52]
        ; load target.3{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, moved.3
        lea r12, [rsp+54]
        ; load moved.3{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        jmp if_13_end
if_13_then:
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], tile.1{r5}
        mov [r12], r10b
        ; const t.15.1{r5}, 0
        mov r10b, 0
        ; store [sourceTile.2{r0}], t.15.1{r5}
        mov [rax], r10b
        ; const merged.1{r0}, 0
        mov al, 0
        ; 91:4 if target != first && !previousMerged
        ; branch target.2{r1} notequals first{r6}: and_15
        cmp cl, bl
        jne and_15
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
        ; store [memVarAddr{r7}], target.2{r1}
        mov [r12], cl
        ; move moved.4{r2}, moved.4{r4}
        mov dl, r9b
        ; move previousMerged.4{r1}, previousMerged.4{r3}
        mov cl, r8b
        jmp if_14_end
and_15:
        ; branch previousMerged.2{r3} equals 0: if_14_then
        cmp r8b, 0
        je if_14_then
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
        ; store [memVarAddr{r7}], target.2{r1}
        mov [r12], cl
        ; move moved.4{r2}, moved.4{r4}
        mov dl, r9b
        ; move previousMerged.4{r1}, previousMerged.4{r3}
        mov cl, r8b
        jmp if_14_end
if_14_then:
        ; move previous.1{r5}, target.2{r1}
        mov r10b, cl
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], target.2{r1}
        mov [r12], cl
        ; sub previous.1{r5}, step{r2}
        sub r10b, dl
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], step{r2}
        mov [r12], dl
        ; cast t.16.1{r1}(i64), previous.1{r5}(u8)
        movzx rcx, r10b
        ; addrof previousTile.1{r2}, tiles
        lea rdx, [var_1]
        ; add previousTile.2{r2}, t.16.1{r1}
        add rdx, rcx
        ; 94:5 if *previousTile == tile
        ; load t.17.1{r1}, [previousTile.2{r2}]
        mov cl, [rdx]
        ; addrof memVarAddr{r7}, first
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], first{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch t.17.1{r1} equals tile.1{r6}: if_16_then
        cmp cl, bl
        je if_16_then
        ; addrof memVarAddr{r7}, previousMerged.4
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], previousMerged.4{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, moved.4
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], moved.4{r4}
        mov [r12], r9b
        ; addrof memVarAddr{r7}, merged.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], merged.2{r0}
        mov [r12], al
        ; move moved.4{r2}, moved.4{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, previousMerged.4
        lea r12, [rsp+55]
        ; move previousMerged.4{r1}, previousMerged.4{r3}
        mov cl, r8b
        jmp if_14_end
if_16_then:
        ; move t.18.1{r0}, previous.1{r5}
        mov al, r10b
        ; or t.18.1{r0}, 128
        or al, 128
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.20.1{r3}(i64), source.2{r1}(u8)
        movzx r8, cl
        ; addrof t.19.1{r1}, moveTargets
        lea rcx, [var_3]
        ; add t.19.2{r1}, t.20.1{r3}
        add rcx, r8
        ; store [t.19.2{r1}], t.18.1{r0}
        mov [rcx], al
        ; move nextTile.1{r0}, tile.1{r6}
        mov al, bl
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], tile.1{r6}
        mov [r12], bl
        ; add nextTile.1{r0}, 1
        add al, 1
        ; store [previousTile.2{r2}], nextTile.1{r0}
        mov [rdx], al
        ; move nextTile.1{r1}, nextTile.1{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, nextTile.1
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], nextTile.1{r0}
        mov [r12], al
        ; call t.21.1{r0} = _tileValue@u8[nextTile.1{r1}] -> i16
        call _tileValue@u8
        ; cast mergedScore.1{r0}(i32), t.21.1{r0}(i16)
        movsx eax, ax
        ; addrof a.23.1{r1}, score
        lea rcx, [var_4]
        ; load t.24.1{r1}, [a.23.1{r1}]
        mov ecx, [rcx]
        ; add t.22.1{r1}, mergedScore.1{r0}
        add ecx, eax
        ; addrof a.25.1{r0}, score
        lea rax, [var_4]
        ; store [a.25.1{r0}], t.22.1{r1}
        mov [rax], ecx
        ; 101:6 if nextTile == 11
        ; load nextTile.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch nextTile.1{r1} notequals 11: if_17_end
        cmp cl, 11
        jne if_17_end
        ; const t.26.1{r0}, 1
        mov al, 1
        ; addrof a.27.1{r1}, gameState
        lea rcx, [var_5]
        ; store [a.27.1{r1}], t.26.1{r0}
        mov [rcx], al
if_17_end:
        ; const merged.3{r0}, 1
        mov al, 1
        ; const previousMerged.6{r1}, 1
        mov cl, 1
        ; const moved.7{r2}, 1
        mov dl, 1
if_14_end:
        ; branch merged.2{r0} equals 0: if_18_then
        cmp al, 0
        je if_18_then
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; load target.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; load step{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        jmp if_13_end
if_18_then:
        ; addrof memVarAddr{r7}, target.2
        lea r12, [rsp+49]
        ; load target.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, source.2
        lea r12, [rsp+48]
        ; load source.2{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; cast t.29.1{r1}(i64), source.2{r3}(u8)
        movzx rcx, r8b
        ; addrof t.28.1{r4}, moveTargets
        lea r9, [var_3]
        ; add t.28.2{r4}, t.29.1{r1}
        add r9, rcx
        ; store [t.28.2{r4}], target.2{r0}
        mov [r9], al
        ; cast t.31.1{r1}(i64), target.2{r0}(u8)
        movzx rcx, al
        ; addrof t.30.1{r4}, tiles
        lea r9, [var_1]
        ; add t.30.2{r4}, t.31.1{r1}
        add r9, rcx
        ; addrof memVarAddr{r7}, tile.1
        lea r12, [rsp+51]
        ; load tile.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; store [t.30.2{r4}], tile.1{r1}
        mov [r9], cl
        ; 112:5 if target != source
        ; branch target.2{r0} equals source.2{r3}: if_19_end
        cmp al, r8b
        je if_19_end
        ; const moved.6{r1}, 1
        mov cl, 1
        ; move moved.5{r2}, moved.6{r1}
        mov dl, cl
if_19_end:
        ; addrof memVarAddr{r7}, step
        lea r12, [rsp+88]
        ; load step{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; add target.7{r0}, step{r4}
        add al, r9b
        ; const previousMerged.5{r1}, 0
        mov cl, 0
if_13_end:
        ; add source.4{r3}, step{r4}
        add r8b, r9b
        ; addrof memVarAddr{r7}, position.2
        lea r12, [rsp+50]
        ; load position.2{r5}, [memVarAddr{r7}]
        mov r10b, [r12]
        ; add position.5{r5}, 1
        add r10b, 1
for_12:
        ; branch position.2{r5} lt 4: for_12_body
        cmp r10b, 4
        jb for_12_body
        ; 121:9 return moved
        ; move moved.2{r0}, moved.2{r2}
        mov al, dl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool _slide@u8
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
        jmp for_20
for_20_body:
        ; cast t.8.1{r1}(i64), index.2{r0}(u8)
        movzx rcx, al
        ; addrof t.7.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.7.2{r2}, t.8.1{r1}
        add rdx, rcx
        ; load t.6.1{r1}, [t.7.2{r2}]
        mov cl, [rdx]
        ; cast t.10.1{r2}(i64), index.2{r0}(u8)
        movzx rdx, al
        ; addrof t.9.1{r3}, moveTiles
        lea r8, [var_2]
        ; add t.9.2{r3}, t.10.1{r2}
        add r8, rdx
        ; store [t.9.2{r3}], t.6.1{r1}
        mov [r8], cl
        ; move t.12.1{r1}, t.12.1{r2}
        mov rcx, rdx
        ; addrof t.11.1{r2}, moveTargets
        lea rdx, [var_3]
        ; add t.11.2{r2}, t.12.1{r1}
        add rdx, rcx
        ; store [t.11.2{r2}], index.2{r0}
        mov [rdx], al
        ; add index.3{r0}, 1
        add al, 1
for_20:
        ; branch index.2{r0} lt 16: for_20_body
        cmp al, 16
        jb for_20_body
        ; const moved.1{r0}, 0
        mov al, 0
        ; const line.1{r1}, 0
        mov cl, 0
        ; 130:2 for line < 4
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], moved.2{r0}
        mov [r12], al
        ; load moved.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp for_21
for_21_body:
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], moved.2{r0}
        mov [r12], al
        ; move line.2{r0}, line.2{r1}
        mov al, cl
        ; shiftleft first.1{r1}, 2
        shl cl, 2
        ; const step.1{r2}, 1
        mov dl, 1
        ; 133:3 if direction == 1
        ; branch direction{r6} equals 1: if_22_then
        cmp bl, 1
        je if_22_then
        ; branch direction{r6} notequals 2: if_23_else, if_23_then
        cmp bl, 2
        jne if_23_else
        jmp if_23_then
if_22_then:
        ; add first.2{r1}, 3
        add cl, 3
        ; const step.2{r2}, 255
        mov dl, 255
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp if_22_end
if_23_else:
        ; branch direction{r6} notequals 3: _slide@u8.no_critical_edge_17, if_24_then
        cmp bl, 3
        jne _slide@u8.no_critical_edge_17
        jmp if_24_then
if_23_then:
        ; move first.4{r1}, line.2{r0}
        mov cl, al
        ; const step.4{r2}, 4
        mov dl, 4
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp if_22_end
_slide@u8.no_critical_edge_17:
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        jmp if_22_end
if_24_then:
        ; move first.5{r1}, line.2{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        ; add first.5{r1}, 12
        add cl, 12
        ; const step.5{r0}, 252
        mov al, 252
        ; move step.3{r2}, step.5{r0}
        mov dl, al
if_22_end:
        ; 145:3 if _slideLine@u8@u8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=145:16], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=145:23]])
        ; call t.13.1{r0} = _slideLine@u8@u8[first.3{r1}, step.3{r2}] -> bool
        call _slideLine@u8@u8
        ; branch t.13.1{r0} notequals 0: if_25_then
        cmp al, 0
        jne if_25_then
        ; addrof memVarAddr{r7}, moved.2
        lea r12, [rsp+48]
        ; load moved.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        jmp for_21_continue
if_25_then:
        ; const moved.5{r0}, 1
        mov al, 1
for_21_continue:
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+49]
        ; load line.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add line.5{r1}, 1
        add cl, 1
for_21:
        ; branch line.2{r1} lt 4: for_21_body
        cmp cl, 4
        jb for_21_body
        ; 149:9 return moved
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool _canMove
_canMove:
        sub rsp, 8
        ; const index.1{r0}, 0
        mov al, 0
        ; 153:2 for index < 16
        jmp for_26
for_26_body:
        ; cast t.3.1{r1}(i64), index.2{r0}(u8)
        movzx rcx, al
        ; addrof t.2.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.2.2{r2}, t.3.1{r1}
        add rdx, rcx
        ; load tile.1{r1}, [t.2.2{r2}]
        mov cl, [rdx]
        ; 155:3 if tile == 0
        ; branch tile.1{r1} equals 0: if_27_then
        cmp cl, 0
        je if_27_then
        ; 158:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r2}, index.2{r0}
        mov dl, al
        ; and t.4.1{r2}, 3
        and dl, 3
        ; branch t.4.1{r2} equals 3: if_28_end
        cmp dl, 3
        je if_28_end
        ; move t.8.1{r2}, index.2{r0}
        mov dl, al
        ; add t.8.1{r2}, 1
        add dl, 1
        ; cast t.7.1{r2}(i64), t.8.1{r2}(u8)
        movzx rdx, dl
        ; addrof t.6.1{r3}, tiles
        lea r8, [var_1]
        ; add t.6.2{r3}, t.7.1{r2}
        add r8, rdx
        ; load t.5.1{r2}, [t.6.2{r3}]
        mov dl, [r8]
        ; branch t.5.1{r2} equals tile.1{r1}: if_28_then, if_28_end
        cmp dl, cl
        je if_28_then
if_28_end:
        ; branch index.2{r0} gteq 12: for_26_continue
        cmp al, 12
        jae for_26_continue
        ; move t.12.1{r2}, index.2{r0}
        mov dl, al
        ; add t.12.1{r2}, 4
        add dl, 4
        ; cast t.11.1{r2}(i64), t.12.1{r2}(u8)
        movzx rdx, dl
        ; addrof t.10.1{r3}, tiles
        lea r8, [var_1]
        ; add t.10.2{r3}, t.11.1{r2}
        add r8, rdx
        ; load t.9.1{r2}, [t.10.2{r3}]
        mov dl, [r8]
        ; branch t.9.1{r2} equals tile.1{r1}: if_30_then, for_26_continue
        cmp dl, cl
        je if_30_then
for_26_continue:
        ; add index.5{r0}, 1
        add al, 1
for_26:
        ; branch index.2{r0} lt 16: for_26_body
        cmp al, 16
        jb for_26_body
        ; const {r0}, 0
        mov al, 0
        jmp _canMove_ret
if_27_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
if_28_then:
        ; const {r0}, 1
        mov al, 1
        jmp _canMove_ret
if_30_then:
        ; const {r0}, 1
        mov al, 1
_canMove_ret:
        add rsp, 8
        ret

        ; void _printTile@u8
        ;   rsp+48: arg exponent
_printTile@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move exponent{r6}, exponent{r1}
        mov bl, cl
        ; branch exponent{r6} equals 0: if_32_then
        cmp bl, 0
        je if_32_then
        ; branch exponent{r6} notequals 1: if_33_else, if_33_then
        cmp bl, 1
        jne if_33_else
        jmp if_33_then
if_32_then:
        ; const t.1.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call _printString@@u8[t.1.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_33_else:
        ; branch exponent{r6} notequals 2: if_34_else, if_34_then
        cmp bl, 2
        jne if_34_else
        jmp if_34_then
if_33_then:
        ; const t.2.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_34_else:
        ; branch exponent{r6} notequals 3: if_35_else, if_35_then
        cmp bl, 3
        jne if_35_else
        jmp if_35_then
if_34_then:
        ; const t.3.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_35_else:
        ; branch exponent{r6} notequals 4: if_36_else, if_36_then
        cmp bl, 4
        jne if_36_else
        jmp if_36_then
if_35_then:
        ; const t.4.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call _printString@@u8[t.4.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_36_else:
        ; branch exponent{r6} notequals 5: if_37_else, if_37_then
        cmp bl, 5
        jne if_37_else
        jmp if_37_then
if_36_then:
        ; const t.5.1{r1}, [string-4]
        lea rcx, [string_4]
        ; call _printString@@u8[t.5.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_37_else:
        ; branch exponent{r6} notequals 6: if_38_else, if_38_then
        cmp bl, 6
        jne if_38_else
        jmp if_38_then
if_37_then:
        ; const t.6.1{r1}, [string-5]
        lea rcx, [string_5]
        ; call _printString@@u8[t.6.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_38_else:
        ; branch exponent{r6} notequals 7: if_39_else, if_39_then
        cmp bl, 7
        jne if_39_else
        jmp if_39_then
if_38_then:
        ; const t.7.1{r1}, [string-6]
        lea rcx, [string_6]
        ; call _printString@@u8[t.7.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_39_else:
        ; branch exponent{r6} notequals 8: if_40_else, if_40_then
        cmp bl, 8
        jne if_40_else
        jmp if_40_then
if_39_then:
        ; const t.8.1{r1}, [string-7]
        lea rcx, [string_7]
        ; call _printString@@u8[t.8.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_40_else:
        ; branch exponent{r6} notequals 9: if_41_else, if_41_then
        cmp bl, 9
        jne if_41_else
        jmp if_41_then
if_40_then:
        ; const t.9.1{r1}, [string-8]
        lea rcx, [string_8]
        ; call _printString@@u8[t.9.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_41_else:
        ; branch exponent{r6} notequals 10: if_42_else, if_42_then
        cmp bl, 10
        jne if_42_else
        jmp if_42_then
if_41_then:
        ; const t.10.1{r1}, [string-9]
        lea rcx, [string_9]
        ; call _printString@@u8[t.10.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_42_else:
        ; branch exponent{r6} notequals 11: if_43_else, if_43_then
        cmp bl, 11
        jne if_43_else
        jmp if_43_then
if_42_then:
        ; const t.11.1{r1}, [string-10]
        lea rcx, [string_10]
        ; call _printString@@u8[t.11.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_43_else:
        ; const t.13.1{r1}, [string-12]
        lea rcx, [string_12]
        ; call _printString@@u8[t.13.1{r1}]
        call _printString@@u8
        jmp _printTile@u8_ret
if_43_then:
        ; const t.12.1{r1}, [string-11]
        lea rcx, [string_11]
        ; call _printString@@u8[t.12.1{r1}]
        call _printString@@u8
_printTile@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _drawTileAt@i16@i16@u8
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
        ; move column{r0}, column{r2}
        mov ax, dx
        ; branch exponent{r3} notequals 0: if_44_end, _drawTileAt@i16@i16@u8_ret
        cmp r8b, 0
        jne if_44_end
        ; addrof memVarAddr{r7}, exponent
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], exponent{r3}
        mov [r12], r8b
        jmp _drawTileAt@i16@i16@u8_ret
if_44_end:
        ; addrof memVarAddr{r7}, exponent
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], exponent{r3}
        mov [r12], r8b
        ; move row{r1}, row{r6}
        mov cx, bx
        ; move column{r2}, column{r0}
        mov dx, ax
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], column{r0}
        mov [r12], ax
        ; call _setCursor@i16@i16[row{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.3.1{r1}, [string-13]
        lea rcx, [string_13]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        ; move t.4.1{r1}, row{r6}
        mov cx, bx
        ; add t.4.1{r1}, 1
        add cx, 1
        ; load column{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move column{r2}, column{r0}
        mov dx, ax
        ; call _setCursor@i16@i16[t.4.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const arg.3.0{r1}, 124
        mov cl, 124
        ; call _printChar@u8[arg.3.0{r1}]
        call _printChar@u8
        ; addrof memVarAddr{r7}, exponent
        lea r12, [rsp+80]
        ; load exponent{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move exponent{r1}, exponent{r3}
        mov cl, r8b
        ; call _printTile@u8[exponent{r1}]
        call _printTile@u8
        ; const arg.5.0{r1}, 124
        mov cl, 124
        ; call _printChar@u8[arg.5.0{r1}]
        call _printChar@u8
        ; move t.5.1{r1}, row{r6}
        mov cx, bx
        ; add t.5.1{r1}, 2
        add cx, 2
        ; addrof memVarAddr{r7}, column
        lea r12, [rsp+72]
        ; load column{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; call _setCursor@i16@i16[t.5.1{r1}, column{r2}]
        call _setCursor@i16@i16
        ; const t.6.1{r1}, [string-13]
        lea rcx, [string_13]
        ; call _printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawTileAt@i16@i16@u8_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; u8 _tileRow@u8
        ;   rsp+16: arg index
_tileRow@u8:
        sub rsp, 8
        ; 226:19 return index & 12 + 3
        ; move t.2.1{r0}, index{r1}
        mov al, cl
        ; and t.2.1{r0}, 12
        and al, 12
        ; add t.1.1{r0}, 3
        add al, 3
        add rsp, 8
        ret

        ; u8 _tileColumn@u8
        ;   rsp+16: arg index
_tileColumn@u8:
        sub rsp, 8
        ; move column.1{r0}, index{r1}
        mov al, cl
        ; and column.1{r0}, 3
        and al, 3
        ; 231:36 return column << 3 + 1 + column
        ; move t.4.1{r1}, column.1{r0}
        mov cl, al
        ; shiftleft t.4.1{r1}, 3
        shl cl, 3
        ; add t.3.1{r1}, 1
        add cl, 1
        ; add t.2.1{r1}, column.1{r0}
        add cl, al
        ; move t.2.1{r0}, t.2.1{r1}
        mov al, cl
        add rsp, 8
        ret

        ; void _clearTileTrail@u8@u8@u8@u8
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+96: arg direction
        ;   rsp+104: arg distance
        ;   rsp+48: var height.5
        ;   rsp+56: var spaces.2
        ;   rsp+64: var row.5
        ;   rsp+65: var line.2
_clearTileTrail@u8@u8@u8@u8:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const width.1{r0}, 8
        mov al, 8
        ; const height.1{r5}, 3
        mov r10b, 3
        ; 237:2 if direction < 2
        ; branch direction{r3} lt 2: if_45_then
        cmp r8b, 2
        jb if_45_then
        ; branch distance{r4} gteq height.1{r5}: _clearTileTrail@u8@u8@u8@u8.no_critical_edge_14, if_48_end
        cmp r9b, r10b
        jae _clearTileTrail@u8@u8@u8@u8.no_critical_edge_14
        jmp if_48_end
if_45_then:
        ; branch distance{r4} gteq width.1{r0}: if_46_end, if_46_then
        cmp r9b, al
        jae if_46_end
        jmp if_46_then
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_14:
        ; move height.2{r4}, height.1{r5}
        mov r9b, r10b
        jmp if_48_end
if_46_then:
        ; move width.4{r0}, distance{r4}
        mov al, r9b
        jmp if_46_end
if_48_end:
        ; branch direction{r3} notequals 2: _clearTileTrail@u8@u8@u8@u8.no_critical_edge_15, if_49_then
        cmp r8b, 2
        jne _clearTileTrail@u8@u8@u8@u8.no_critical_edge_15
        jmp if_49_then
if_46_end:
        ; branch direction{r3} notequals 0: _clearTileTrail@u8@u8@u8@u8.no_critical_edge_17, if_47_then
        cmp r8b, 0
        jne _clearTileTrail@u8@u8@u8@u8.no_critical_edge_17
        jmp if_47_then
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_15:
        ; move column.3{r6}, column{r2}
        mov bl, dl
        ; move height.5{r2}, height.2{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], height.5{r2}
        mov [r12], dl
        jmp if_45_end
if_49_then:
        ; const t.11.1{r3}, 3
        mov r8b, 3
        ; sub t.10.1{r3}, height.2{r4}
        sub r8b, r9b
        ; add row.4{r1}, t.10.1{r3}
        add cl, r8b
        ; move column.3{r6}, column{r2}
        mov bl, dl
        ; move height.5{r2}, height.2{r4}
        mov dl, r9b
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], height.5{r2}
        mov [r12], dl
        jmp if_45_end
_clearTileTrail@u8@u8@u8@u8.no_critical_edge_17:
        ; move column.3{r6}, column{r2}
        mov bl, dl
        ; move height.5{r2}, height.1{r5}
        mov dl, r10b
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], height.5{r2}
        mov [r12], dl
        jmp if_45_end
if_47_then:
        ; const t.9.1{r3}, 8
        mov r8b, 8
        ; sub t.8.1{r3}, width.3{r0}
        sub r8b, al
        ; add column.4{r2}, t.8.1{r3}
        add dl, r8b
        ; move column.3{r6}, column.4{r2}
        mov bl, dl
        ; move height.5{r2}, height.1{r5}
        mov dl, r10b
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], height.5{r2}
        mov [r12], dl
if_45_end:
        ; const spaces.1{r2}, [string-14]
        lea rdx, [string_14]
        ; const t.14.1{r3}, 8
        mov r8b, 8
        ; sub t.13.1{r3}, width.5{r0}
        sub r8b, al
        ; cast t.12.1{r0}(i64), t.13.1{r3}(u8)
        movzx rax, r8b
        ; add spaces.2{r2}, t.12.1{r0}
        add rdx, rax
        ; addrof memVarAddr{r7}, spaces.2
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], spaces.2{r2}
        mov [r12], rdx
        ; const line.1{r0}, 0
        mov al, 0
        ; 255:2 for line < height
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+65]
        ; store [memVarAddr{r7}], line.2{r0}
        mov [r12], al
        ; move row.5{r0}, row.5{r1}
        mov al, cl
        ; load line.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        jmp for_50
for_50_body:
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], height.5{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+65]
        ; store [memVarAddr{r7}], line.2{r1}
        mov [r12], cl
        ; move row.5{r1}, row.5{r0}
        mov cl, al
        ; cast t.15.1{r0}(i16), row.5{r1}(u8)
        movzx ax, cl
        ; addrof memVarAddr{r7}, row.5
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], row.5{r1}
        mov [r12], cl
        ; cast t.16.1{r2}(i16), column.3{r6}(u8)
        movzx dx, bl
        ; move t.15.1{r1}, t.15.1{r0}
        mov cx, ax
        ; call _setCursor@i16@i16[t.15.1{r1}, t.16.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r7}, spaces.2
        lea r12, [rsp+56]
        ; load spaces.2{r0}, [memVarAddr{r7}]
        mov rax, [r12]
        ; move spaces.2{r1}, spaces.2{r0}
        mov rcx, rax
        ; call _printString@@u8[spaces.2{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r7}, row.5
        lea r12, [rsp+64]
        ; load row.5{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; add row.6{r0}, 1
        add al, 1
        ; addrof memVarAddr{r7}, line.2
        lea r12, [rsp+65]
        ; load line.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; add line.3{r1}, 1
        add cl, 1
for_50:
        ; addrof memVarAddr{r7}, height.5
        lea r12, [rsp+48]
        ; load height.5{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; branch line.2{r1} lt height.5{r2}: for_50_body
        cmp cl, dl
        jb for_50_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; bool _drawMoveFrame@u8@u8@u8@bool
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
        ;   rsp+58: var row.3
        ;   rsp+59: var column.3
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
        ; and t.17.1{r1}, 1
        and cl, 1
        ; notequals forward.1{r1}, t.17.1{r1}, 0
        cmp cl, 0
        setne cl
        ; const pending.1{r5}, 0
        mov r10b, 0
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
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
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
        ; move count.2{r0}, count.2{r6}
        mov al, bl
        ; move pending.2{r1}, pending.2{r5}
        mov cl, r10b
        jmp for_51
for_51_body:
        ; move count.2{r6}, count.2{r0}
        mov bl, al
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; load horizontal.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move pending.2{r5}, pending.2{r1}
        mov r10b, cl
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; load previous{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, travel
        lea r12, [rsp+96]
        ; load travel{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; load forward.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; move index.1{r4}, count.2{r6}
        mov r9b, bl
        ; 269:3 if !forward
        ; branch forward.1{r1} notequals 0: if_52_end
        cmp cl, 0
        jne if_52_end
        ; const t.18.1{r4}, 15
        mov r9b, 15
        ; sub index.3{r4}, count.2{r6}
        sub r9b, bl
if_52_end:
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
        jne if_53_end
        ; move pending.4{r6}, pending.2{r5}
        mov bl, r10b
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], previous{r2}
        mov [r12], dl
        jmp for_51_continue
if_53_end:
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
        ; load t.21.1{r3}, [t.22.2{r3}]
        mov r8b, [r8]
        ; move target.1{r6}, t.21.1{r3}
        mov bl, r8b
        ; and target.1{r6}, 15
        and bl, 15
        ; move distance.1{r3}, index.2{r4}
        mov r8b, r9b
        ; sub distance.1{r3}, target.1{r6}
        sub r8b, bl
        ; 280:3 if forward
        ; branch forward.1{r1} equals 0: if_54_end
        cmp cl, 0
        je if_54_end
        ; move distance.3{r3}, target.1{r6}
        mov r8b, bl
        ; sub distance.3{r3}, index.2{r4}
        sub r8b, r9b
if_54_end:
        ; branch horizontal.1{r0} notequals 0: if_55_then
        cmp al, 0
        jne if_55_then
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r0}
        mov [r12], al
        jmp if_55_end
if_55_then:
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
if_55_end:
        ; move oldOffset.1{r0}, previous{r2}
        mov al, dl
        ; addrof memVarAddr{r7}, previous
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], previous{r2}
        mov [r12], dl
        ; 289:3 if oldOffset > distance
        ; branch oldOffset.1{r0} lteq distance.4{r3}: if_56_end
        cmp al, r8b
        jbe if_56_end
        ; move oldOffset.3{r0}, distance.4{r3}
        mov al, r8b
if_56_end:
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
        jae if_57_then
        ; const pending.8{r4}, 1
        mov r9b, 1
        ; addrof memVarAddr{r7}, distance.4
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], distance.4{r3}
        mov [r12], r8b
        jmp if_57_end
if_57_then:
        ; move offset.3{r2}, distance.4{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, distance.4
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], distance.4{r3}
        mov [r12], r8b
        ; move pending.9{r4}, pending.2{r5}
        mov r9b, r10b
if_57_end:
        ; branch oldOffset.2{r0} equals offset.2{r2}: and_59
        cmp al, dl
        je and_59
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
        ; addrof memVarAddr{r7}, exponent.1
        lea r12, [rsp+52]
        ; load exponent.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp if_58_end
and_59:
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; load erase{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; branch erase{r3} equals 0: or_60
        cmp r8b, 0
        je or_60
        ; move pending.4{r6}, pending.9{r4}
        mov bl, r9b
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
        jmp for_51_continue
or_60:
        ; cast t.27.1{r5}(i64), target.1{r6}(u8)
        movzx r10, bl
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r6}
        mov [r12], bl
        ; addrof t.26.1{r6}, tiles
        lea rbx, [var_1]
        ; add t.26.2{r6}, t.27.1{r5}
        add rbx, r10
        ; load t.25.1{r5}, [t.26.2{r6}]
        mov r10b, [rbx]
        ; addrof memVarAddr{r7}, exponent.1
        lea r12, [rsp+52]
        ; load exponent.1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; branch exponent.1{r6} notequals t.25.1{r5}: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        cmp bl, r10b
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        ; move pending.4{r6}, pending.9{r4}
        mov bl, r9b
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
        jmp for_51_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46:
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], pending.9{r4}
        mov [r12], r9b
if_58_end:
        ; move displacement.1{r4}, offset.2{r2}
        mov r9b, dl
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+57]
        ; store [memVarAddr{r7}], offset.2{r2}
        mov [r12], dl
        ; 307:3 if erase
        ; branch erase{r3} notequals 0: if_61_then
        cmp r8b, 0
        jne if_61_then
        ; addrof memVarAddr{r7}, oldOffset.2
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], oldOffset.2{r0}
        mov [r12], al
        jmp if_61_end
if_61_then:
        ; move displacement.3{r2}, oldOffset.2{r0}
        mov dl, al
        ; addrof memVarAddr{r7}, oldOffset.2
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], oldOffset.2{r0}
        mov [r12], al
if_61_end:
        ; branch forward.1{r1} notequals 0: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41, if_62_then
        cmp cl, 0
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
        jmp if_62_then
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_41:
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
        ; move displacement.4{r0}, displacement.2{r2}
        mov al, dl
        jmp if_62_end
if_62_then:
        ; addrof memVarAddr{r7}, forward.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], forward.1{r1}
        mov [r12], cl
        ; const t.28.1{r0}, 0
        mov al, 0
        ; sub displacement.5{r0}, displacement.2{r2}
        sub al, dl
if_62_end:
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; load index.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; move t.29.1{r2}, index.2{r1}
        mov dl, cl
        ; and t.29.1{r2}, 12
        and dl, 12
        ; add row.1{r2}, 3
        add dl, 3
        ; move column.1{r4}, index.2{r1}
        mov r9b, cl
        ; and column.1{r4}, 3
        and r9b, 3
        ; move t.31.1{r1}, column.1{r4}
        mov cl, r9b
        ; shiftleft t.31.1{r1}, 3
        shl cl, 3
        ; add t.30.1{r1}, 1
        add cl, 1
        ; add column.2{r4}, t.30.1{r1}
        add r9b, cl
        ; 319:3 if horizontal
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; load horizontal.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; branch horizontal.1{r1} notequals 0: if_63_then
        cmp cl, 0
        jne if_63_then
        ; move row.2{r1}, row.1{r2}
        mov cl, dl
        ; add row.2{r1}, displacement.4{r0}
        add cl, al
        ; move column.3{r2}, column.2{r4}
        mov dl, r9b
        jmp if_63_end
if_63_then:
        ; addrof memVarAddr{r7}, horizontal.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], horizontal.1{r1}
        mov [r12], cl
        ; add column.4{r4}, displacement.4{r0}
        add r9b, al
        ; move row.3{r1}, row.1{r2}
        mov cl, dl
        ; move column.3{r2}, column.4{r4}
        mov dl, r9b
if_63_end:
        ; branch erase{r3} equals 0: if_64_else, if_64_then
        cmp r8b, 0
        je if_64_else
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        jmp if_64_then
if_64_else:
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        ; cast t.33.1{r1}(i16), row.3{r1}(u8)
        movzx cx, cl
        ; cast t.34.1{r2}(i16), column.3{r2}(u8)
        movzx dx, dl
        ; move exponent.1{r3}, exponent.1{r6}
        mov r8b, bl
        ; call _drawTileAt@i16@i16@u8[t.33.1{r1}, t.34.1{r2}, exponent.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; 331:4 if offset == distance
        ; addrof memVarAddr{r7}, distance.4
        lea r12, [rsp+54]
        ; load distance.4{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, offset.2
        lea r12, [rsp+57]
        ; load offset.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; branch offset.2{r0} notequals distance.4{r1}: _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42, if_65_then
        cmp al, cl
        jne _drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42
        jmp if_65_then
if_64_then:
        ; addrof memVarAddr{r7}, column.3
        lea r12, [rsp+59]
        ; store [memVarAddr{r7}], column.3{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, erase
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], erase{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, row.3
        lea r12, [rsp+58]
        ; store [memVarAddr{r7}], row.3{r1}
        mov [r12], cl
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
        ; addrof memVarAddr{r7}, direction
        lea r12, [rsp+80]
        ; load direction{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move direction{r3}, direction{r0}
        mov r8b, al
        ; call _clearTileTrail@u8@u8@u8@u8[row.3{r1}, column.3{r2}, direction{r3}, t.32.1{r4}]
        call _clearTileTrail@u8@u8@u8@u8
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; load pending.9{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp for_51_continue
_drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42:
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; load pending.9{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        jmp for_51_continue
if_65_then:
        ; addrof memVarAddr{r7}, pending.9
        lea r12, [rsp+56]
        ; load pending.9{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; 332:5 if [...] & 128 != 0
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; load index.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.38.1{r1}(i64), index.2{r0}(u8)
        movzx rcx, al
        ; addrof t.37.1{r2}, moveTargets
        lea rdx, [var_3]
        ; add t.37.2{r2}, t.38.1{r1}
        add rdx, rcx
        ; load t.36.1{r1}, [t.37.2{r2}]
        mov cl, [rdx]
        ; and t.35.1{r1}, 128
        and cl, 128
        ; branch t.35.1{r1} notequals 0: if_66_then
        cmp cl, 0
        jne if_66_then
        ; 336:10 if [...] & 64 != 0
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.51.1{r1}(i64), target.1{r2}(u8)
        movzx rcx, dl
        ; addrof t.50.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.50.2{r3}, t.51.1{r1}
        add r8, rcx
        ; load t.49.1{r1}, [t.50.2{r3}]
        mov cl, [r8]
        ; and t.48.1{r1}, 64
        and cl, 64
        ; branch t.48.1{r1} equals 0: for_51_continue, if_67_then
        cmp cl, 0
        je for_51_continue
        jmp if_67_then
if_66_then:
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; cast t.42.1{r1}(i64), target.1{r2}(u8)
        movzx rcx, dl
        ; addrof t.41.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.41.2{r3}, t.42.1{r1}
        add r8, rcx
        ; load t.40.1{r1}, [t.41.2{r3}]
        mov cl, [r8]
        ; or t.39.1{r1}, 64
        or cl, 64
        ; cast t.44.1{r2}(i64), target.1{r2}(u8)
        movzx rdx, dl
        ; addrof t.43.1{r3}, moveTargets
        lea r8, [var_3]
        ; add t.43.2{r3}, t.44.1{r2}
        add r8, rdx
        ; store [t.43.2{r3}], t.39.1{r1}
        mov [r8], cl
        ; const t.45.1{r1}, 0
        mov cl, 0
        ; cast t.47.1{r0}(i64), index.2{r0}(u8)
        movzx rax, al
        ; addrof t.46.1{r2}, moveTiles
        lea rdx, [var_2]
        ; add t.46.2{r2}, t.47.1{r0}
        add rdx, rax
        ; store [t.46.2{r2}], t.45.1{r1}
        mov [rdx], cl
        jmp for_51_continue
if_67_then:
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], index.2{r0}
        mov [r12], al
        ; move target.1{r1}, target.1{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r2}
        mov [r12], dl
        ; call t.53.1{r0} = _tileRow@u8[target.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.52.1{r1}(i16), t.53.1{r0}(u8)
        movzx cx, al
        ; addrof memVarAddr{r7}, t.52.1
        lea r12, [rsp+60]
        ; store [memVarAddr{r7}], t.52.1{r1}
        mov [r12], cx
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move target.1{r1}, target.1{r0}
        mov cl, al
        ; call t.55.1{r0} = _tileColumn@u8[target.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.54.1{r2}(i16), t.55.1{r0}(u8)
        movzx dx, al
        ; load target.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; cast t.58.1{r0}(i64), target.1{r0}(u8)
        movzx rax, al
        ; addrof t.57.1{r1}, tiles
        lea rcx, [var_1]
        ; add t.57.2{r1}, t.58.1{r0}
        add rcx, rax
        ; load t.56.1{r3}, [t.57.2{r1}]
        mov r8b, [rcx]
        ; addrof memVarAddr{r7}, t.52.1
        lea r12, [rsp+60]
        ; load t.52.1{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; call _drawTileAt@i16@i16@u8[t.52.1{r1}, t.54.1{r2}, t.56.1{r3}]
        call _drawTileAt@i16@i16@u8
        ; const t.59.1{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r7}, index.2
        lea r12, [rsp+51]
        ; load index.2{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.61.1{r1}(i64), index.2{r1}(u8)
        movzx rcx, cl
        ; addrof t.60.1{r2}, moveTiles
        lea rdx, [var_2]
        ; add t.60.2{r2}, t.61.1{r1}
        add rdx, rcx
        ; store [t.60.2{r2}], t.59.1{r0}
        mov [rdx], al
for_51_continue:
        ; addrof memVarAddr{r7}, count.2
        lea r12, [rsp+50]
        ; load count.2{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; add count.5{r0}, 1
        add al, 1
        ; move pending.2{r1}, pending.4{r6}
        mov cl, bl
for_51:
        ; branch count.2{r0} lt 16: for_51_body
        cmp al, 16
        jb for_51_body
        ; 343:9 return pending
        ; move pending.2{r0}, pending.2{r1}
        mov al, cl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void _animateMove@u8
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
        ; const speed.1{r1}, 1
        mov cl, 1
        ; const pending.1{r2}, 1
        mov dl, 1
        ; 352:2 while pending
        ; addrof memVarAddr{r7}, pending.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], pending.2{r2}
        mov [r12], dl
        jmp while_68
while_68_body:
        ; move previous.1{r3}, travel.2{r0}
        mov r8b, al
        ; add travel.3{r0}, speed.2{r1}
        add al, cl
        ; add speed.3{r1}, 1
        add cl, 1
        ; addrof memVarAddr{r7}, speed.3
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], speed.3{r1}
        mov [r12], cl
        ; const t.7.1{r4}, 1
        mov r9b, 1
        ; move direction{r1}, direction{r6}
        mov cl, bl
        ; move previous.1{r2}, previous.1{r3}
        mov dl, r8b
        ; addrof memVarAddr{r7}, previous.1
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], previous.1{r3}
        mov [r12], r8b
        ; move travel.3{r3}, travel.3{r0}
        mov r8b, al
        ; addrof memVarAddr{r7}, travel.3
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], travel.3{r0}
        mov [r12], al
        ; call _ = _drawMoveFrame@u8@u8@u8@bool[direction{r1}, previous.1{r2}, travel.3{r3}, t.7.1{r4}] -> bool
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
        ; load travel.3{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move travel.3{r3}, travel.3{r0}
        mov r8b, al
        ; call pending.3{r0} = _drawMoveFrame@u8@u8@u8@bool[direction{r1}, previous.1{r2}, travel.3{r3}, t.8.1{r4}] -> bool
        call _drawMoveFrame@u8@u8@u8@bool
        ; addrof memVarAddr{r7}, pending.3
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], pending.3{r0}
        mov [r12], al
        ; call _waitFrame[]
        call _waitFrame
        ; addrof memVarAddr{r7}, travel.3
        lea r12, [rsp+50]
        ; load travel.3{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; move travel.2{r0}, travel.3{r3}
        mov al, r8b
        ; addrof memVarAddr{r7}, speed.3
        lea r12, [rsp+51]
        ; load speed.3{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, pending.3
        lea r12, [rsp+52]
        ; load pending.3{r2}, [memVarAddr{r7}]
        mov dl, [r12]
while_68:
        ; branch pending.2{r2} notequals 0: while_68_body
        cmp dl, 0
        jne while_68_body
        ; const index.1{r0}, 0
        mov al, 0
        ; 362:2 for index < 16
        ; move index.2{r6}, index.1{r0}
        mov bl, al
        jmp for_69
for_69_body:
        ; cast t.11.1{r0}(i64), index.2{r6}(u8)
        movzx rax, bl
        ; addrof t.10.1{r1}, moveTargets
        lea rcx, [var_3]
        ; add t.10.2{r1}, t.11.1{r0}
        add rcx, rax
        ; load t.9.1{r0}, [t.10.2{r1}]
        mov al, [rcx]
        ; and target.1{r0}, 15
        and al, 15
        ; 364:3 if [...] != 0 && [...] != [...]
        ; cast t.14.1{r1}(i64), index.2{r6}(u8)
        movzx rcx, bl
        ; addrof t.13.1{r2}, moveTiles
        lea rdx, [var_2]
        ; add t.13.2{r2}, t.14.1{r1}
        add rdx, rcx
        ; load t.12.1{r1}, [t.13.2{r2}]
        mov cl, [rdx]
        ; branch t.12.1{r1} equals 0: for_69_continue
        cmp cl, 0
        je for_69_continue
        ; cast t.17.1{r1}(i64), index.2{r6}(u8)
        movzx rcx, bl
        ; addrof t.16.1{r2}, moveTiles
        lea rdx, [var_2]
        ; add t.16.2{r2}, t.17.1{r1}
        add rdx, rcx
        ; load t.15.1{r1}, [t.16.2{r2}]
        mov cl, [rdx]
        ; cast t.20.1{r2}(i64), target.1{r0}(u8)
        movzx rdx, al
        ; addrof t.19.1{r3}, tiles
        lea r8, [var_1]
        ; add t.19.2{r3}, t.20.1{r2}
        add r8, rdx
        ; load t.18.1{r2}, [t.19.2{r3}]
        mov dl, [r8]
        ; branch t.15.1{r1} equals t.18.1{r2}: for_69_continue
        cmp cl, dl
        je for_69_continue
        ; move target.1{r1}, target.1{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; store [memVarAddr{r7}], target.1{r0}
        mov [r12], al
        ; call t.23.1{r0} = _tileRow@u8[target.1{r1}] -> u8
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
        ; load target.1{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move target.1{r1}, target.1{r0}
        mov cl, al
        ; call t.26.1{r0} = _tileColumn@u8[target.1{r1}] -> u8
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
        ; call _setCursor@i16@i16[t.21.1{r1}, t.24.1{r2}]
        call _setCursor@i16@i16
        ; addrof memVarAddr{r7}, target.1
        lea r12, [rsp+53]
        ; load target.1{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; cast t.29.1{r0}(i64), target.1{r1}(u8)
        movzx rax, cl
        ; addrof t.28.1{r1}, tiles
        lea rcx, [var_1]
        ; add t.28.2{r1}, t.29.1{r0}
        add rcx, rax
        ; load t.27.1{r1}, [t.28.2{r1}]
        mov cl, [rcx]
        ; call _printTile@u8[t.27.1{r1}]
        call _printTile@u8
for_69_continue:
        ; move index.4{r0}, index.2{r6}
        mov al, bl
        ; add index.4{r0}, 1
        add al, 1
        ; move index.2{r6}, index.4{r0}
        mov bl, al
for_69:
        ; branch index.2{r6} lt 16: for_69_body
        cmp bl, 16
        jb for_69_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _drawFrame
_drawFrame:
        sub rsp, 8
        sub rsp, 32
        ; const arg.0.0{r1}, 1
        mov cx, 1
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-15]
        lea rcx, [string_15]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void _clearBoard
_clearBoard:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const row.1{r0}, 0
        mov ax, 0
        ; 404:2 for row < 15
        ; move row.2{r6}, row.1{r0}
        mov bx, ax
        jmp for_72
for_72_body:
        ; move t.1.1{r1}, row.2{r6}
        mov cx, bx
        ; add t.1.1{r1}, 3
        add cx, 3
        ; const arg.0.1{r2}, 1
        mov dx, 1
        ; call _setCursor@i16@i16[t.1.1{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.2.1{r1}, [string-16]
        lea rcx, [string_16]
        ; call _printString@@u8[t.2.1{r1}]
        call _printString@@u8
        ; move row.3{r0}, row.2{r6}
        mov ax, bx
        ; add row.3{r0}, 1
        add ax, 1
        ; move row.2{r6}, row.3{r0}
        mov bx, ax
for_72:
        ; branch row.2{r6} lt 15: for_72_body
        cmp bx, 15
        jl for_72_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _drawBoard
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
        ; call _clearBoard[]
        call _clearBoard
        ; const index.1{r0}, 0
        mov al, 0
        ; const row.1{r1}, 3
        mov cx, 3
        ; const boardRow.1{r2}, 0
        mov dl, 0
        ; 414:2 for boardRow < 4
        ; move index.2{r6}, index.1{r0}
        mov bl, al
        ; move row.2{r0}, row.1{r1}
        mov ax, cx
        ; move boardRow.2{r1}, boardRow.1{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r1}
        mov [r12], cl
        ; move row.2{r1}, row.2{r0}
        mov cx, ax
        jmp for_73
for_73_body:
        ; addrof memVarAddr{r7}, boardRow.2
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], boardRow.2{r2}
        mov [r12], dl
        ; move row.2{r0}, row.2{r1}
        mov ax, cx
        ; const column.1{r1}, 1
        mov cx, 1
        ; const boardColumn.1{r2}, 0
        mov dl, 0
        ; 416:3 for boardColumn < 4
        ; move column.2{r3}, column.1{r1}
        mov r8w, cx
        ; move boardColumn.2{r1}, boardColumn.1{r2}
        mov cl, dl
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], boardColumn.2{r1}
        mov [r12], cl
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], row.2{r0}
        mov [r12], ax
        ; move column.2{r2}, column.2{r3}
        mov dx, r8w
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; move boardColumn.2{r3}, boardColumn.2{r1}
        mov r8b, cl
        jmp for_74
for_74_body:
        ; addrof memVarAddr{r7}, boardColumn.2
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], boardColumn.2{r3}
        mov [r12], r8b
        ; move column.2{r3}, column.2{r2}
        mov r8w, dx
        ; addrof memVarAddr{r7}, row.2
        lea r12, [rsp+48]
        ; load row.2{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; cast t.7.1{r1}(i64), index.3{r6}(u8)
        movzx rcx, bl
        ; addrof t.6.1{r2}, tiles
        lea rdx, [var_1]
        ; add t.6.2{r2}, t.7.1{r1}
        add rdx, rcx
        ; load t.5.1{r4}, [t.6.2{r2}]
        mov r9b, [rdx]
        ; move row.2{r1}, row.2{r0}
        mov cx, ax
        ; move column.2{r2}, column.2{r3}
        mov dx, r8w
        ; addrof memVarAddr{r7}, column.2
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], column.2{r3}
        mov [r12], r8w
        ; move t.5.1{r3}, t.5.1{r4}
        mov r8b, r9b
        ; call _drawTileAt@i16@i16@u8[row.2{r1}, column.2{r2}, t.5.1{r3}]
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
for_74:
        ; branch boardColumn.2{r3} lt 4: for_74_body
        cmp r8b, 4
        jb for_74_body
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
for_73:
        ; branch boardRow.2{r2} lt 4: for_73_body
        cmp dl, 4
        jb for_73_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _drawScore
_drawScore:
        sub rsp, 8
        sub rsp, 32
        ; const arg.0.0{r1}, 0
        mov cx, 0
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-17]
        lea rcx, [string_17]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; addrof a.1.1{r0}, score
        lea rax, [var_4]
        ; load t.2.1{r1}, [a.1.1{r0}]
        mov ecx, [rax]
        ; call _printUint@i32[t.2.1{r1}]
        call _printUint@i32
        ; const t.3.1{r1}, [string-18]
        lea rcx, [string_18]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void _drawStatus
_drawStatus:
        sub rsp, 8
        sub rsp, 32
        ; const arg.0.0{r1}, 19
        mov cx, 19
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const t.0.1{r1}, [string-19]
        lea rcx, [string_19]
        ; call _printString@@u8[t.0.1{r1}]
        call _printString@@u8
        ; const arg.2.0{r1}, 19
        mov cx, 19
        ; const arg.2.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; 436:2 if gameState == 1
        ; addrof a.1.1{r0}, gameState
        lea rax, [var_5]
        ; load t.2.1{r0}, [a.1.1{r0}]
        mov al, [rax]
        ; branch t.2.1{r0} equals 1: if_75_then
        cmp al, 1
        je if_75_then
        ; 439:7 if gameState == 2
        ; addrof a.4.1{r0}, gameState
        lea rax, [var_5]
        ; load t.5.1{r0}, [a.4.1{r0}]
        mov al, [rax]
        ; branch t.5.1{r0} notequals 2: _drawStatus_ret, if_76_then
        cmp al, 2
        jne _drawStatus_ret
        jmp if_76_then
if_75_then:
        ; const t.3.1{r1}, [string-20]
        lea rcx, [string_20]
        ; call _printString@@u8[t.3.1{r1}]
        call _printString@@u8
        jmp _drawStatus_ret
if_76_then:
        ; const t.6.1{r1}, [string-21]
        lea rcx, [string_21]
        ; call _printString@@u8[t.6.1{r1}]
        call _printString@@u8
_drawStatus_ret:
        add rsp, 32
        add rsp, 8
        ret

        ; void _newGame
_newGame:
        sub rsp, 8
        sub rsp, 32
        ; const index.1{r0}, 0
        mov al, 0
        ; 445:2 for index < 16
        jmp for_77
for_77_body:
        ; const t.1.1{r1}, 0
        mov cl, 0
        ; cast t.3.1{r2}(i64), index.2{r0}(u8)
        movzx rdx, al
        ; addrof t.2.1{r3}, tiles
        lea r8, [var_1]
        ; add t.2.2{r3}, t.3.1{r2}
        add r8, rdx
        ; store [t.2.2{r3}], t.1.1{r1}
        mov [r8], cl
        ; add index.3{r0}, 1
        add al, 1
for_77:
        ; branch index.2{r0} lt 16: for_77_body
        cmp al, 16
        jb for_77_body
        ; const t.4.1{r0}, 0
        mov eax, 0
        ; addrof a.5.1{r1}, score
        lea rcx, [var_4]
        ; store [a.5.1{r1}], t.4.1{r0}
        mov [rcx], eax
        ; call _drawScore[]
        call _drawScore
        ; const t.6.1{r0}, 0
        mov al, 0
        ; addrof a.7.1{r1}, gameState
        lea rcx, [var_5]
        ; store [a.7.1{r1}], t.6.1{r0}
        mov [rcx], al
        ; call _ = _spawnTile[] -> u8
        call _spawnTile
        ; call _ = _spawnTile[] -> u8
        call _spawnTile
        ; call _drawBoard[]
        call _drawBoard
        ; call _drawStatus[]
        call _drawStatus
        ; const arg.5.0{r1}, 21
        mov cx, 21
        ; const arg.5.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.5.0{r1}, arg.5.1{r2}]
        call _setCursor@i16@i16
        add rsp, 32
        add rsp, 8
        ret

        ; void _main
        ;   rsp+48: var t.12.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.3.1{r0}, 0
        mov eax, 0
        ; addrof a.4.1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.4.1{r1}], t.3.1{r0}
        mov [rcx], eax
        ; addrof a.6.1{r1}, score
        lea rcx, [var_4]
        ; store [a.6.1{r1}], t.5.1{r0}
        mov [rcx], eax
        ; const t.7.1{r0}, 0
        mov al, 0
        ; addrof a.8.1{r1}, gameState
        lea rcx, [var_5]
        ; store [a.8.1{r1}], t.7.1{r0}
        mov [rcx], al
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call _initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; call _drawFrame[]
        call _drawFrame
        ; call _newGame[]
        call _newGame
        ; 462:2 while true
        jmp while_78
if_79_end:
        ; branch key.1{r6} equals 114: if_80_then
        cmp bx, 114
        je if_80_then
        ; branch key.1{r6} equals 82: if_80_then
        cmp bx, 82
        je if_80_then
        ; 471:3 if gameState != 0
        ; addrof a.9.1{r0}, gameState
        lea rax, [var_5]
        ; load t.10.1{r0}, [a.9.1{r0}]
        mov al, [rax]
        ; branch t.10.1{r0} notequals 0: while_78
        cmp al, 0
        jne while_78
        ; branch key.1{r6} equals -8117: if_83_then, or_85
        cmp bx, -8117
        je if_83_then
        jmp or_85
if_80_then:
        ; call _newGame[]
        call _newGame
        jmp while_78
or_85:
        ; branch key.1{r6} equals 97: if_83_then
        cmp bx, 97
        je if_83_then
        ; branch key.1{r6} equals 65: if_83_then
        cmp bx, 65
        je if_83_then
        ; branch key.1{r6} equals -8115: if_86_then
        cmp bx, -8115
        je if_86_then
        ; branch key.1{r6} equals 100: if_86_then, or_87
        cmp bx, 100
        je if_86_then
        jmp or_87
if_83_then:
        ; const direction.2{r0}, 0
        mov al, 0
        ; move direction.3{r6}, direction.2{r0}
        mov bl, al
        jmp if_83_end
or_87:
        ; branch key.1{r6} equals 68: if_86_then
        cmp bx, 68
        je if_86_then
        ; branch key.1{r6} equals -8120: if_89_then
        cmp bx, -8120
        je if_89_then
        ; branch key.1{r6} equals 119: if_89_then, or_90
        cmp bx, 119
        je if_89_then
        jmp or_90
if_86_then:
        ; const direction.4{r0}, 1
        mov al, 1
        ; move direction.3{r6}, direction.4{r0}
        mov bl, al
        jmp if_83_end
or_90:
        ; branch key.1{r6} equals 87: if_89_then
        cmp bx, 87
        je if_89_then
        ; branch key.1{r6} equals -8112: if_92_then
        cmp bx, -8112
        je if_92_then
        ; branch key.1{r6} equals 115: if_92_then, or_93
        cmp bx, 115
        je if_92_then
        jmp or_93
if_89_then:
        ; const direction.5{r0}, 2
        mov al, 2
        ; move direction.3{r6}, direction.5{r0}
        mov bl, al
        jmp if_83_end
or_93:
        ; branch key.1{r6} notequals 83: while_78, if_92_then
        cmp bx, 83
        jne while_78
if_92_then:
        ; const direction.6{r0}, 3
        mov al, 3
        ; move direction.3{r6}, direction.6{r0}
        mov bl, al
if_83_end:
        ; 491:3 if !_slide@u8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=491:13]])
        ; move direction.3{r1}, direction.3{r6}
        mov cl, bl
        ; call t.11.1{r0} = _slide@u8[direction.3{r1}] -> bool
        call _slide@u8
        ; branch t.11.1{r0} equals 0: while_78
        cmp al, 0
        je while_78
        ; move direction.3{r1}, direction.3{r6}
        mov cl, bl
        ; call _animateMove@u8[direction.3{r1}]
        call _animateMove@u8
        ; call spawned.1{r0} = _spawnTile[] -> u8
        call _spawnTile
        ; move spawned.1{r6}, spawned.1{r0}
        mov bl, al
        ; 497:3 if spawned != 255
        ; branch spawned.1{r6} equals 255: if_96_end
        cmp bl, 255
        je if_96_end
        ; move spawned.1{r1}, spawned.1{r6}
        mov cl, bl
        ; call t.13.1{r0} = _tileRow@u8[spawned.1{r1}] -> u8
        call _tileRow@u8
        ; cast t.12.1{r1}(i16), t.13.1{r0}(u8)
        movzx cx, al
        ; addrof memVarAddr{r7}, t.12.1
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], t.12.1{r1}
        mov [r12], cx
        ; move spawned.1{r1}, spawned.1{r6}
        mov cl, bl
        ; call t.15.1{r0} = _tileColumn@u8[spawned.1{r1}] -> u8
        call _tileColumn@u8
        ; cast t.14.1{r2}(i16), t.15.1{r0}(u8)
        movzx dx, al
        ; cast t.18.1{r0}(i64), spawned.1{r6}(u8)
        movzx rax, bl
        ; addrof t.17.1{r1}, tiles
        lea rcx, [var_1]
        ; add t.17.2{r1}, t.18.1{r0}
        add rcx, rax
        ; load t.16.1{r3}, [t.17.2{r1}]
        mov r8b, [rcx]
        ; load t.12.1{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; call _drawTileAt@i16@i16@u8[t.12.1{r1}, t.14.1{r2}, t.16.1{r3}]
        call _drawTileAt@i16@i16@u8
if_96_end:
        ; 500:3 if gameState == 0 && !_canMove([])
        ; addrof a.19.1{r0}, gameState
        lea rax, [var_5]
        ; load t.20.1{r0}, [a.19.1{r0}]
        mov al, [rax]
        ; branch t.20.1{r0} notequals 0: if_97_end
        cmp al, 0
        jne if_97_end
        ; call t.21.1{r0} = _canMove[] -> bool
        call _canMove
        ; branch t.21.1{r0} notequals 0: if_97_end
        cmp al, 0
        jne if_97_end
        ; const t.22.1{r0}, 2
        mov al, 2
        ; addrof a.23.1{r1}, gameState
        lea rcx, [var_5]
        ; store [a.23.1{r1}], t.22.1{r0}
        mov [rcx], al
if_97_end:
        ; call _drawScore[]
        call _drawScore
        ; 504:3 if gameState != 0
        ; addrof a.24.1{r0}, gameState
        lea rax, [var_5]
        ; load t.25.1{r0}, [a.24.1{r0}]
        mov al, [rax]
        ; branch t.25.1{r0} equals 0: if_99_end
        cmp al, 0
        je if_99_end
        ; call _drawStatus[]
        call _drawStatus
if_99_end:
        ; const arg.13.0{r1}, 21
        mov cx, 21
        ; const arg.13.1{r2}, 0
        mov dx, 0
        ; call _setCursor@i16@i16[arg.13.0{r1}, arg.13.1{r2}]
        call _setCursor@i16@i16
while_78:
        ; call key.1{r0} = _getChar[] -> i16
        call _getChar
        ; move key.1{r6}, key.1{r0}
        mov bx, ax
        ; 464:3 if key == 27
        ; branch key.1{r6} notequals 27: if_79_end
        cmp bx, 27
        jne if_79_end
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _printStringLength@@u8@i64
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

        ; i16 _getChar
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

        ; void _setCursor@i16@i16
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

        ; void _waitFrame
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
