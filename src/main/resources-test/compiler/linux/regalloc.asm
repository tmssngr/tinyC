format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; u8 simple
_simple:
        sub rsp, 8
        ; const four.1{r1}, 4
        mov dil, 4
        ; const three.1{r2}, 3
        mov sil, 3
        ; move one.1{r0}, four.1{r1}
        mov al, dil
        ; sub one.1{r0}, three.1{r2}
        sub al, sil
        ; 5:9 return one
        add rsp, 8
        ret

        ; u8 registerHint@u8@u8
        ;   rsp+0: arg a
        ;   rsp+1: arg b
_registerHint@u8@u8:
        sub rsp, 8
        ; 9:11 return a + b
        ; move t.2.1{r0}, a{r1}
        mov al, dil
        ; add t.2.1{r0}, b{r2}
        add al, sil
        add rsp, 8
        ret

        ; u8 max@u8@u8
        ;   rsp+0: arg a
        ;   rsp+1: arg b
_max@u8@u8:
        sub rsp, 8
        ; branch a{r1} lt b{r2}: if_1_then
        cmp dil, sil
        jb _if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        mov al, dil
        jmp _max@u8@u8_ret
_if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        mov al, sil
_max@u8@u8_ret:
        add rsp, 8
        ret

        ; i16 fibonacci@u8
        ;   rsp+0: arg i
_fibonacci@u8:
        sub rsp, 8
        ; const a.1{r2}, 0
        mov si, 0
        ; const b.1{r3}, 1
        mov dx, 1
        ; 22:2 while i > 0
        ; move a.2{r0}, a.1{r2}
        mov ax, si
        ; move b.2{r2}, b.1{r3}
        mov si, dx
        jmp _while_2
_while_2_body:
        ; sub i.2{r1}, 1
        sub dil, 1
        ; move c.1{r3}, a.2{r0}
        mov dx, ax
        ; add c.1{r3}, b.2{r2}
        add dx, si
        ; move a.2{r0}, a.3{r2}
        mov ax, si
        ; move b.2{r2}, b.3{r3}
        mov si, dx
_while_2:
        ; branch i.1{r1} gt 0: while_2_body
        cmp dil, 0
        ja _while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call one.1{r0} = simple[] -> u8
        call _simple
        ; move one.1{r8}, one.1{r0}
        mov bl, al
        ; const two.1{r9}, 2
        mov r12b, 2
        ; move one.1{r1}, one.1{r8}
        mov dil, bl
        ; move two.1{r2}, two.1{r9}
        mov sil, r12b
        ; call _ = registerHint@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _registerHint@u8@u8
        ; move one.1{r1}, one.1{r8}
        mov dil, bl
        ; move two.1{r2}, two.1{r9}
        mov sil, r12b
        ; call _ = max@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _max@u8@u8
        ; const arg.3.0{r1}, 5
        mov dil, 5
        ; call _ = fibonacci@u8[arg.3.0{r1}] -> i16
        call _fibonacci@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

