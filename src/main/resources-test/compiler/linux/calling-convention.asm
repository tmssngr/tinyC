format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

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

        ; void _printUint@i64
        ;   rsp+0: arg number
        ;   rsp+20: var buffer
_printUint@i64:
        sub rsp, 40
        ; const pos.1{r0}, 20
        mov al, 20
        ; 33:2 while true
        jmp while_1
_printUint@i64.no_critical_edge_4:
        ; move pos.2{r0}, pos.3{r2}
        mov al, sil
while_1:
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

        ; void _printIntLf@i16
        ;   rsp+0: arg number
_printIntLf@i16:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
        ; call _printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void _printIntLf@i64
        ;   rsp+24: arg number
_printIntLf@i64:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; branch number{r8} gteq 0: if_3_end
        cmp rbx, 0
        jge if_3_end
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call _printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r0}, number{r8}
        mov rax, rbx
        neg rax
        ; move number.1{r8}, number.2{r0}
        mov rbx, rax
if_3_end:
        ; move number.1{r1}, number.1{r8}
        mov rdi, rbx
        ; call _printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
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

        ; i16 _printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ;   rsp+32: arg a
        ;   rsp+34: arg b
        ;   rsp+36: arg c
        ;   rsp+38: arg d
        ;   rsp+40: arg e
        ;   rsp+42: arg f
        ;   rsp+64: arg g
        ;   rsp+72: arg h
_printAndSum@i16@i16@i16@i16@i16@i16@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, h
        lea r12, [rsp+72]
        ; load h{r8}, [memVarAddr{r9}]
        mov bx, [r12]
        ; move a{r0}, a{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], b{r2}
        mov [r12], si
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dx
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], d{r4}
        mov [r12], cx
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], e{r5}
        mov [r12], r8w
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], f{r6}
        mov [r12], r9w
        ; addrof memVarAddr{r9}, a
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], a{r0}
        mov [r12], ax
        ; call _printIntLf@i16[a{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+34]
        ; load b{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; move b{r1}, b{r2}
        mov di, si
        ; call _printIntLf@i16[b{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+36]
        ; load c{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; move c{r1}, c{r3}
        mov di, dx
        ; call _printIntLf@i16[c{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+38]
        ; load d{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; move d{r1}, d{r4}
        mov di, cx
        ; call _printIntLf@i16[d{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+40]
        ; load e{r5}, [memVarAddr{r9}]
        mov r8w, [r12]
        ; move e{r1}, e{r5}
        mov di, r8w
        ; call _printIntLf@i16[e{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+42]
        ; load f{r6}, [memVarAddr{r9}]
        mov r9w, [r12]
        ; move f{r1}, f{r6}
        mov di, r9w
        ; call _printIntLf@i16[f{r1}]
        call _printIntLf@i16
        ; addrof memVarAddr{r9}, g
        lea r12, [rsp+64]
        ; load g{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move g{r1}, g{r0}
        mov di, ax
        ; call _printIntLf@i16[g{r1}]
        call _printIntLf@i16
        ; move h{r1}, h{r8}
        mov di, bx
        ; call _printIntLf@i16[h{r1}]
        call _printIntLf@i16
        ; 17:35 return a + b + c + d + e + f + g + h
        ; addrof memVarAddr{r9}, a
        lea r12, [rsp+32]
        ; load a{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; move t.14.1{r0}, a{r1}
        mov ax, di
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+34]
        ; load b{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.14.1{r0}, b{r2}
        add ax, si
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+36]
        ; load c{r3}, [memVarAddr{r9}]
        mov dx, [r12]
        ; add t.13.1{r0}, c{r3}
        add ax, dx
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+38]
        ; load d{r4}, [memVarAddr{r9}]
        mov cx, [r12]
        ; add t.12.1{r0}, d{r4}
        add ax, cx
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+40]
        ; load e{r5}, [memVarAddr{r9}]
        mov r8w, [r12]
        ; add t.11.1{r0}, e{r5}
        add ax, r8w
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+42]
        ; load f{r6}, [memVarAddr{r9}]
        mov r9w, [r12]
        ; add t.10.1{r0}, f{r6}
        add ax, r9w
        ; addrof memVarAddr{r9}, g
        lea r12, [rsp+64]
        ; load g{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; add t.9.1{r0}, g{r1}
        add ax, di
        ; add t.8.1{r0}, h{r8}
        add ax, bx
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void _main
        ;   rsp+0: var arg.0.6
        ;   rsp+8: var arg.0.7
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 16
        ; const argLit.0.6{r0}, 7
        mov ax, 7
        ; addrof memVarAddr{r9}, arg.0.6
        lea r12, [rsp+0]
        ; store [memVarAddr{r9}], argLit.0.6{r0}
        mov [r12], ax
        ; const argLit.0.7{r0}, 8
        mov ax, 8
        ; addrof memVarAddr{r9}, arg.0.7
        lea r12, [rsp+8]
        ; store [memVarAddr{r9}], argLit.0.7{r0}
        mov [r12], ax
        ; const arg.0.0{r1}, 1
        mov di, 1
        ; const arg.0.1{r2}, 2
        mov si, 2
        ; const arg.0.2{r3}, 3
        mov dx, 3
        ; const arg.0.3{r4}, 4
        mov cx, 4
        ; const arg.0.4{r5}, 5
        mov r8w, 5
        ; const arg.0.5{r6}, 6
        mov r9w, 6
        ; call sum.1{r0} = _printAndSum@i16@i16@i16@i16@i16@i16@i16@i16[arg.0.0{r1}, arg.0.1{r2}, arg.0.2{r3}, arg.0.3{r4}, arg.0.4{r5}, arg.0.5{r6}, arg.0.6, arg.0.7] -> i16
        call _printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ; move sum.1{r1}, sum.1{r0}
        mov di, ax
        ; call _printIntLf@i16[sum.1{r1}]
        call _printIntLf@i16
        add rsp, 16
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

