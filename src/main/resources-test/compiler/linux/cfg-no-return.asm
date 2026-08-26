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
        ; const t.1{r1}, 1
        mov dil, 1
        ; add i{r0}, i{r0}, t.1{r1}
        add al, dil
        jmp @while_1
        add rsp, 8
        ret

