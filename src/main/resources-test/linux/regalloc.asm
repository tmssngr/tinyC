format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; u8 simple
@simple:
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

        ; u8 registerHint
        ;   rsp+16: arg a
        ;   rsp+24: arg b
@registerHint:
        sub rsp, 8
        ; 9:11 return a + b
        ; move t.2{r0}, a{r1}
        mov al, dil
        ; add t.2{r0}, t.2{r0}, b{r2}
        add al, sil
        add rsp, 8
        ret

        ; u8 max
        ;   rsp+16: arg a
        ;   rsp+24: arg b
@max:
        sub rsp, 8
        ; 13:2 if a < b
        ; lt t.2{r3}, a{r1}, b{r2}
        cmp dil, sil
        setb dl
        ; branch t.2{r3}, true, @if_1_then
        or dl, dl
        jnz @if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        mov al, dil
        jmp @max_ret
@if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        mov al, sil
@max_ret:
        add rsp, 8
        ret

        ; i16 fibonacci
        ;   rsp+16: arg i
@fibonacci:
        sub rsp, 8
        ; const a{r0}, 0
        mov ax, 0
        ; const b{r2}, 1
        mov si, 1
        ; 22:2 while i > 0
        jmp @while_2
@while_2_body:
        ; dec i{r1}
        dec dil
        ; move c{r3}, a{r0}
        mov dx, ax
        ; add c{r3}, c{r3}, b{r2}
        add dx, si
        ; move a{r0}, b{r2}
        mov ax, si
        ; move b{r2}, c{r3}
        mov si, dx
@while_2:
        ; gt t.4{r3}, i{r1}, 0
        cmp dil, 0
        seta dl
        ; branch t.4{r3}, true, @while_2_body
        or dl, dl
        jnz @while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; call one{r0} = simple[] -> u8
        call @simple
        ; move one{r8}, one{r0}
        mov bl, al
        ; const two{r9}, 2
        mov r12b, 2
        ; move one{r1}, one{r8}
        mov dil, bl
        ; move two{r2}, two{r9}
        mov sil, r12b
        ; call _ = registerHint[one{r1}, two{r2}] -> u8
        call @registerHint
        ; move one{r1}, one{r8}
        mov dil, bl
        ; move two{r2}, two{r9}
        mov sil, r12b
        ; call _ = max[one{r1}, two{r2}] -> u8
        call @max
        ; const t.4{r1}, 5
        mov dil, 5
        ; call _ = fibonacci[t.4{r1}] -> i16
        call @fibonacci
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

