format ELF64 executable 3
segment executable
entry _start

_start:
        call _main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void _printChar@u8
        ;   rsp+32: arg chr
_printChar@u8:
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
        ; move t.1.1{r1}, t.1.1{r9}
        mov rdi, r12
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call _printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void _printUint@i64
        ;   rsp+0: arg number
        ;   rsp+20: var buffer
_printUint@i64:
        sub rsp, 40
        ; const pos.1{r0}, 20
        mov al, 20
        ; 33:2 while true
        jmp while_1
_printUint@i64.no_critical_edge_4:
        ; move pos.2{r0}, pos.3{r2}
        mov al, sil
while_1:
        ; move pos.3{r2}, pos.2{r0}
        mov sil, al
        ; sub pos.3{r2}, 1
        sub sil, 1
        ; move remainder.1{r5}, number.1{r1}
        mov r8, rdi
        ; move remainder.1{r0}, remainder.1{r5}
        mov rax, r8
        ; mod remainder.1{r3}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r5}, remainder.1{r3}
        mov r8, rdx
        ; move number.2{r0}, number.2{r1}
        mov rax, rdi
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r1}, number.2{r0}
        mov rdi, rax
        ; cast t.5.1{r0}(u8), remainder.1{r5}(i64)
        mov al, r8b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r2}(u8)
        movzx rdx, sil
        ; addrof t.6.1{r4}, buffer
        lea rcx, [rsp+20]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; store [t.6.2{r4}], digit.1{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number.2{r1} notequals 0: _printUint@i64.no_critical_edge_4
        cmp rdi, 0
        jne _printUint@i64.no_critical_edge_4
        ; move t.8.2{r1}, t.8.2{r4}
        mov rdi, rcx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; sub t.10.1{r0}, pos.3{r2}
        sub al, sil
        ; move t.10.1{r2}, t.10.1{r0}
        mov sil, al
        ; call _printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 40
        ret

        ; void _printIntLf@u8
        ;   rsp+0: arg number
_printIntLf@u8:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call _printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void _printIntLf@i64
        ;   rsp+24: arg number
_printIntLf@i64:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; branch number{r8} gteq 0: if_3_end
        cmp rbx, 0
        jge if_3_end
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call _printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r0}, number{r8}
        mov rax, rbx
        neg rax
        ; move number.1{r8}, number.2{r0}
        mov rbx, rax
if_3_end:
        ; move number.1{r1}, number.1{r8}
        mov rdi, rbx
        ; call _printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void _printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call _printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void _main
_main:
        sub rsp, 8
        ; const chr.1{r0}, 32
        mov al, 32
        ; const t.3.1{r1}, 0
        mov rdi, 0
        ; addrof t.2.1{r2}, chars
        lea rsi, [var_0]
        ; add t.2.2{r2}, t.3.1{r1}
        add rsi, rdi
        ; store [t.2.2{r2}], chr.1{r0}
        mov [rsi], al
        ; move t.6.2{r1}, t.6.2{r2}
        mov rdi, rsi
        ; load t.5.1{r0}, [t.6.2{r1}]
        mov al, [rdi]
        ; add t.4.1{r0}, 1
        add al, 1
        ; const t.9.1{r1}, 1
        mov rdi, 1
        ; addrof t.8.1{r2}, chars
        lea rsi, [var_0]
        ; add t.8.2{r2}, t.9.1{r1}
        add rsi, rdi
        ; store [t.8.2{r2}], t.4.1{r0}
        mov [rsi], al
        ; move t.12.2{r1}, t.12.2{r2}
        mov rdi, rsi
        ; load t.11.1{r0}, [t.12.2{r1}]
        mov al, [rdi]
        ; add t.10.1{r0}, 2
        add al, 2
        ; const t.15.1{r1}, 2
        mov rdi, 2
        ; addrof t.14.1{r2}, chars
        lea rsi, [var_0]
        ; add t.14.2{r2}, t.15.1{r1}
        add rsi, rdi
        ; store [t.14.2{r2}], t.10.1{r0}
        mov [rsi], al
        ; const t.17.1{r0}, 2
        mov rax, 2
        ; move t.16.2{r1}, t.16.2{r2}
        mov rdi, rsi
        ; load result.1{r1}, [t.16.2{r1}]
        mov dil, [rdi]
        ; call _printIntLf@u8[result.1{r1}]
        call _printIntLf@u8
        add rsp, 8
        ret

        ; void _printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

segment readable writable
        ; variable 0: chars[] (u8*/256)
        var_0 rb 256

