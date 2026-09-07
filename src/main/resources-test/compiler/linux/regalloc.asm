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
        ; const four{r1}, 4
        mov dil, 4
        ; const three{r2}, 3
        mov sil, 3
        ; move one{r0}, four{r1}
        mov al, dil
        ; sub one{r0}, one{r0}, three{r2}
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
        ; move t.2{r0}, a{r1}
        mov al, dil
        ; add t.2{r0}, t.2{r0}, b{r2}
        add al, sil
        add rsp, 8
        ret

        ; u8 max@u8@u8
        ;   rsp+0: arg a
        ;   rsp+1: arg b
_max@u8@u8:
        sub rsp, 8
        ; 13:2 if a < b
        ; branch a{r1} lt b{r2}: if_1_then, if_1_end
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
        ; const a{r0}, 0
        mov ax, 0
        ; const b{r2}, 1
        mov si, 1
        ; 22:2 while i > 0
        jmp _while_2
_while_2_body:
        ; sub i{r1}, i{r1}, 1
        sub dil, 1
        ; move c{r3}, a{r0}
        mov dx, ax
        ; add c{r3}, c{r3}, b{r2}
        add dx, si
        ; move a{r0}, b{r2}
        mov ax, si
        ; move b{r2}, c{r3}
        mov si, dx
_while_2:
        ; branch i{r1} gt 0: while_2_body, while_2_break
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
        ; call one{r0} = simple[] -> u8
        call _simple
        ; move one{r8}, one{r0}
        mov bl, al
        ; const two{r9}, 2
        mov r12b, 2
        ; move one{r1}, one{r8}
        mov dil, bl
        ; move two{r2}, two{r9}
        mov sil, r12b
        ; call _ = registerHint@u8@u8[one{r1}, two{r2}] -> u8
        call _registerHint@u8@u8
        ; move one{r1}, one{r8}
        mov dil, bl
        ; move two{r2}, two{r9}
        mov sil, r12b
        ; call _ = max@u8@u8[one{r1}, two{r2}] -> u8
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

