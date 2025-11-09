format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printString
        ;   rsp+64: arg str
@printString:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen[str{r1}] -> i64
        call @strlen
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength[str{r1}, length{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

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

        ; void printIntLf
        ;   rsp+80: arg number
@printIntLf:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; 27:2 if number < 0
        ; lt t.1{r9}, number{r8}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r9}, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov dil, 45
        ; call printChar[t.2{r1}]
        call @printChar
        ; neg number{r8}, number{r8}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint[number{r1}]
        call @printUint
        ; const t.3{r1}, 10
        mov dil, 10
        ; call printChar[t.3{r1}]
        call @printChar
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; inc length{r0}
        inc rax
        ; cast t.5{r2}(i64), str{r1}(u8*)
        mov rsi, rdi
        ; const t.6{r3}, 1
        mov rdx, 1
        ; move t.4{r1}, t.5{r2}
        mov rdi, rsi
        ; add t.4{r1}, t.4{r1}, t.6{r3}
        add rdi, rdx
        ; cast str{r1}(u8*), t.4{r1}(i64)
@for_4:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp sil, 0
        setne sil
        ; branch t.2{r2}, true, @for_4_body
        or sil, sil
        jnz @for_4_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void main
        ;   rsp+64: var c
        ;   rsp+65: var d
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.4{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString[t.4{r1}]
        call @printString
        ; const a{r8}, 1
        mov bx, 1
        ; const b{r9}, 2
        mov r12w, 2
        ; lt t.6{r0}, a{r8}, b{r9}
        cmp bx, r12w
        setl al
        ; cast t.5{r1}(i64), t.6{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.5{r1}]
        call @printIntLf
        ; lt t.8{r0}, b{r9}, a{r8}
        cmp r12w, bx
        setl al
        ; cast t.7{r1}(i64), t.8{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.7{r1}]
        call @printIntLf
        ; const t.9{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString[t.9{r1}]
        call @printString
        ; const c{r0}, 0
        mov al, 0
        ; const d{r2}, 128
        mov sil, 128
        ; lt t.11{r3}, c{r0}, d{r2}
        cmp al, sil
        setb dl
        ; move c, c{r0}
        lea r11, [rsp+64]
        mov [r11], al
        ; move d, d{r2}
        lea r11, [rsp+65]
        mov [r11], sil
        ; cast t.10{r1}(i64), t.11{r3}(bool)
        movzx rdi, dl
        ; call printIntLf[t.10{r1}]
        call @printIntLf
        ; move c{r2}, c
        lea r11, [rsp+64]
        mov sil, [r11]
        ; move d{r0}, d
        lea r11, [rsp+65]
        mov al, [r11]
        ; lt t.13{r3}, d{r0}, c{r2}
        cmp al, sil
        setb dl
        ; move c, c{r2}
        lea r11, [rsp+64]
        mov [r11], sil
        ; move d, d{r0}
        lea r11, [rsp+65]
        mov [r11], al
        ; cast t.12{r1}(i64), t.13{r3}(bool)
        movzx rdi, dl
        ; call printIntLf[t.12{r1}]
        call @printIntLf
        ; const t.14{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString[t.14{r1}]
        call @printString
        ; lteq t.16{r0}, a{r8}, b{r9}
        cmp bx, r12w
        setle al
        ; cast t.15{r1}(i64), t.16{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.15{r1}]
        call @printIntLf
        ; lteq t.18{r0}, b{r9}, a{r8}
        cmp r12w, bx
        setle al
        ; cast t.17{r1}(i64), t.18{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.17{r1}]
        call @printIntLf
        ; const t.19{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString[t.19{r1}]
        call @printString
        ; move c{r0}, c
        lea r11, [rsp+64]
        mov al, [r11]
        ; move d{r2}, d
        lea r11, [rsp+65]
        mov sil, [r11]
        ; lteq t.21{r3}, c{r0}, d{r2}
        cmp al, sil
        setbe dl
        ; move c, c{r0}
        lea r11, [rsp+64]
        mov [r11], al
        ; move d, d{r2}
        lea r11, [rsp+65]
        mov [r11], sil
        ; cast t.20{r1}(i64), t.21{r3}(bool)
        movzx rdi, dl
        ; call printIntLf[t.20{r1}]
        call @printIntLf
        ; move c{r2}, c
        lea r11, [rsp+64]
        mov sil, [r11]
        ; move d{r0}, d
        lea r11, [rsp+65]
        mov al, [r11]
        ; lteq t.23{r3}, d{r0}, c{r2}
        cmp al, sil
        setbe dl
        ; move c, c{r2}
        lea r11, [rsp+64]
        mov [r11], sil
        ; move d, d{r0}
        lea r11, [rsp+65]
        mov [r11], al
        ; cast t.22{r1}(i64), t.23{r3}(bool)
        movzx rdi, dl
        ; call printIntLf[t.22{r1}]
        call @printIntLf
        ; const t.24{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString[t.24{r1}]
        call @printString
        ; equals t.26{r0}, a{r8}, b{r9}
        cmp bx, r12w
        sete al
        ; cast t.25{r1}(i64), t.26{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.25{r1}]
        call @printIntLf
        ; equals t.28{r0}, b{r9}, a{r8}
        cmp r12w, bx
        sete al
        ; cast t.27{r1}(i64), t.28{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.27{r1}]
        call @printIntLf
        ; const t.29{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString[t.29{r1}]
        call @printString
        ; notequals t.31{r0}, a{r8}, b{r9}
        cmp bx, r12w
        setne al
        ; cast t.30{r1}(i64), t.31{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.30{r1}]
        call @printIntLf
        ; notequals t.33{r0}, b{r9}, a{r8}
        cmp r12w, bx
        setne al
        ; cast t.32{r1}(i64), t.33{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.32{r1}]
        call @printIntLf
        ; const t.34{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString[t.34{r1}]
        call @printString
        ; gteq t.36{r0}, a{r8}, b{r9}
        cmp bx, r12w
        setge al
        ; cast t.35{r1}(i64), t.36{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.35{r1}]
        call @printIntLf
        ; gteq t.38{r0}, b{r9}, a{r8}
        cmp r12w, bx
        setge al
        ; cast t.37{r1}(i64), t.38{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.37{r1}]
        call @printIntLf
        ; const t.39{r1}, [string-7]
        lea rdi, [string_7]
        ; call printString[t.39{r1}]
        call @printString
        ; move c{r0}, c
        lea r11, [rsp+64]
        mov al, [r11]
        ; move d{r2}, d
        lea r11, [rsp+65]
        mov sil, [r11]
        ; gteq t.41{r3}, c{r0}, d{r2}
        cmp al, sil
        setae dl
        ; move c, c{r0}
        lea r11, [rsp+64]
        mov [r11], al
        ; move d, d{r2}
        lea r11, [rsp+65]
        mov [r11], sil
        ; cast t.40{r1}(i64), t.41{r3}(bool)
        movzx rdi, dl
        ; call printIntLf[t.40{r1}]
        call @printIntLf
        ; move c{r2}, c
        lea r11, [rsp+64]
        mov sil, [r11]
        ; move d{r0}, d
        lea r11, [rsp+65]
        mov al, [r11]
        ; gteq t.43{r3}, d{r0}, c{r2}
        cmp al, sil
        setae dl
        ; move c, c{r2}
        lea r11, [rsp+64]
        mov [r11], sil
        ; move d, d{r0}
        lea r11, [rsp+65]
        mov [r11], al
        ; cast t.42{r1}(i64), t.43{r3}(bool)
        movzx rdi, dl
        ; call printIntLf[t.42{r1}]
        call @printIntLf
        ; const t.44{r1}, [string-8]
        lea rdi, [string_8]
        ; call printString[t.44{r1}]
        call @printString
        ; gt t.46{r0}, a{r8}, b{r9}
        cmp bx, r12w
        setg al
        ; cast t.45{r1}(i64), t.46{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.45{r1}]
        call @printIntLf
        ; gt t.48{r8}, b{r9}, a{r8}
        cmp r12w, bx
        setg bl
        ; cast t.47{r1}(i64), t.48{r8}(bool)
        movzx rdi, bl
        ; call printIntLf[t.47{r1}]
        call @printIntLf
        ; const t.49{r1}, [string-9]
        lea rdi, [string_9]
        ; call printString[t.49{r1}]
        call @printString
        ; move c{r8}, c
        lea r11, [rsp+64]
        mov bl, [r11]
        ; move d{r9}, d
        lea r11, [rsp+65]
        mov r12b, [r11]
        ; gt t.51{r0}, c{r8}, d{r9}
        cmp bl, r12b
        seta al
        ; cast t.50{r1}(i64), t.51{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.50{r1}]
        call @printIntLf
        ; gt t.53{r8}, d{r9}, c{r8}
        cmp r12b, bl
        seta bl
        ; cast t.52{r1}(i64), t.53{r8}(bool)
        movzx rdi, bl
        ; call printIntLf[t.52{r1}]
        call @printIntLf
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

