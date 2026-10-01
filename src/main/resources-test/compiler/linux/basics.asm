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

        ; void printUint@u8
        ;   rsp+0: arg number
_printUint@u8:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
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

        ; i64 unusedArgs@u8@bool@u8@u8
        ;   rsp+0: arg a
        ;   rsp+1: arg b
        ;   rsp+2: arg c
        ;   rsp+3: arg d
_unusedArgs@u8@bool@u8@u8:
        sub rsp, 8
        ; 9:10 return (i64)
        ; cast t.4.1{r0}(i64), c{r3}(u8)
        movzx rax, dl
        add rsp, 8
        ret

        ; void main
_main:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; begin initialize global variables
        ; const t.3.1{r8}, 48
        mov bl, 48
        ; addrof a.4.1{r0}, zero
        lea rax, [var_0]
        ; store [a.4.1{r0}], t.3.1{r8}
        mov [rax], bl
        ; const t.5.1{r8}, 49
        mov bl, 49
        ; addrof a.6.1{r0}, one
        lea rax, [var_1]
        ; store [a.6.1{r0}], t.5.1{r8}
        mov [rax], bl
        ; const t.7.1{r8}, 50
        mov bl, 50
        ; addrof a.8.1{r0}, two
        lea rax, [var_2]
        ; store [a.8.1{r0}], t.7.1{r8}
        mov [rax], bl
        ; const t.9.1{r8}, 34
        mov bl, 34
        ; addrof a.10.1{r0}, threeFour
        lea rax, [var_3]
        ; store [a.10.1{r0}], t.9.1{r8}
        mov [rax], bl
        ; end initialize global variables
        ; const t.11.1{r2}, 1
        mov sil, 1
        ; const arg.0.0{r1}, 1
        mov dil, 1
        ; const arg.0.2{r3}, 2
        mov dl, 2
        ; const arg.0.3{r4}, 3
        mov cl, 3
        ; call _ = unusedArgs@u8@bool@u8@u8[arg.0.0{r1}, t.11.1{r2}, arg.0.2{r3}, arg.0.3{r4}] -> i64
        call _unusedArgs@u8@bool@u8@u8
        ; addrof a.12.1{r8}, zero
        lea rbx, [var_0]
        ; load t.13.1{r1}, [a.12.1{r8}]
        mov dil, [rbx]
        ; call printChar@u8[t.13.1{r1}]
        call _printChar@u8
        ; addrof onePtr.1{r8}, one
        lea rbx, [var_1]
        ; load t.14.1{r1}, [onePtr.1{r8}]
        mov dil, [rbx]
        ; call printChar@u8[t.14.1{r1}]
        call _printChar@u8
        ; addrof twoPtr.1{r8}, two
        lea rbx, [var_2]
        ; const t.17.1{r0}, 0
        mov rax, 0
        ; add t.16.2{r8}, t.17.1{r0}
        add rbx, rax
        ; load t.15.1{r1}, [t.16.2{r8}]
        mov dil, [rbx]
        ; call printChar@u8[t.15.1{r1}]
        call _printChar@u8
        ; addrof a.18.1{r8}, threeFour
        lea rbx, [var_3]
        ; load t.19.1{r1}, [a.18.1{r8}]
        mov dil, [rbx]
        ; call printUint@u8[t.19.1{r1}]
        call _printUint@u8
        ; const arg.5.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.5.0{r1}]
        call _printChar@u8
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

segment readable writable
        ; variable 0: zero (u8/1)
        var_0 rb 1
        ; variable 1: one (u8/1)
        var_1 rb 1
        ; variable 2: two (u8/1)
        var_2 rb 1
        ; variable 3: threeFour (u8/1)
        var_3 rb 1

