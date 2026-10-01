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
        ; move t.9.1{r0}, t.9.1{r3}
        mov rax, rdx
        ; addrof t.8.1{r3}, buffer
        lea rdx, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rdi, rdx
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

        ; void printIntLf@u8
        ;   rsp+0: arg number
_printIntLf@u8:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call printIntLf@i64[t.1.1{r1}]
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
        ; branch number{r8} gteq 0: if_3_end
        cmp rbx, 0
        jge _if_3_end
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r8}, number{r8}
        neg rbx
_if_3_end:
        ; move number.1{r1}, number.1{r8}
        mov rdi, rbx
        ; call printUint@i64[number.1{r1}]
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
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var t.3.1
        ;   rsp+33: var t.4.1
        ;   rsp+34: var t.5.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const t.0.1{r8}, 0
        mov bl, 0
        ; addrof a.1.1{r0}, i
        lea rax, [var_0]
        ; store [a.1.1{r0}], t.0.1{r8}
        mov [rax], bl
        ; end initialize global variables
        ; call t.2.1{r0} = next[] -> u8
        call _next
        ; move t.2.1{r8}, t.2.1{r0}
        mov bl, al
        ; call t.3.1{r0} = next[] -> u8
        call _next
        ; addrof memVarAddr{r9}, t.3.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], t.3.1{r0}
        mov [r12], al
        ; call t.4.1{r0} = next[] -> u8
        call _next
        ; addrof memVarAddr{r9}, t.4.1
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], t.4.1{r0}
        mov [r12], al
        ; call t.5.1{r0} = next[] -> u8
        call _next
        ; addrof memVarAddr{r9}, t.5.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], t.5.1{r0}
        mov [r12], al
        ; call t.6.1{r0} = next[] -> u8
        call _next
        ; move t.2.1{r1}, t.2.1{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, t.3.1
        lea r12, [rsp+32]
        ; load t.3.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, t.4.1
        lea r12, [rsp+33]
        ; load t.4.1{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, t.5.1
        lea r12, [rsp+34]
        ; load t.5.1{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move t.6.1{r5}, t.6.1{r0}
        mov r8b, al
        ; call doPrint@u8@u8@u8@u8@u8[t.2.1{r1}, t.3.1{r2}, t.4.1{r3}, t.5.1{r4}, t.6.1{r5}]
        call _doPrint@u8@u8@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; u8 next
_next:
        sub rsp, 8
        ; addrof a.1.1{r1}, i
        lea rdi, [var_0]
        ; load t.2.1{r1}, [a.1.1{r1}]
        mov dil, [rdi]
        ; add t.0.1{r1}, 1
        add dil, 1
        ; addrof a.3.1{r2}, i
        lea rsi, [var_0]
        ; store [a.3.1{r2}], t.0.1{r1}
        mov [rsi], dil
        ; 11:9 return i
        ; move a.4.1{r1}, a.4.1{r2}
        mov rdi, rsi
        ; load t.5.1{r0}, [a.4.1{r1}]
        mov al, [rdi]
        add rsp, 8
        ret

        ; void doPrint@u8@u8@u8@u8@u8
        ;   rsp+32: arg a
        ;   rsp+33: arg b
        ;   rsp+34: arg c
        ;   rsp+35: arg d
        ;   rsp+36: arg e
_doPrint@u8@u8@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move b{r8}, b{r2}
        mov bl, sil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], e{r5}
        mov [r12], r8b
        ; call printIntLf@u8[a{r1}]
        call _printIntLf@u8
        ; move b{r1}, b{r8}
        mov dil, bl
        ; call printIntLf@u8[b{r1}]
        call _printIntLf@u8
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[c{r1}]
        call _printIntLf@u8
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[d{r1}]
        call _printIntLf@u8
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+36]
        ; load e{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[e{r1}]
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
        ; variable 0: i (u8/1)
        var_0 rb 1

