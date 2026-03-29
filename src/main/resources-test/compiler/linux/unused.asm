format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void unusedArg@u8
        ;   rsp+0: arg a
@unusedArg@u8:
        sub rsp, 8
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; const t.0{r1}, 0
        mov dil, 0
        ; call unusedArg@u8[t.0{r1}]
        call @unusedArg@u8
        add rsp, 8
        ret

