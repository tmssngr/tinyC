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

        ; void printIntLf@i16
        ;   rsp+0: arg number
@printIntLf@i16:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(i16)
        movsx rdi, di
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

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
@for_4:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp sil, 0
        setne sil
        ; branch t.2{r2}, true, @for_4_body, @for_4_break
        or sil, sil
        jnz @for_4_body
        ; 72:9 return length
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
        ; add length{r1}, length{r1}, 1
        add di, 1
        ; add ptr{r8}, ptr{r8}, 1
        add rbx, 1
@for_5:
        ; load t.3{r0}, [ptr{r8}]
        mov al, [rbx]
        ; notequals t.2{r0}, t.3{r0}, 0
        cmp al, 0
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

