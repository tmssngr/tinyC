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
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
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
_printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos{r8}, 20
        mov bl, 20
        ; 33:2 while true
_while_1:
        ; sub pos{r8}, pos{r8}, 1
        sub bl, 1
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.5{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.6{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.6{r4}, t.6{r4}, t.7{r3}
        add rcx, rdx
        ; store [t.6{r4}], digit{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number{r1} notequals 0: while_1, while_1_break
        cmp rdi, 0
        jne _while_1
        ; cast t.9{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.8{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.8{r1}, t.8{r1}, t.9{r0}
        add rdi, rax
        ; const t.11{r0}, 20
        mov al, 20
        ; move t.10{r2}, t.11{r0}
        mov sil, al
        ; sub t.10{r2}, t.10{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.8{r1}, t.10{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; void printIntLf@u8
        ;   rsp+0: arg number
_printIntLf@u8:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call printIntLf@i64[t.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
_printIntLf@i64:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; 59:2 if number < 0
        ; branch number{r8} gteq 0: if_3_end, if_3_then
        cmp rbx, 0
        jge _if_3_end
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number{r8}, number{r8}
        neg rbx
_if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint@i64[number{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const chr{r8}, 32
        mov bl, 32
        ; const t.3{r9}, 0
        mov r12, 0
        ; addrof t.2{r0}, [chars]
        lea rax, [var_0]
        ; add t.2{r0}, t.2{r0}, t.3{r9}
        add rax, r12
        ; store [t.2{r0}], chr{r8}
        mov [rax], bl
        ; const t.7{r8}, 0
        mov rbx, 0
        ; addrof t.6{r9}, [chars]
        lea r12, [var_0]
        ; add t.6{r9}, t.6{r9}, t.7{r8}
        add r12, rbx
        ; load t.5{r8}, [t.6{r9}]
        mov bl, [r12]
        ; add t.4{r8}, t.4{r8}, 1
        add bl, 1
        ; const t.9{r9}, 1
        mov r12, 1
        ; addrof t.8{r0}, [chars]
        lea rax, [var_0]
        ; add t.8{r0}, t.8{r0}, t.9{r9}
        add rax, r12
        ; store [t.8{r0}], t.4{r8}
        mov [rax], bl
        ; const t.13{r8}, 1
        mov rbx, 1
        ; addrof t.12{r9}, [chars]
        lea r12, [var_0]
        ; add t.12{r9}, t.12{r9}, t.13{r8}
        add r12, rbx
        ; load t.11{r8}, [t.12{r9}]
        mov bl, [r12]
        ; add t.10{r8}, t.10{r8}, 2
        add bl, 2
        ; const t.15{r9}, 2
        mov r12, 2
        ; addrof t.14{r0}, [chars]
        lea rax, [var_0]
        ; add t.14{r0}, t.14{r0}, t.15{r9}
        add rax, r12
        ; store [t.14{r0}], t.10{r8}
        mov [rax], bl
        ; const t.17{r8}, 2
        mov rbx, 2
        ; addrof t.16{r9}, [chars]
        lea r12, [var_0]
        ; add t.16{r9}, t.16{r9}, t.17{r8}
        add r12, rbx
        ; load result{r1}, [t.16{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[result{r1}]
        call _printIntLf@u8
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

segment readable writable
        ; variable 0: chars[] (u8*/2048)
        var_0 rb 2048

