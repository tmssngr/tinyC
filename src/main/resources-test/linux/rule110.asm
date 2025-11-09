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

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_1
@for_1_body:
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
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp sil, 0
        setne sil
        ; branch t.2{r2}, true, @for_1_body
        or sil, sil
        jnz @for_1_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void printBoard
@printBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; const t.1{r1}, 124
        mov dil, 124
        ; call printChar[t.1{r1}]
        call @printChar
        ; const i{r8}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.6{r9}(i64), i{r8}(u8)
        movzx r12, bl
        ; cast t.7{r9}(u8*), t.6{r9}(i64)
        ; addrof t.5{r0}, [board]
        lea rax, [var_0]
        ; add t.5{r0}, t.5{r0}, t.7{r9}
        add rax, r12
        ; load t.4{r9}, [t.5{r0}]
        mov r12b, [rax]
        ; equals t.3{r9}, t.4{r9}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.3{r9}, true, @if_3_then
        or r12b, r12b
        jnz @if_3_then
        ; const t.9{r1}, 42
        mov dil, 42
        ; call printChar[t.9{r1}]
        call @printChar
        jmp @for_2_continue
@if_3_then:
        ; const t.8{r1}, 32
        mov dil, 32
        ; call printChar[t.8{r1}]
        call @printChar
@for_2_continue:
        ; inc i{r8}
        inc bl
@for_2:
        ; lt t.2{r9}, i{r8}, 30
        cmp bl, 30
        setb r12b
        ; branch t.2{r9}, true, @for_2_body
        or r12b, r12b
        jnz @for_2_body
        ; const t.10{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString[t.10{r1}]
        call @printString
        add rsp, 32
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
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const i{r8}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const t.5{r9}, 0
        mov r12b, 0
        ; cast t.7{r0}(i64), i{r8}(u8)
        movzx rax, bl
        ; cast t.8{r0}(u8*), t.7{r0}(i64)
        ; addrof t.6{r1}, [board]
        lea rdi, [var_0]
        ; add t.6{r1}, t.6{r1}, t.8{r0}
        add rdi, rax
        ; store [t.6{r1}], t.5{r9}
        mov [rdi], r12b
        ; inc i{r8}
        inc bl
@for_4:
        ; lt t.4{r9}, i{r8}, 30
        cmp bl, 30
        setb r12b
        ; branch t.4{r9}, true, @for_4_body
        or r12b, r12b
        jnz @for_4_body
        ; const t.9{r8}, 1
        mov bl, 1
        ; const t.12{r9}, 29
        mov r12b, 29
        ; cast t.11{r9}(i64), t.12{r9}(u8)
        movzx r12, r12b
        ; cast t.13{r9}(u8*), t.11{r9}(i64)
        ; addrof t.10{r0}, [board]
        lea rax, [var_0]
        ; add t.10{r0}, t.10{r0}, t.13{r9}
        add rax, r12
        ; store [t.10{r0}], t.9{r8}
        mov [rax], bl
        ; call printBoard[]
        call @printBoard
        ; const i{r8}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp @for_5
@for_5_body:
        ; const t.18{r9}, 0
        mov r12, 0
        ; cast t.19{r9}(u8*), t.18{r9}(i64)
        ; addrof t.17{r0}, [board]
        lea rax, [var_0]
        ; add t.17{r0}, t.17{r0}, t.19{r9}
        add rax, r12
        ; load t.16{r9}, [t.17{r0}]
        mov r12b, [rax]
        ; const t.20{r4}, 1
        mov cl, 1
        ; shiftleft t.15{r9}, t.15{r9}, t.20{r4}
        shl r12b, cl
        ; const t.23{r0}, 1
        mov rax, 1
        ; cast t.24{r0}(u8*), t.23{r0}(i64)
        ; addrof t.22{r1}, [board]
        lea rdi, [var_0]
        ; add t.22{r1}, t.22{r1}, t.24{r0}
        add rdi, rax
        ; load t.21{r0}, [t.22{r1}]
        mov al, [rdi]
        ; or pattern{r9}, pattern{r9}, t.21{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; const t.28{r4}, 1
        mov cl, 1
        ; move t.27{r1}, pattern{r9}
        mov dil, r12b
        ; shiftleft t.27{r1}, t.27{r1}, t.28{r4}
        shl dil, cl
        ; const t.29{r2}, 7
        mov sil, 7
        ; move t.26{r9}, t.27{r1}
        mov r12b, dil
        ; and t.26{r9}, t.26{r9}, t.29{r2}
        and r12b, sil
        ; const t.34{r1}, 1
        mov dil, 1
        ; move t.33{r2}, j{r0}
        mov sil, al
        ; add t.33{r2}, t.33{r2}, t.34{r1}
        add sil, dil
        ; cast t.32{r1}(i64), t.33{r2}(u8)
        movzx rdi, sil
        ; cast t.35{r1}(u8*), t.32{r1}(i64)
        ; addrof t.31{r2}, [board]
        lea rsi, [var_0]
        ; add t.31{r2}, t.31{r2}, t.35{r1}
        add rsi, rdi
        ; load t.30{r1}, [t.31{r2}]
        mov dil, [rsi]
        ; or pattern{r9}, pattern{r9}, t.30{r1}
        or r12b, dil
        ; const t.38{r1}, 110
        mov dil, 110
        ; move pattern{r4}, pattern{r9}
        mov cl, r12b
        ; shiftright t.37{r1}, t.37{r1}, pattern{r4}
        shr dil, cl
        ; const t.39{r2}, 1
        mov sil, 1
        ; and t.36{r1}, t.36{r1}, t.39{r2}
        and dil, sil
        ; cast t.41{r2}(i64), j{r0}(u8)
        movzx rsi, al
        ; cast t.42{r2}(u8*), t.41{r2}(i64)
        ; addrof t.40{r3}, [board]
        lea rdx, [var_0]
        ; add t.40{r3}, t.40{r3}, t.42{r2}
        add rdx, rsi
        ; store [t.40{r3}], t.36{r1}
        mov [rdx], dil
        ; inc j{r0}
        inc al
@for_6:
        ; lt t.25{r1}, j{r0}, 29
        cmp al, 29
        setb dil
        ; branch t.25{r1}, true, @for_6_body
        or dil, dil
        jnz @for_6_body
        ; call printBoard[]
        call @printBoard
        ; inc i{r8}
        inc bl
@for_5:
        ; lt t.14{r0}, i{r8}, 28
        cmp bl, 28
        setb al
        ; branch t.14{r0}, true, @for_5_body
        or al, al
        jnz @for_5_body
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

segment readable writable
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

segment readable
        string_0 db '|', 0x0a, 0x00

