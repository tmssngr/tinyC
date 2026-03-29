format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printString@@u8
        ;   rsp+24: arg str
@printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call @strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call @printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

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

        ; void printIntLf@i16
        ;   rsp+0: arg number
@printIntLf@i16:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(i16)
        movzx rdi, di
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
        ; 47:2 if number < 0
        ; const t.2{r9}, 0
        mov r12, 0
        ; lt t.1{r9}, number{r8}, t.2{r9}
        cmp rbx, r12
        setl r12b
        ; branch t.1{r9}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const t.3{r1}, 45
        mov dil, 45
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        ; neg number{r8}, number{r8}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const t.4{r1}, 10
        mov dil, 10
        ; call printChar@u8[t.4{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 57:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; const t.5{r2}, 1
        mov rsi, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rsi
        ; const t.6{r2}, 1
        mov rsi, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rdi, rsi
@for_4:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; const t.4{r3}, 0
        mov dl, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp sil, dl
        setne sil
        ; branch t.2{r2}, true, @for_4_body, @for_4_break
        or sil, sil
        jnz @for_4_body
        ; 60:9 return length
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
        ; begin initialize global variables
        ; const tmp.text{r8}, [string-0]
        lea rbx, [string_0]
        ; end initialize global variables
        ; addrof memVarAddr{r9}, text
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.text{r8}
        mov [r12], rbx
        ; move tmp.text{r1}, tmp.text{r8}
        mov rdi, rbx
        ; call printString@@u8[tmp.text{r1}]
        call @printString@@u8
        ; call printLength[]
        call @printLength
        ; const t.2{r0}, 1
        mov rax, 1
        ; addrof memVarAddr{r9}, text
        lea r12, [var_0]
        ; load tmp.text{r8}, [memVarAddr{r9}]
        mov rbx, [r12]
        ; move second{r1}, tmp.text{r8}
        mov rdi, rbx
        ; add second{r1}, second{r1}, t.2{r0}
        add rdi, rax
        ; call printString@@u8[second{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, text
        lea r12, [var_0]
        ; load tmp.text{r8}, [memVarAddr{r9}]
        mov rbx, [r12]
        ; load chr{r1}, [tmp.text{r8}]
        mov dil, [rbx]
        ; call printIntLf@u8[chr{r1}]
        call @printIntLf@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printLength
@printLength:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const length{r1}, 0
        mov di, 0
        ; addrof memVarAddr{r9}, text
        lea r12, [var_0]
        ; load tmp.text{r8}, [memVarAddr{r9}]
        mov rbx, [r12]
        ; 16:2 for *ptr != 0
        jmp @for_5
@for_5_body:
        ; const t.5{r0}, 1
        mov ax, 1
        ; add length{r1}, length{r1}, t.5{r0}
        add di, ax
        ; const t.6{r0}, 1
        mov rax, 1
        ; add ptr{r8}, ptr{r8}, t.6{r0}
        add rbx, rax
@for_5:
        ; load t.3{r0}, [ptr{r8}]
        mov al, [rbx]
        ; const t.4{r2}, 0
        mov sil, 0
        ; notequals t.2{r0}, t.3{r0}, t.4{r2}
        cmp al, sil
        setne al
        ; branch t.2{r0}, true, @for_5_body, @for_5_break
        or al, al
        jnz @for_5_body
        ; call printIntLf@i16[length{r1}]
        call @printIntLf@i16
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
        ; variable 0: text (u8*/8)
        var_0 rb 8

segment readable
        string_0 db 'hello world', 0x0a, 0x00

