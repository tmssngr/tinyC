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

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 69:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp sil, 0
        setne sil
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or sil, sil
        jnz @for_1_body
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

        ; void printNibble@u8
        ;   rsp+24: arg x
@printNibble@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; and x{r1}, x{r1}, 15
        and dil, 15
        ; 5:2 if x > 9
        ; gt t.1{r8}, x{r1}, 9
        cmp dil, 9
        seta bl
        ; branch t.1{r8}, false, @if_2_end, @if_2_then
        or bl, bl
        jz @if_2_end
        ; add x{r1}, x{r1}, 7
        add dil, 7
@if_2_end:
        ; add x{r1}, x{r1}, 48
        add dil, 48
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
        ; move t.1{r1}, x{r8}
        mov dil, bl
        ; shiftright t.1{r1}, t.1{r1}, 4
        shr dil, 4
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
        ; move t.5{r9}, i{r8}
        mov r12b, bl
        ; and t.5{r9}, t.5{r9}, 7
        and r12b, 7
        ; equals t.4{r9}, t.5{r9}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.4{r9}, false, @if_4_end, @if_4_then
        or r12b, r12b
        jz @if_4_end
        ; const arg.1.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.1.0{r1}]
        call @printChar@u8
@if_4_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printNibble@u8[i{r1}]
        call @printNibble@u8
        ; add i{r8}, i{r8}, 1
        add bl, 1
@for_3:
        ; lt t.3{r9}, i{r8}, 16
        cmp bl, 16
        setb r12b
        ; branch t.3{r9}, true, @for_3_body, @for_3_break
        or r12b, r12b
        jnz @for_3_body
        ; const arg.3.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.3.0{r1}]
        call @printChar@u8
        ; const i{r8}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; move t.8{r9}, i{r8}
        mov r12b, bl
        ; and t.8{r9}, t.8{r9}, 15
        and r12b, 15
        ; equals t.7{r9}, t.8{r9}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.7{r9}, false, @if_6_end, @if_6_then
        or r12b, r12b
        jz @if_6_end
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printHex2@u8[i{r1}]
        call @printHex2@u8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; move t.10{r9}, i{r8}
        mov r12b, bl
        ; and t.10{r9}, t.10{r9}, 7
        and r12b, 7
        ; equals t.9{r9}, t.10{r9}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.9{r9}, false, @if_7_end, @if_7_then
        or r12b, r12b
        jz @if_7_end
        ; const arg.5.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.5.0{r1}]
        call @printChar@u8
@if_7_end:
        ; move i{r1}, i{r8}
        mov dil, bl
        ; call printChar@u8[i{r1}]
        call @printChar@u8
        ; 35:3 if i & 15 == 15
        ; move t.12{r9}, i{r8}
        mov r12b, bl
        ; and t.12{r9}, t.12{r9}, 15
        and r12b, 15
        ; equals t.11{r9}, t.12{r9}, 15
        cmp r12b, 15
        sete r12b
        ; branch t.11{r9}, false, @for_5_continue, @if_8_then
        or r12b, r12b
        jz @for_5_continue
        ; const arg.7.0{r1}, 10
        mov dil, 10
        ; call printChar@u8[arg.7.0{r1}]
        call @printChar@u8
@for_5_continue:
        ; add i{r8}, i{r8}, 1
        add bl, 1
@for_5:
        ; lt t.6{r0}, i{r8}, 128
        cmp bl, 128
        setb al
        ; branch t.6{r0}, true, @for_5_body, @main_ret
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

