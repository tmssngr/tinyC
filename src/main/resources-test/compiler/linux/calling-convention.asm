format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printChar@u8
        ;   rsp+32: arg chr
@printChar@u8:
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
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const t.2{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+24: arg number
        ;   rsp+40: var buffer
@printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos{r8}, 20
        mov bl, 20
        ; 21:2 while true
@while_1:
        ; const t.5{r4}, 1
        mov cl, 1
        ; sub pos{r8}, pos{r8}, t.5{r4}
        sub bl, cl
        ; const t.6{r4}, 10
        mov rcx, 10
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, t.6{r4}
        cqo
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; const t.7{r4}, 10
        mov rcx, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.7{r4}
        cqo
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.8{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; const t.9{r3}, 48
        mov dl, 48
        ; add digit{r0}, digit{r0}, t.9{r3}
        add al, dl
        ; cast t.11{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.10{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.10{r4}, t.10{r4}, t.11{r3}
        add rcx, rdx
        ; store [t.10{r4}], digit{r0}
        mov [rcx], al
        ; 27:3 if number == 0
        ; const t.13{r0}, 0
        mov rax, 0
        ; equals t.12{r0}, number{r1}, t.13{r0}
        cmp rdi, rax
        sete al
        ; branch t.12{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.15{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.14{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rdi, rax
        ; const t.17{r0}, 20
        mov al, 20
        ; move t.16{r2}, t.17{r0}
        mov sil, al
        ; sub t.16{r2}, t.16{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.14{r1}, t.16{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; void printIntLf@i16
        ;   rsp+0: arg number
@printIntLf@i16:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(i16)
        movzx rdi, di
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+32: arg number
@printIntLf@i64:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; 47:2 if number < 0
        ; const t.2{r9}, 0
        mov r12, 0
        ; lt t.1{r9}, number{r8}, t.2{r9}
        cmp rbx, r12
        setl r12b
        ; branch t.1{r9}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const t.3{r1}, 45
        mov dil, 45
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        ; neg number{r8}, number{r8}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const t.4{r1}, 10
        mov dil, 10
        ; call printChar@u8[t.4{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
@printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 24
        ret

        ; i16 printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ;   rsp+32: arg a
        ;   rsp+34: arg b
        ;   rsp+36: arg c
        ;   rsp+38: arg d
        ;   rsp+40: arg e
        ;   rsp+42: arg f
        ;   rsp+64: arg g
        ;   rsp+72: arg h
@printAndSum@i16@i16@i16@i16@i16@i16@i16@i16:
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
        ; store [memVarAddr{r9}], a{r1}
        mov [r12], di
        ; call printIntLf@i16[a{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+34]
        ; load b{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], b{r1}
        mov [r12], di
        ; call printIntLf@i16[b{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+36]
        ; load c{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], c{r1}
        mov [r12], di
        ; call printIntLf@i16[c{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+38]
        ; load d{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], d{r1}
        mov [r12], di
        ; call printIntLf@i16[d{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+40]
        ; load e{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], e{r1}
        mov [r12], di
        ; call printIntLf@i16[e{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+42]
        ; load f{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+42]
        ; store [memVarAddr{r9}], f{r1}
        mov [r12], di
        ; call printIntLf@i16[f{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, g
        lea r12, [rsp+64]
        ; load g{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, g
        lea r12, [rsp+64]
        ; store [memVarAddr{r9}], g{r1}
        mov [r12], di
        ; call printIntLf@i16[g{r1}]
        call @printIntLf@i16
        ; move h{r1}, h{r8}
        mov di, bx
        ; call printIntLf@i16[h{r1}]
        call @printIntLf@i16
        ; 17:35 return a + b + c + d + e + f + g + h
        ; addrof memVarAddr{r9}, a
        lea r12, [rsp+32]
        ; load a{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+34]
        ; load b{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.14{r1}, t.14{r1}, b{r2}
        add di, si
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+36]
        ; load c{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.13{r1}, t.13{r1}, c{r2}
        add di, si
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+38]
        ; load d{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.12{r1}, t.12{r1}, d{r2}
        add di, si
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+40]
        ; load e{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.11{r1}, t.11{r1}, e{r2}
        add di, si
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+42]
        ; load f{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.10{r1}, t.10{r1}, f{r2}
        add di, si
        ; addrof memVarAddr{r9}, g
        lea r12, [rsp+64]
        ; load g{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; add t.9{r1}, t.9{r1}, g{r2}
        add di, si
        ; move t.8{r0}, t.9{r1}
        mov ax, di
        ; add t.8{r0}, t.8{r0}, h{r8}
        add ax, bx
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void main
        ;   rsp+0: var arg.0.6
        ;   rsp+8: var arg.0.7
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 16
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.1{r1}, 1
        mov di, 1
        ; const t.2{r2}, 2
        mov si, 2
        ; const t.3{r3}, 3
        mov dx, 3
        ; const t.4{r4}, 4
        mov cx, 4
        ; const t.5{r5}, 5
        mov r8w, 5
        ; const t.6{r6}, 6
        mov r9w, 6
        ; const t.7{r8}, 7
        mov bx, 7
        ; const t.8{r0}, 8
        mov ax, 8
        ; addrof memVarAddr{r9}, arg.0.6
        lea r12, [rsp+0]
        ; store [memVarAddr{r9}], t.7{r8}
        mov [r12], bx
        ; addrof memVarAddr{r9}, arg.0.7
        lea r12, [rsp+8]
        ; store [memVarAddr{r9}], t.8{r0}
        mov [r12], ax
        ; call sum{r0} = printAndSum@i16@i16@i16@i16@i16@i16@i16@i16[t.1{r1}, t.2{r2}, t.3{r3}, t.4{r4}, t.5{r5}, t.6{r6}, arg.0.6, arg.0.7] -> i16
        call @printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ; move sum{r1}, sum{r0}
        mov di, ax
        ; call printIntLf@i16[sum{r1}]
        call @printIntLf@i16
        add rsp, 16
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

