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
        ;   rsp+66: var d
        ;   rsp+68: var t
        ;   rsp+69: var f
        ;   rsp+70: var b1
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
        ; const t.9{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString[t.9{r1}]
        call @printString
        ; const a{r8}, 0
        mov bx, 0
        ; const b{r9}, 1
        mov r12w, 1
        ; const c{r0}, 2
        mov ax, 2
        ; move c, c{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; const d{r0}, 3
        mov ax, 3
        ; move d, d{r0}
        lea r11, [rsp+66]
        mov [r11], ax
        ; const t{r0}, 1
        mov al, 1
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
        ; const f{r0}, 0
        mov al, 0
        ; move f, f{r0}
        lea r11, [rsp+69]
        mov [r11], al
        ; move t.11{r0}, a{r8}
        mov ax, bx
        ; and t.11{r0}, t.11{r0}, a{r8}
        and ax, bx
        ; cast t.10{r1}(i64), t.11{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.10{r1}]
        call @printIntLf
        ; move t.13{r0}, a{r8}
        mov ax, bx
        ; and t.13{r0}, t.13{r0}, b{r9}
        and ax, r12w
        ; cast t.12{r1}(i64), t.13{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.12{r1}]
        call @printIntLf
        ; move t.15{r0}, b{r9}
        mov ax, r12w
        ; and t.15{r0}, t.15{r0}, a{r8}
        and ax, bx
        ; cast t.14{r1}(i64), t.15{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.14{r1}]
        call @printIntLf
        ; move t.17{r0}, b{r9}
        mov ax, r12w
        ; and t.17{r0}, t.17{r0}, b{r9}
        and ax, r12w
        ; cast t.16{r1}(i64), t.17{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.16{r1}]
        call @printIntLf
        ; const t.18{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString[t.18{r1}]
        call @printString
        ; move t.20{r0}, a{r8}
        mov ax, bx
        ; or t.20{r0}, t.20{r0}, a{r8}
        or ax, bx
        ; cast t.19{r1}(i64), t.20{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.19{r1}]
        call @printIntLf
        ; move t.22{r0}, a{r8}
        mov ax, bx
        ; or t.22{r0}, t.22{r0}, b{r9}
        or ax, r12w
        ; cast t.21{r1}(i64), t.22{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.21{r1}]
        call @printIntLf
        ; move t.24{r0}, b{r9}
        mov ax, r12w
        ; or t.24{r0}, t.24{r0}, a{r8}
        or ax, bx
        ; cast t.23{r1}(i64), t.24{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.23{r1}]
        call @printIntLf
        ; move t.26{r0}, b{r9}
        mov ax, r12w
        ; or t.26{r0}, t.26{r0}, b{r9}
        or ax, r12w
        ; cast t.25{r1}(i64), t.26{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.25{r1}]
        call @printIntLf
        ; const t.27{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString[t.27{r1}]
        call @printString
        ; move t.29{r0}, a{r8}
        mov ax, bx
        ; xor t.29{r0}, t.29{r0}, a{r8}
        xor ax, bx
        ; cast t.28{r1}(i64), t.29{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.28{r1}]
        call @printIntLf
        ; move t.31{r0}, a{r8}
        mov ax, bx
        ; move c{r2}, c
        lea r11, [rsp+64]
        mov si, [r11]
        ; xor t.31{r0}, t.31{r0}, c{r2}
        xor ax, si
        ; move c, c{r2}
        lea r11, [rsp+64]
        mov [r11], si
        ; cast t.30{r1}(i64), t.31{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.30{r1}]
        call @printIntLf
        ; move t.33{r0}, b{r9}
        mov ax, r12w
        ; xor t.33{r0}, t.33{r0}, a{r8}
        xor ax, bx
        ; cast t.32{r1}(i64), t.33{r0}(i16)
        movzx rdi, ax
        ; call printIntLf[t.32{r1}]
        call @printIntLf
        ; move t.35{r8}, b{r9}
        mov bx, r12w
        ; move c{r0}, c
        lea r11, [rsp+64]
        mov ax, [r11]
        ; xor t.35{r8}, t.35{r8}, c{r0}
        xor bx, ax
        ; move c, c{r0}
        lea r11, [rsp+64]
        mov [r11], ax
        ; cast t.34{r1}(i64), t.35{r8}(i16)
        movzx rdi, bx
        ; call printIntLf[t.34{r1}]
        call @printIntLf
        ; const t.36{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString[t.36{r1}]
        call @printString
        ; 26:15 logic and
        ; move f{r8}, f
        lea r11, [rsp+69]
        mov bl, [r11]
        ; move t.38{r0}, f{r8}
        mov al, bl
        ; branch t.38{r0}, false, @and_next_5
        or al, al
        jz @and_next_5
        ; move t.38{r0}, f{r8}
        mov al, bl
@and_next_5:
        ; cast t.37{r1}(i64), t.38{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.37{r1}]
        call @printIntLf
        ; 27:15 logic and
        ; move t.40{r0}, f{r8}
        mov al, bl
        ; branch t.40{r0}, false, @and_next_6
        or al, al
        jz @and_next_6
        ; move t{r0}, t
        lea r11, [rsp+68]
        mov al, [r11]
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
@and_next_6:
        ; cast t.39{r1}(i64), t.40{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.39{r1}]
        call @printIntLf
        ; 28:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+68]
        mov al, [r11]
        ; move t.42{r2}, t{r0}
        mov sil, al
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
        ; branch t.42{r2}, false, @and_next_7
        or sil, sil
        jz @and_next_7
        ; move t.42{r2}, f{r8}
        mov sil, bl
@and_next_7:
        ; cast t.41{r1}(i64), t.42{r2}(bool)
        movzx rdi, sil
        ; call printIntLf[t.41{r1}]
        call @printIntLf
        ; 29:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+68]
        mov al, [r11]
        ; move t.44{r2}, t{r0}
        mov sil, al
        ; branch t.44{r2}, true, @and_2nd_8
        or sil, sil
        jnz @and_2nd_8
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
        jmp @and_next_8
@and_2nd_8:
        ; move t.44{r2}, t{r0}
        mov sil, al
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
@and_next_8:
        ; cast t.43{r1}(i64), t.44{r2}(bool)
        movzx rdi, sil
        ; call printIntLf[t.43{r1}]
        call @printIntLf
        ; const t.45{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString[t.45{r1}]
        call @printString
        ; 31:15 logic or
        ; move t.47{r0}, f{r8}
        mov al, bl
        ; branch t.47{r0}, true, @or_next_9
        or al, al
        jnz @or_next_9
        ; move t.47{r0}, f{r8}
        mov al, bl
@or_next_9:
        ; cast t.46{r1}(i64), t.47{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.46{r1}]
        call @printIntLf
        ; 32:15 logic or
        ; move t.49{r0}, f{r8}
        mov al, bl
        ; branch t.49{r0}, true, @or_next_10
        or al, al
        jnz @or_next_10
        ; move t{r0}, t
        lea r11, [rsp+68]
        mov al, [r11]
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
@or_next_10:
        ; cast t.48{r1}(i64), t.49{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.48{r1}]
        call @printIntLf
        ; 33:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+68]
        mov al, [r11]
        ; move t.51{r2}, t{r0}
        mov sil, al
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
        ; branch t.51{r2}, true, @or_next_11
        or sil, sil
        jnz @or_next_11
        ; move t.51{r2}, f{r8}
        mov sil, bl
@or_next_11:
        ; cast t.50{r1}(i64), t.51{r2}(bool)
        movzx rdi, sil
        ; call printIntLf[t.50{r1}]
        call @printIntLf
        ; 34:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+68]
        mov al, [r11]
        ; move t.53{r2}, t{r0}
        mov sil, al
        ; branch t.53{r2}, false, @or_2nd_12
        or sil, sil
        jz @or_2nd_12
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
        jmp @or_next_12
@or_2nd_12:
        ; move t.53{r2}, t{r0}
        mov sil, al
        ; move t, t{r0}
        lea r11, [rsp+68]
        mov [r11], al
@or_next_12:
        ; cast t.52{r1}(i64), t.53{r2}(bool)
        movzx rdi, sil
        ; call printIntLf[t.52{r1}]
        call @printIntLf
        ; const t.54{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString[t.54{r1}]
        call @printString
        ; notlog t.56{r8}, f{r8}
        or bl, bl
        sete bl
        ; cast t.55{r1}(i64), t.56{r8}(bool)
        movzx rdi, bl
        ; call printIntLf[t.55{r1}]
        call @printIntLf
        ; move t{r8}, t
        lea r11, [rsp+68]
        mov bl, [r11]
        ; notlog t.58{r8}, t{r8}
        or bl, bl
        sete bl
        ; cast t.57{r1}(i64), t.58{r8}(bool)
        movzx rdi, bl
        ; call printIntLf[t.57{r1}]
        call @printIntLf
        ; const t.59{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString[t.59{r1}]
        call @printString
        ; const b10{r8}, 10
        mov bl, 10
        ; const b6{r0}, 6
        mov al, 6
        ; const b1{r2}, 1
        mov sil, 1
        ; and t.62{r8}, t.62{r8}, b6{r0}
        and bl, al
        ; or t.61{r8}, t.61{r8}, b1{r2}
        or bl, sil
        ; move b1, b1{r2}
        lea r11, [rsp+70]
        mov [r11], sil
        ; cast t.60{r1}(i64), t.61{r8}(u8)
        movzx rdi, bl
        ; call printIntLf[t.60{r1}]
        call @printIntLf
        ; 43:20 logic or
        ; move c{r8}, c
        lea r11, [rsp+64]
        mov bx, [r11]
        ; equals t.64{r0}, b{r9}, c{r8}
        cmp r12w, bx
        sete al
        ; branch t.64{r0}, true, @or_next_13
        or al, al
        jnz @or_next_13
        ; move d{r0}, d
        lea r11, [rsp+66]
        mov ax, [r11]
        ; lt t.64{r0}, c{r8}, d{r0}
        cmp bx, ax
        setl al
        ; move d, d{r0}
        lea r11, [rsp+66]
        mov [r11], ax
@or_next_13:
        ; cast t.63{r1}(i64), t.64{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.63{r1}]
        call @printIntLf
        ; 44:20 logic and
        ; equals t.66{r0}, b{r9}, c{r8}
        cmp r12w, bx
        sete al
        ; branch t.66{r0}, false, @and_next_14
        or al, al
        jz @and_next_14
        ; move d{r0}, d
        lea r11, [rsp+66]
        mov ax, [r11]
        ; lt t.66{r0}, c{r8}, d{r0}
        cmp bx, ax
        setl al
@and_next_14:
        ; cast t.65{r1}(i64), t.66{r0}(bool)
        movzx rdi, al
        ; call printIntLf[t.65{r1}]
        call @printIntLf
        ; const t.68{r8}, -1
        mov bx, -1
        ; cast t.67{r1}(i64), t.68{r8}(i16)
        movzx rdi, bx
        ; call printIntLf[t.67{r1}]
        call @printIntLf
        ; neg t.70{r8}, b{r9}
        mov rbx, r12
        neg rbx
        ; cast t.69{r1}(i64), t.70{r8}(i16)
        movzx rdi, bx
        ; call printIntLf[t.69{r1}]
        call @printIntLf
        ; move b1{r8}, b1
        lea r11, [rsp+70]
        mov bl, [r11]
        ; not t.72{r8}, b1{r8}
        not rbx
        ; cast t.71{r1}(i64), t.72{r8}(u8)
        movzx rdi, bl
        ; call printIntLf[t.71{r1}]
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
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

