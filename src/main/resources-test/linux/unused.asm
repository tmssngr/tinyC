format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void unusedArg
        ;   rsp+16: arg a
@unusedArg:
        sub rsp, 8
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        sub rsp, 32
        ; const t.0{r1}, 0
        mov rdi, 0
        ; call unusedArg[t.0{r1}]
        call @unusedArg
        add rsp, 32
        add rsp, 8
        ret

