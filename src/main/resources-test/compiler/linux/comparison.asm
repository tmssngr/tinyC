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
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length.1{r2}, length.1{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
        call _printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printChar@u8
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
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
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
_printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos.1{r8}, 20
        mov bl, 20
        ; 33:2 while true
        ; move number.1{r5}, number{r1}
        mov r8, rdi
_while_1:
        ; sub pos.3{r8}, 1
        sub bl, 1
        ; move remainder.1{r6}, number.1{r5}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r6}
        mov rax, r9
        ; mod remainder.1{r3}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r6}, remainder.1{r3}
        mov r9, rdx
        ; move number.2{r0}, number.2{r5}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r5}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r6}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r8}(u8)
        movzx rdx, bl
        ; addrof t.6.1{r4}, buffer
        lea rcx, [rsp+40]
        ; add t.6.2{r4}, t.7.1{r3}
        add rcx, rdx
        ; store [t.6.2{r4}], digit.1{r0}
        mov [rcx], al
        ; 39:3 if number == 0
        ; branch number.2{r5} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; move t.9.1{r0}, t.9.1{r3}
        mov rax, rdx
        ; addrof t.8.1{r3}, buffer
        lea rdx, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rdi, rdx
        ; move t.8.2{r1}, t.8.2{r4}
        mov rdi, rcx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov sil, al
        ; sub t.10.1{r2}, pos.3{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; void printIntLf@bool
        ;   rsp+0: arg number
_printIntLf@bool:
        sub rsp, 8
        ; cast t.1.1{r1}(i64), number{r1}(bool)
        movsx rdi, dil
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
_printIntLf@i64:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; branch number{r8} gteq 0: printIntLf@i64.no_critical_edge_4
        cmp rbx, 0
        jge _printIntLf@i64.no_critical_edge_4
        ; const arg.0.0{r1}, 45
        mov dil, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r8}, number{r8}
        neg rbx
        ; move number.1{r1}, number.2{r8}
        mov rdi, rbx
        jmp _if_3_end
_printIntLf@i64.no_critical_edge_4:
        ; move number.1{r1}, number{r8}
        mov rdi, rbx
_if_3_end:
        ; call printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
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
        ; const length.1{r2}, 0
        mov rsi, 0
        ; 69:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rsi
        jmp _for_4
_for_4_body:
        ; move length.3{r2}, length.2{r0}
        mov rsi, rax
        ; add length.3{r2}, 1
        add rsi, 1
        ; add str.2{r1}, 1
        add rdi, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rsi
