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
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
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
        ; 33:2 while true
@while_1:
        ; sub pos{r8}, pos{r8}, 1
        sub bl, 1
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.5{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.6{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.6{r4}, t.6{r4}, t.7{r3}
        add rcx, rdx
        ; store [t.6{r4}], digit{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; equals t.8{r0}, number{r1}, 0
        cmp rdi, 0
        sete al
        ; branch t.8{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.10{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.9{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.9{r1}, t.9{r1}, t.10{r0}
        add rdi, rax
        ; const t.12{r0}, 20
        mov al, 20
        ; move t.11{r2}, t.12{r0}
        mov sil, al
        ; sub t.11{r2}, t.11{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.9{r1}, t.11{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; void printIntLf@u8
        ;   rsp+0: arg number
@printIntLf@u8:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+32: arg number
@printIntLf@i64:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; 59:2 if number < 0
        ; lt t.1{r9}, number{r8}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r9}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call printChar@u8[arg.0.0{r1}]
        call @printChar@u8
        ; neg number{r8}, number{r8}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.2.0{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
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

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const i{r8}, 250
        mov bl, 250
        ; 4:3 for i != 2
        jmp @for_4
@for_4_body:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printIntLf@u8[i{r1}]
        call @printIntLf@u8
        ; add i{r8}, i{r8}, 1
        add bl, 1
@for_4:
        ; notequals t.2{r9}, i{r8}, 2
        cmp bl, 2
        setne r12b
        ; branch t.2{r9}, true, @for_4_body, @for_4_break
        or r12b, r12b
        jnz @for_4_body
        ; const v{r8}, 260
        mov bx, 260
        ; cast t.3{r1}(u8), v{r8}(i16)
        mov dil, bl
        ; call printIntLf@u8[t.3{r1}]
        call @printIntLf@u8
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

