format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; i64 fn
        ;   rsp+0: arg a
        ;   rsp+4: arg b
        ;   rsp+8: arg c
        ;   rsp+16: arg d
        ;   rsp+24: arg e
        ;   rsp+32: arg f
        ;   rsp+48: arg g
        ;   rsp+56: arg temp
@fn:
        sub rsp, 40
        ; const a{r0}, 10
        mov ax, 10
        ; const b{r1}, 20
        mov edi, 20
        ; addrof c{r2}, c
        lea rsi, [rsp+8]
        ; load d{r3}, [c{r2}]
        mov rdx, [rsi]
        add rsp, 40
        ret

