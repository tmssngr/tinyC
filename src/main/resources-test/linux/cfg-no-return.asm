format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void main
@main:
        sub rsp, 8
        ; const i{r0}, 0
        mov al, 0
        ; 3:2 while true
@while_1:
        ; inc i{r0}
        inc al
        jmp @while_1
        add rsp, 8
        ret

