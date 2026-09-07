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
_printString@@u8:
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
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call _printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp _for_1
_for_1_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
_for_1:
        ; load t.2{r2}, [str{r1}]
        mov sil, [rdi]
        ; branch t.2{r2} notequals 0: for_1_body, for_1_break
        cmp sil, 0
        jne _for_1_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; u8 next
_next:
        sub rsp, 8
        ; addrof a.global{r1}, global
        lea rdi, [var_0]
        ; load t.global{r1}, [a.global{r1}]
        mov dil, [rdi]
        ; move copy{r0}, t.global{r1}
        mov al, dil
        ; addrof a.global1{r1}, global
        lea rdi, [var_0]
        ; load t.global1{r1}, [a.global1{r1}]
        mov dil, [rdi]
        ; add t.global2{r1}, t.global2{r1}, 1
        add dil, 1
        ; addrof a.global2{r2}, global
        lea rsi, [var_0]
        ; store [a.global2{r2}], t.global2{r1}
        mov [rsi], dil
        ; 8:9 return copy
        add rsp, 8
        ret

        ; void main
_main:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; begin initialize global variables
        ; const t.global{r8}, 0
        mov bl, 0
        ; addrof a.global{r0}, global
        lea rax, [var_0]
        ; store [a.global{r0}], t.global{r8}
        mov [rax], bl
        ; end initialize global variables
        ; 12:2 while true
        jmp _while_2
_if_3_end:
        ; branch n{r8} gteq 2: while_2, if_4_then
        cmp bl, 2
        jae _while_2
        ; const t.2{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.2{r1}]
        call _printString@@u8
_while_2:
        ; const t.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.1{r1}]
        call _printString@@u8
        ; call n{r0} = next[] -> u8
        call _next
        ; move n{r8}, n{r0}
        mov bl, al
        ; 15:3 if n == 3
        ; branch n{r8} notequals 3: if_3_end, main_ret
        cmp bl, 3
        jne _if_3_end
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
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

