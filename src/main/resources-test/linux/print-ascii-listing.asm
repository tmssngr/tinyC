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

        ; void printNibble
        ;   rsp+64: arg x
@printNibble:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; const t.1{r8}, 15
        mov bl, 15
        ; and x{r1}, x{r1}, t.1{r8}
        and dil, bl
        ; 5:2 if x > 9
        ; gt t.2{r8}, x{r1}, 9
        cmp dil, 9
        seta bl
        ; branch t.2{r8}, false, @if_2_end
        or bl, bl
        jz @if_2_end
        ; add x{r1}, 7
        add dil, 7
@if_2_end:
        ; add x{r1}, 48
        add dil, 48
        ; call printChar[x{r1}]
        call @printChar
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printHex2
        ;   rsp+64: arg x
@printHex2:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; move x{r8}, x{r1}
        mov bl, dil
        ; const t.2{r4}, 4
        mov cl, 4
        ; move t.1{r1}, x{r8}
        mov dil, bl
        ; shiftright t.1{r1}, t.1{r1}, t.2{r4}
        shr dil, cl
        ; call printNibble[t.1{r1}]
        call @printNibble
        ; move x{r1}, x{r8}
        mov dil, bl
        ; call printNibble[x{r1}]
        call @printNibble
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
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
        ; const t.2{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString[t.2{r1}]
        call @printString
        ; const i{r8}, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; const t.6{r9}, 7
        mov r12b, 7
        ; move t.5{r0}, i{r8}
        mov al, bl
        ; and t.5{r0}, t.5{r0}, t.6{r9}
        and al, r12b
        ; equals t.4{r9}, t.5{r0}, 0
        cmp al, 0
        sete r12b
        ; branch t.4{r9}, false, @if_4_end
        or r12b, r12b
        jz @if_4_end
        ; const t.7{r1}, 32
        mov dil, 32
        ; call printChar[t.7{r1}]
        call @printChar
@if_4_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printNibble[i{r1}]
        call @printNibble
        ; inc i{r8}
        inc bl
@for_3:
        ; lt t.3{r9}, i{r8}, 16
        cmp bl, 16
        setb r12b
        ; branch t.3{r9}, true, @for_3_body
        or r12b, r12b
        jnz @for_3_body
        ; const t.8{r1}, 10
        mov dil, 10
        ; call printChar[t.8{r1}]
        call @printChar
        ; const i{r8}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; const t.12{r9}, 15
        mov r12b, 15
        ; move t.11{r0}, i{r8}
        mov al, bl
        ; and t.11{r0}, t.11{r0}, t.12{r9}
        and al, r12b
        ; equals t.10{r9}, t.11{r0}, 0
        cmp al, 0
        sete r12b
        ; branch t.10{r9}, false, @if_6_end
        or r12b, r12b
        jz @if_6_end
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printHex2[i{r1}]
        call @printHex2
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const t.15{r9}, 7
        mov r12b, 7
        ; move t.14{r0}, i{r8}
        mov al, bl
        ; and t.14{r0}, t.14{r0}, t.15{r9}
        and al, r12b
        ; equals t.13{r9}, t.14{r0}, 0
        cmp al, 0
        sete r12b
        ; branch t.13{r9}, false, @if_7_end
        or r12b, r12b
        jz @if_7_end
        ; const t.16{r1}, 32
        mov dil, 32
        ; call printChar[t.16{r1}]
        call @printChar
@if_7_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printChar[i{r1}]
        call @printChar
        ; 35:3 if i & 15 == 15
        ; const t.19{r9}, 15
        mov r12b, 15
        ; move t.18{r0}, i{r8}
        mov al, bl
        ; and t.18{r0}, t.18{r0}, t.19{r9}
        and al, r12b
        ; equals t.17{r9}, t.18{r0}, 15
        cmp al, 15
        sete r12b
        ; branch t.17{r9}, false, @for_5_continue
        or r12b, r12b
        jz @for_5_continue
        ; const t.20{r1}, 10
        mov dil, 10
        ; call printChar[t.20{r1}]
        call @printChar
@for_5_continue:
        ; inc i{r8}
        inc bl
@for_5:
        ; lt t.9{r0}, i{r8}, 128
        cmp bl, 128
        setb al
        ; branch t.9{r0}, true, @for_5_body
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

segment readable
        string_0 db ' x', 0x00

