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

        ; void printBoard
@printBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.1{r1}, 124
        mov dil, 124
        ; call printChar@u8[t.1{r1}]
        call @printChar@u8
        ; const i{r8}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.7{r9}(i64), i{r8}(u8)
        movzx r12, bl
        ; addrof t.6{r0}, [board]
        lea rax, [var_0]
        ; add t.6{r0}, t.6{r0}, t.7{r9}
        add rax, r12
        ; load t.5{r9}, [t.6{r0}]
        mov r12b, [rax]
        ; const t.8{r0}, 0
        mov al, 0
        ; equals t.4{r9}, t.5{r9}, t.8{r0}
        cmp r12b, al
        sete r12b
        ; branch t.4{r9}, true, @if_3_then, @if_3_else
        or r12b, r12b
        jnz @if_3_then
        ; const t.10{r1}, 42
        mov dil, 42
        ; call printChar@u8[t.10{r1}]
        call @printChar@u8
        jmp @for_2_continue
@if_3_then:
        ; const t.9{r1}, 32
        mov dil, 32
        ; call printChar@u8[t.9{r1}]
        call @printChar@u8
@for_2_continue:
        ; add i{r8}, i{r8}, 1
        add bl, 1
@for_2:
        ; const t.3{r9}, 30
        mov r12b, 30
        ; lt t.2{r9}, i{r8}, t.3{r9}
        cmp bl, r12b
        setb r12b
        ; branch t.2{r9}, true, @for_2_body, @for_2_break
        or r12b, r12b
        jnz @for_2_body
        ; const t.11{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.11{r1}]
        call @printString@@u8
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
        ; const i{r8}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const t.6{r9}, 0
        mov r12b, 0
        ; cast t.8{r0}(i64), i{r8}(u8)
        movzx rax, bl
        ; addrof t.7{r1}, [board]
        lea rdi, [var_0]
        ; add t.7{r1}, t.7{r1}, t.8{r0}
        add rdi, rax
        ; store [t.7{r1}], t.6{r9}
        mov [rdi], r12b
        ; add i{r8}, i{r8}, 1
        add bl, 1
@for_4:
        ; const t.5{r9}, 30
        mov r12b, 30
        ; lt t.4{r9}, i{r8}, t.5{r9}
        cmp bl, r12b
        setb r12b
        ; branch t.4{r9}, true, @for_4_body, @for_4_break
        or r12b, r12b
        jnz @for_4_body
        ; const t.9{r8}, 1
        mov bl, 1
        ; const t.11{r9}, 29
        mov r12, 29
        ; addrof t.10{r0}, [board]
        lea rax, [var_0]
        ; add t.10{r0}, t.10{r0}, t.11{r9}
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
        ; const t.17{r9}, 0
        mov r12, 0
        ; addrof t.16{r0}, [board]
        lea rax, [var_0]
        ; add t.16{r0}, t.16{r0}, t.17{r9}
        add rax, r12
        ; load t.15{r9}, [t.16{r0}]
        mov r12b, [rax]
        ; shiftleft t.14{r9}, t.14{r9}, 1
        shl r12b, 1
        ; const t.20{r0}, 1
        mov rax, 1
        ; addrof t.19{r1}, [board]
        lea rdi, [var_0]
        ; add t.19{r1}, t.19{r1}, t.20{r0}
        add rdi, rax
        ; load t.18{r0}, [t.19{r1}]
        mov al, [rdi]
        ; or pattern{r9}, pattern{r9}, t.18{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; shiftleft t.24{r9}, t.24{r9}, 1
        shl r12b, 1
        ; and t.23{r9}, t.23{r9}, 7
        and r12b, 7
        ; move t.28{r1}, j{r0}
        mov dil, al
        ; add t.28{r1}, t.28{r1}, 1
        add dil, 1
        ; cast t.27{r1}(i64), t.28{r1}(u8)
        movzx rdi, dil
        ; addrof t.26{r2}, [board]
        lea rsi, [var_0]
        ; add t.26{r2}, t.26{r2}, t.27{r1}
        add rsi, rdi
        ; load t.25{r1}, [t.26{r2}]
        mov dil, [rsi]
        ; or pattern{r9}, pattern{r9}, t.25{r1}
        or r12b, dil
        ; const t.31{r1}, 110
        mov dil, 110
        ; move pattern{r4}, pattern{r9}
        mov cl, r12b
        ; shiftright t.30{r1}, t.30{r1}, pattern{r4}
        shr dil, cl
        ; and t.29{r1}, t.29{r1}, 1
        and dil, 1
        ; cast t.33{r2}(i64), j{r0}(u8)
        movzx rsi, al
        ; addrof t.32{r3}, [board]
        lea rdx, [var_0]
        ; add t.32{r3}, t.32{r3}, t.33{r2}
        add rdx, rsi
        ; store [t.32{r3}], t.29{r1}
        mov [rdx], dil
        ; add j{r0}, j{r0}, 1
        add al, 1
@for_6:
        ; const t.22{r1}, 29
        mov dil, 29
        ; lt t.21{r1}, j{r0}, t.22{r1}
        cmp al, dil
        setb dil
        ; branch t.21{r1}, true, @for_6_body, @for_6_break
        or dil, dil
        jnz @for_6_body
        ; call printBoard[]
        call @printBoard
        ; add i{r8}, i{r8}, 1
        add bl, 1
@for_5:
        ; const t.13{r0}, 28
        mov al, 28
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

segment readable writable
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

segment readable
        string_0 db '|', 0x0a, 0x00

