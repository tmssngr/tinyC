format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printChar@u8
        ;   rsp+32: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const t.2{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printUint@u8
        ;   rsp+0: arg number
@printUint@u8:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call printUint@i64[t.1{r1}]
        call @printUint@i64
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+24: arg number
        ;   rsp+40: var buffer
@printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos{r8}, 20
        mov bl, 20
        ; 21:2 while true
@while_1:
        ; const t.5{r4}, 1
        mov cl, 1
        ; sub pos{r8}, pos{r8}, t.5{r4}
        sub bl, cl
        ; const t.6{r4}, 10
        mov rcx, 10
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, t.6{r4}
        cqo
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; const t.7{r4}, 10
        mov rcx, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.7{r4}
        cqo
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.8{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; const t.9{r3}, 48
        mov dl, 48
        ; add digit{r0}, digit{r0}, t.9{r3}
        add al, dl
        ; cast t.11{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.10{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.10{r4}, t.10{r4}, t.11{r3}
        add rcx, rdx
        ; store [t.10{r4}], digit{r0}
        mov [rcx], al
        ; 27:3 if number == 0
        ; const t.13{r0}, 0
        mov rax, 0
        ; equals t.12{r0}, number{r1}, t.13{r0}
        cmp rdi, rax
        sete al
        ; branch t.12{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.15{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.14{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rdi, rax
        ; const t.17{r0}, 20
        mov al, 20
        ; move t.16{r2}, t.17{r0}
        mov sil, al
        ; sub t.16{r2}, t.16{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.14{r1}, t.16{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
@printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 24
        ret

        ; i64 unusedArgs@u8@bool@u8@u8
        ;   rsp+0: arg a
        ;   rsp+1: arg b
        ;   rsp+2: arg c
        ;   rsp+3: arg d
@unusedArgs@u8@bool@u8@u8:
        sub rsp, 8
        ; 9:9 return (autocast)
        ; cast t.4{r0}(i64), c{r3}(u8)
        movzx rax, dl
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
        ; begin initialize global variables
        ; const tmp.zero{r8}, 48
        mov bl, 48
        ; const tmp.one{r0}, 49
        mov al, 49
        ; const tmp.two{r5}, 50
        mov r8b, 50
        ; const tmp.threeFour{r1}, 34
        mov dil, 34
        ; end initialize global variables
        ; const t.3{r6}, 1
        mov r9b, 1
        ; const t.4{r2}, 1
        mov sil, 1
        ; const t.5{r3}, 2
        mov dl, 2
        ; const t.6{r4}, 3
        mov cl, 3
        ; addrof memVarAddr{r9}, zero
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.zero{r8}
        mov [r12], bl
        ; addrof memVarAddr{r9}, one
        lea r12, [var_1]
        ; store [memVarAddr{r9}], tmp.one{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, two
        lea r12, [var_2]
        ; store [memVarAddr{r9}], tmp.two{r5}
        mov [r12], r8b
        ; addrof memVarAddr{r9}, threeFour
        lea r12, [var_3]
        ; store [memVarAddr{r9}], tmp.threeFour{r1}
        mov [r12], dil
        ; move t.3{r1}, t.3{r6}
        mov dil, r9b
        ; call _ = unusedArgs@u8@bool@u8@u8[t.3{r1}, t.4{r2}, t.5{r3}, t.6{r4}] -> i64
        call @unusedArgs@u8@bool@u8@u8
        ; addrof memVarAddr{r9}, zero
        lea r12, [var_0]
        ; load tmp.zero{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; move tmp.zero{r1}, tmp.zero{r8}
        mov dil, bl
        ; call printChar@u8[tmp.zero{r1}]
        call @printChar@u8
        ; addrof onePtr{r8}, one
        lea rbx, [var_1]
        ; load t.7{r1}, [onePtr{r8}]
        mov dil, [rbx]
        ; call printChar@u8[t.7{r1}]
        call @printChar@u8
        ; addrof twoPtr{r8}, two
        lea rbx, [var_2]
        ; const t.10{r0}, 0
        mov rax, 0
        ; add t.9{r8}, t.9{r8}, t.10{r0}
        add rbx, rax
        ; load t.8{r1}, [t.9{r8}]
        mov dil, [rbx]
        ; call printChar@u8[t.8{r1}]
        call @printChar@u8
        ; addrof memVarAddr{r9}, threeFour
        lea r12, [var_3]
        ; load tmp.threeFour{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printUint@u8[tmp.threeFour{r1}]
        call @printUint@u8
        ; const t.11{r1}, 10
        mov dil, 10
        ; call printChar@u8[t.11{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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

