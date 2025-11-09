format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printChar
        ;   rsp+64: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; addrof t.1{r8}, chr
        lea rbx, [rsp+64]
        ; const t.2{r2}, 1
        mov rsi, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+64]
        mov [r11], dil
        ; move t.1{r1}, t.1{r8}
        mov rdi, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printUint
        ;   rsp+112: arg number
        ;   rsp+80: var buffer
@printUint:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; const pos{r8}, 20
        mov bl, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r8}
        dec bl
        ; const t.5{r9}, 10
        mov r12, 10
        ; move remainder{r4}, number{r1}
        mov rcx, rdi
        ; move remainder{r0}, remainder{r4}
        mov rax, rcx
        ; mod remainder{r3}, remainder{r0}, t.5{r9}
        cqo
        idiv r12
        ; move remainder{r4}, remainder{r3}
        mov rcx, rdx
        ; const t.6{r9}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.6{r9}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.7{r9}(u8), remainder{r4}(i64)
        mov r12b, cl
        ; const t.8{r0}, 48
        mov al, 48
        ; add digit{r9}, digit{r9}, t.8{r0}
        add r12b, al
        ; cast t.10{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; cast t.11{r0}(u8*), t.10{r0}(i64)
        ; addrof t.9{r3}, [buffer]
        lea rdx, [rsp+80]
        ; add t.9{r3}, t.9{r3}, t.11{r0}
        add rdx, rax
        ; store [t.9{r3}], digit{r9}
        mov [rdx], r12b
        ; 19:3 if number == 0
        ; equals t.12{r9}, number{r1}, 0
        cmp rdi, 0
        sete r12b
        ; branch t.12{r9}, false, @while_1
        or r12b, r12b
        jz @while_1
        ; cast t.14{r9}(i64), pos{r8}(u8)
        movzx r12, bl
        ; cast t.15{r9}(u8*), t.14{r9}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rdi, [rsp+80]
        ; add t.13{r1}, t.13{r1}, t.15{r9}
        add rdi, r12
        ; const t.18{r9}, 20
        mov r12b, 20
        ; sub t.17{r9}, t.17{r9}, pos{r8}
        sub r12b, bl
        ; cast t.16{r2}(i64), t.17{r9}(u8)
        movzx rsi, r12b
        ; call printStringLength[t.13{r1}, t.16{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 40
        ret

        ; i64 unusedArgs
        ;   rsp+16: arg a
        ;   rsp+24: arg b
        ;   rsp+32: arg c
        ;   rsp+40: arg d
@unusedArgs:
        sub rsp, 8
        ; 9:9 return c
        ; move c{r0}, c{r3}
        mov rax, rdx
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
        ; begin initialize global variables
        ; const tmp.zero{r8}, 48
        mov bl, 48
        ; const tmp.one{r9}, 49
        mov r12b, 49
        ; const tmp.two{r0}, 50
        mov al, 50
        ; const tmp.threeFour{r5}, 34
        mov r8b, 34
        ; end initialize global variables
        ; const t.3{r1}, 1
        mov di, 1
        ; const t.4{r2}, 1
        mov sil, 1
        ; const t.5{r3}, 2
        mov rdx, 2
        ; const t.6{r4}, 3
        mov rcx, 3
        ; move zero, tmp.zero{r8}
        lea r11, [var_0]
        mov [r11], bl
        ; move one, tmp.one{r9}
        lea r11, [var_1]
        mov [r11], r12b
        ; move two, tmp.two{r0}
        lea r11, [var_2]
        mov [r11], al
        ; move threeFour, tmp.threeFour{r5}
        lea r11, [var_3]
        mov [r11], r8b
        ; call _ = unusedArgs[t.3{r1}, t.4{r2}, t.5{r3}, t.6{r4}] -> i64
        call @unusedArgs
        ; move tmp.zero{r8}, zero
        lea r11, [var_0]
        mov bl, [r11]
        ; move tmp.zero{r1}, tmp.zero{r8}
        mov dil, bl
        ; call printChar[tmp.zero{r1}]
        call @printChar
        ; addrof onePtr{r8}, one
        lea rbx, [var_1]
        ; load t.7{r1}, [onePtr{r8}]
        mov dil, [rbx]
        ; call printChar[t.7{r1}]
        call @printChar
        ; addrof twoPtr{r8}, two
        lea rbx, [var_2]
        ; const t.10{r9}, 0
        mov r12, 0
        ; cast t.11{r9}(u8*), t.10{r9}(i64)
        ; add t.9{r8}, t.9{r8}, t.11{r9}
        add rbx, r12
        ; load t.8{r1}, [t.9{r8}]
        mov dil, [rbx]
        ; call printChar[t.8{r1}]
        call @printChar
        ; move tmp.threeFour{r8}, threeFour
        lea r11, [var_3]
        mov bl, [r11]
        ; cast t.12{r1}(i64), tmp.threeFour{r8}(u8)
        movzx rdi, bl
        ; call printUint[t.12{r1}]
        call @printUint
        ; const t.13{r1}, 10
        mov dil, 10
        ; call printChar[t.13{r1}]
        call @printChar
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
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

