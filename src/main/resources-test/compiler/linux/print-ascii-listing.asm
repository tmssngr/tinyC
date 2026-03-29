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

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 57:2 for *str != 0
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

        ; void printNibble@u8
        ;   rsp+24: arg x
@printNibble@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const t.1{r8}, 15
        mov bl, 15
        ; and x{r1}, x{r1}, t.1{r8}
        and dil, bl
        ; 5:2 if x > 9
        ; const t.3{r8}, 9
        mov bl, 9
        ; gt t.2{r8}, x{r1}, t.3{r8}
        cmp dil, bl
        seta bl
        ; branch t.2{r8}, false, @if_2_end, @if_2_then
        or bl, bl
        jz @if_2_end
        ; const t.4{r8}, 7
        mov bl, 7
        ; add x{r1}, x{r1}, t.4{r8}
        add dil, bl
@if_2_end:
        ; const t.5{r8}, 48
        mov bl, 48
        ; add x{r1}, x{r1}, t.5{r8}
        add dil, bl
        ; call printChar@u8[x{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printHex2@u8
        ;   rsp+24: arg x
@printHex2@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move x{r8}, x{r1}
        mov bl, dil
        ; const t.2{r4}, 4
        mov cl, 4
        ; move t.1{r1}, x{r8}
        mov dil, bl
        ; shiftright t.1{r1}, t.1{r1}, t.2{r4}
        shr dil, cl
        ; call printNibble@u8[t.1{r1}]
        call @printNibble@u8
        ; move x{r1}, x{r8}
        mov dil, bl
        ; call printNibble@u8[x{r1}]
        call @printNibble@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
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
        ; end initialize global variables
        ; const t.2{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.2{r1}]
        call @printString@@u8
        ; const i{r8}, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; const t.7{r9}, 7
        mov r12b, 7
        ; move t.6{r0}, i{r8}
        mov al, bl
        ; and t.6{r0}, t.6{r0}, t.7{r9}
        and al, r12b
        ; const t.8{r9}, 0
        mov r12b, 0
        ; equals t.5{r9}, t.6{r0}, t.8{r9}
        cmp al, r12b
        sete r12b
        ; branch t.5{r9}, false, @if_4_end, @if_4_then
        or r12b, r12b
        jz @if_4_end
        ; const t.9{r1}, 32
        mov dil, 32
        ; call printChar@u8[t.9{r1}]
        call @printChar@u8
@if_4_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printNibble@u8[i{r1}]
        call @printNibble@u8
        ; const t.10{r9}, 1
        mov r12b, 1
        ; add i{r8}, i{r8}, t.10{r9}
        add bl, r12b
@for_3:
        ; const t.4{r9}, 16
        mov r12b, 16
        ; lt t.3{r9}, i{r8}, t.4{r9}
        cmp bl, r12b
        setb r12b
        ; branch t.3{r9}, true, @for_3_body, @for_3_break
        or r12b, r12b
        jnz @for_3_body
        ; const t.11{r1}, 10
        mov dil, 10
        ; call printChar@u8[t.11{r1}]
        call @printChar@u8
        ; const i{r8}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; const t.16{r9}, 15
        mov r12b, 15
        ; move t.15{r0}, i{r8}
        mov al, bl
        ; and t.15{r0}, t.15{r0}, t.16{r9}
        and al, r12b
        ; const t.17{r9}, 0
        mov r12b, 0
        ; equals t.14{r9}, t.15{r0}, t.17{r9}
        cmp al, r12b
        sete r12b
        ; branch t.14{r9}, false, @if_6_end, @if_6_then
        or r12b, r12b
        jz @if_6_end
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printHex2@u8[i{r1}]
        call @printHex2@u8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const t.20{r9}, 7
        mov r12b, 7
        ; move t.19{r0}, i{r8}
        mov al, bl
        ; and t.19{r0}, t.19{r0}, t.20{r9}
        and al, r12b
        ; const t.21{r9}, 0
        mov r12b, 0
        ; equals t.18{r9}, t.19{r0}, t.21{r9}
        cmp al, r12b
        sete r12b
        ; branch t.18{r9}, false, @if_7_end, @if_7_then
        or r12b, r12b
        jz @if_7_end
        ; const t.22{r1}, 32
        mov dil, 32
        ; call printChar@u8[t.22{r1}]
        call @printChar@u8
@if_7_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printChar@u8[i{r1}]
        call @printChar@u8
        ; 35:3 if i & 15 == 15
        ; const t.25{r9}, 15
        mov r12b, 15
        ; move t.24{r0}, i{r8}
        mov al, bl
        ; and t.24{r0}, t.24{r0}, t.25{r9}
        and al, r12b
        ; const t.26{r9}, 15
        mov r12b, 15
        ; equals t.23{r9}, t.24{r0}, t.26{r9}
        cmp al, r12b
        sete r12b
        ; branch t.23{r9}, false, @for_5_continue, @if_8_then
        or r12b, r12b
        jz @for_5_continue
        ; const t.27{r1}, 10
        mov dil, 10
        ; call printChar@u8[t.27{r1}]
        call @printChar@u8
@for_5_continue:
        ; const t.28{r0}, 1
        mov al, 1
        ; add i{r8}, i{r8}, t.28{r0}
        add bl, al
@for_5:
        ; const t.13{r0}, 128
        mov al, 128
        ; lt t.12{r0}, i{r8}, t.13{r0}
        cmp bl, al
        setb al
        ; branch t.12{r0}, true, @for_5_body, @main_ret
        or al, al
        jnz @for_5_body
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

segment readable
        string_0 db ' x', 0x00