_for_4:
        ; load t.2.1{r2}, [str.1{r1}]
        mov sil, [rdi]
        ; branch t.2.1{r2} notequals 0: for_4_body
        cmp sil, 0
        jne _for_4_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var b.1
        ;   rsp+34: var c.1
        ;   rsp+35: var d.1
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.4.1{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.4.1{r1}]
        call _printString@@u8
        ; const a.1{r8}, 1
        mov bx, 1
        ; const b.1{r0}, 2
        mov ax, 2
        ; lt t.5.1{r1}, a.1{r8}, b.1{r0}
        cmp bx, ax
        setl dil
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b.1{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.5.1{r1}]
        call _printIntLf@bool
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; lt t.6.1{r1}, b.1{r0}, a.1{r8}
        cmp ax, bx
        setl dil
        ; call printIntLf@bool[t.6.1{r1}]
        call _printIntLf@bool
        ; const t.7.1{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; const c.1{r0}, 0
        mov al, 0
        ; const d.1{r2}, 128
        mov sil, 128
        ; lt t.8.1{r1}, c.1{r0}, d.1{r2}
        cmp al, sil
        setb dil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c.1{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d.1{r2}
        mov [r12], sil
        ; call printIntLf@bool[t.8.1{r1}]
        call _printIntLf@bool
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; load d.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; lt t.9.1{r1}, d.1{r0}, c.1{r2}
        cmp al, sil
        setb dil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; call printIntLf@bool[t.9.1{r1}]
        call _printIntLf@bool
        ; const t.10.1{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.10.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; lteq t.11.1{r1}, a.1{r8}, b.1{r0}
        cmp bx, ax
        setle dil
        ; call printIntLf@bool[t.11.1{r1}]
        call _printIntLf@bool
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; lteq t.12.1{r1}, b.1{r0}, a.1{r8}
        cmp ax, bx
        setle dil
        ; call printIntLf@bool[t.12.1{r1}]
        call _printIntLf@bool
        ; const t.13.1{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.13.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; load d.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; lteq t.14.1{r1}, c.1{r0}, d.1{r2}
        cmp al, sil
        setbe dil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; call printIntLf@bool[t.14.1{r1}]
        call _printIntLf@bool
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; load d.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; lteq t.15.1{r1}, d.1{r0}, c.1{r2}
        cmp al, sil
        setbe dil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; call printIntLf@bool[t.15.1{r1}]
        call _printIntLf@bool
        ; const t.16.1{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString@@u8[t.16.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.17.1{r1}, a.1{r8}, b.1{r0}
        cmp bx, ax
        sete dil
        ; call printIntLf@bool[t.17.1{r1}]
        call _printIntLf@bool
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.18.1{r1}, b.1{r0}, a.1{r8}
        cmp ax, bx
        sete dil
        ; call printIntLf@bool[t.18.1{r1}]
        call _printIntLf@bool
        ; const t.19.1{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString@@u8[t.19.1{r1}]
        call _printString@@u8
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; notequals t.20.1{r1}, a.1{r8}, b.1{r0}
        cmp bx, ax
        setne dil
        ; call printIntLf@bool[t.20.1{r1}]
        call _printIntLf@bool
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; notequals t.21.1{r1}, b.1{r0}, a.1{r8}
        cmp ax, bx
        setne dil
        ; call printIntLf@bool[t.21.1{r1}]
        call _printIntLf@bool
        ; const t.22.1{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString@@u8[t.22.1{r1}]
        call _printString@@u8
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gteq t.23.1{r1}, a.1{r8}, b.1{r0}
        cmp bx, ax
        setge dil
        ; call printIntLf@bool[t.23.1{r1}]
        call _printIntLf@bool
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gteq t.24.1{r1}, b.1{r0}, a.1{r8}
        cmp ax, bx
        setge dil
        ; call printIntLf@bool[t.24.1{r1}]
        call _printIntLf@bool
        ; const t.25.1{r1}, [string-7]
        lea rdi, [string_7]
        ; call printString@@u8[t.25.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; load d.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; gteq t.26.1{r1}, c.1{r0}, d.1{r2}
        cmp al, sil
        setae dil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; call printIntLf@bool[t.26.1{r1}]
        call _printIntLf@bool
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; load d.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; gteq t.27.1{r1}, d.1{r0}, c.1{r2}
        cmp al, sil
        setae dil
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; call printIntLf@bool[t.27.1{r1}]
        call _printIntLf@bool
        ; const t.28.1{r1}, [string-8]
        lea rdi, [string_8]
        ; call printString@@u8[t.28.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, b.1
        lea r12, [rsp+32]
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gt t.29.1{r1}, a.1{r8}, b.1{r0}
        cmp bx, ax
        setg dil
        ; call printIntLf@bool[t.29.1{r1}]
        call _printIntLf@bool
        ; load b.1{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gt t.30.1{r1}, b.1{r0}, a.1{r8}
        cmp ax, bx
        setg dil
        ; call printIntLf@bool[t.30.1{r1}]
        call _printIntLf@bool
        ; const t.31.1{r1}, [string-9]
        lea rdi, [string_9]
        ; call printString@@u8[t.31.1{r1}]
        call _printString@@u8
        ; addrof memVarAddr{r9}, c.1
        lea r12, [rsp+34]
        ; load c.1{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; addrof memVarAddr{r9}, d.1
        lea r12, [rsp+35]
        ; load d.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; gt t.32.1{r1}, c.1{r8}, d.1{r0}
        cmp bl, al
        seta dil
        ; call printIntLf@bool[t.32.1{r1}]
        call _printIntLf@bool
        ; load d.1{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; gt t.33.1{r1}, d.1{r0}, c.1{r8}
        cmp al, bl
        seta dil
        ; call printIntLf@bool[t.33.1{r1}]
        call _printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

segment readable
        string_0 db '< (signed)', 0x0a, 0x00
        string_1 db '< (unsigned)', 0x0a, 0x00
        string_2 db '<= (signed)', 0x0a, 0x00
        string_3 db '<= (unsigned)', 0x0a, 0x00
        string_4 db '==', 0x0a, 0x00
        string_5 db '!=', 0x0a, 0x00
        string_6 db '>= (signed)', 0x0a, 0x00
        string_7 db '>= (unsigned)', 0x0a, 0x00
        string_8 db '> (signed)', 0x0a, 0x00
        string_9 db '> (unsigned)', 0x0a, 0x00

