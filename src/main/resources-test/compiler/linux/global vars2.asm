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

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; const t.5{r2}, 1
        mov rsi, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rsi
        ; const t.6{r2}, 1
        mov rsi, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rdi, rsi
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; const t.4{r3}, 0
        mov dl, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp sil, dl
        setne sil
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or sil, sil
        jnz @for_1_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; u8 next
@next:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, global
        lea r12, [var_0]
        ; load tmp.global{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; move copy{r0}, tmp.global{r1}
        mov al, dil
        ; const t.1{r2}, 1
        mov sil, 1
        ; add tmp.global{r1}, tmp.global{r1}, t.1{r2}
        add dil, sil
        ; 8:9 return copy
        ; addrof memVarAddr{r9}, global
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.global{r1}
        mov [r12], dil
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
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
        ; const tmp.global{r8}, 0
        mov bl, 0
        ; end initialize global variables
        ; 12:2 while true
        ; addrof memVarAddr{r9}, global
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.global{r8}
        mov [r12], bl
        jmp @while_2
@if_3_end:
        ; 19:3 if n < 2
        ; const t.5{r0}, 2
        mov al, 2
        ; lt t.4{r8}, n{r8}, t.5{r0}
        cmp bl, al
        setb bl
        ; branch t.4{r8}, false, @while_2, @if_4_then
        or bl, bl
        jz @while_2
        ; const t.6{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.6{r1}]
        call @printString@@u8
@while_2:
        ; const t.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.1{r1}]
        call @printString@@u8
        ; call n{r0} = next[] -> u8
        call @next
        ; move n{r8}, n{r0}
        mov bl, al
        ; 15:3 if n == 3
        ; const t.3{r0}, 3
        mov al, 3
        ; equals t.2{r0}, n{r8}, t.3{r0}
        cmp bl, al
        sete al
        ; branch t.2{r0}, false, @if_3_end, @main_ret
        or al, al
        jz @if_3_end
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
        ; variable 0: global (u8/1)
        var_0 rb 1

segment readable
        string_0 db 'loop', 0x0a, 0x00
        string_1 db '<2', 0x0a, 0x00

