format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; u8 _simple
_simple:
        sub rsp, 8
        ; const four.1{r0}, 4
        mov al, 4
        ; const three.1{r1}, 3
        mov dil, 3
        ; sub one.1{r0}, three.1{r1}
        sub al, dil
        ; 5:9 return one
        add rsp, 8
        ret

        ; u8 _registerHint@u8@u8
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

        ; u8 _max@u8@u8
        ;   rsp+0: arg a
        ;   rsp+1: arg b
_max@u8@u8:
        sub rsp, 8
        ; branch a{r1} lt b{r2}: if_1_then
        cmp dil, sil
        jb if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        mov al, dil
        jmp _max@u8@u8_ret
if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        mov al, sil
_max@u8@u8_ret:
        add rsp, 8
        ret

        ; i16 _fibonacci@u8
        ;   rsp+0: arg i
_fibonacci@u8:
        sub rsp, 8
        ; const a.1{r0}, 0
        mov ax, 0
        ; const b.1{r2}, 1
        mov si, 1
        ; 22:2 while i > 0
        jmp while_2
while_2_body:
        ; sub i.2{r1}, 1
        sub dil, 1
        ; add c.1{r0}, b.2{r2}
        add ax, si
        ; move b.3{r3}, c.1{r0}
        mov dx, ax
        ; move a.2{r0}, a.3{r2}
        mov ax, si
        ; move b.2{r2}, b.3{r3}
        mov si, dx
while_2:
        ; branch i.1{r1} gt 0: while_2_body
        cmp dil, 0
        ja while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void _main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; call one.1{r0} = _simple[] -> u8
        call _simple
        ; move one.1{r8}, one.1{r0}
        mov bl, al
        ; const two.1{r9}, 2
        mov r12b, 2
        ; move one.1{r1}, one.1{r8}
        mov dil, bl
        ; move two.1{r2}, two.1{r9}
        mov sil, r12b
        ; call _ = _registerHint@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _registerHint@u8@u8
        ; move one.1{r1}, one.1{r8}
        mov dil, bl
        ; move two.1{r2}, two.1{r9}
        mov sil, r12b
        ; call _ = _max@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _max@u8@u8
        ; const arg.3.0{r1}, 5
        mov dil, 5
        ; call _ = _fibonacci@u8[arg.3.0{r1}] -> i16
        call _fibonacci@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

