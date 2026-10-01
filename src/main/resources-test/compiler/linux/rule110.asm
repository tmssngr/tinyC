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
        ; move t.1{r1}, t.1{r9}
        mov rdi, r12
        ; const arg.0.1{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
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
        ; add length{r0}, 1
        add rax, 1
        ; add str{r1}, 1
        add rdi, 1
_for_1:
        ; load t.2{r2}, [str{r1}]
        mov sil, [rdi]
        ; branch t.2{r2} notequals 0: for_1_body
        cmp sil, 0
        jne _for_1_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
_printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void printBoard
_printBoard:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const arg.0.0{r1}, 124
        mov dil, 124
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; const i{r8}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp _for_2
_for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.3{r0}(i64), i{r8}(u8)
        movzx rax, bl
        ; addrof t.2{r2}, board
        lea rsi, [var_0]
        ; add t.2{r2}, t.3{r0}
        add rsi, rax
        ; load t.1{r0}, [t.2{r2}]
        mov al, [rsi]
        ; branch t.1{r0} equals 0: if_3_then
        cmp al, 0
        je _if_3_then
        ; const arg.2.0{r1}, 42
        mov dil, 42
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        jmp _for_2_continue
_if_3_then:
        ; const arg.1.0{r1}, 32
        mov dil, 32
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
_for_2_continue:
        ; add i{r8}, 1
        add bl, 1
_for_2:
        ; branch i{r8} lt 30: for_2_body
        cmp bl, 30
        jb _for_2_body
        ; const t.4{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.4{r1}]
        call _printString@@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void main
_main:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const i{r8}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp _for_4
_for_4_body:
        ; const t.4{r0}, 0
        mov al, 0
        ; cast t.6{r1}(i64), i{r8}(u8)
        movzx rdi, bl
        ; addrof t.5{r2}, board
        lea rsi, [var_0]
        ; add t.5{r2}, t.6{r1}
        add rsi, rdi
        ; store [t.5{r2}], t.4{r0}
        mov [rsi], al
        ; add i{r8}, 1
        add bl, 1
_for_4:
        ; branch i{r8} lt 30: for_4_body
        cmp bl, 30
        jb _for_4_body
        ; const t.7{r8}, 1
        mov bl, 1
        ; const t.9{r0}, 29
        mov rax, 29
        ; addrof t.8{r1}, board
        lea rdi, [var_0]
        ; add t.8{r1}, t.9{r0}
        add rdi, rax
        ; store [t.8{r1}], t.7{r8}
        mov [rdi], bl
        ; call printBoard[]
        call _printBoard
        ; const i{r8}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp _for_5
_for_5_body:
        ; const t.13{r0}, 0
        mov rax, 0
        ; addrof t.12{r1}, board
        lea rdi, [var_0]
        ; add t.12{r1}, t.13{r0}
        add rdi, rax
        ; load t.11{r0}, [t.12{r1}]
        mov al, [rdi]
        ; shiftleft t.10{r0}, 1
        shl al, 1
        ; const t.16{r1}, 1
        mov rdi, 1
        ; addrof t.15{r2}, board
        lea rsi, [var_0]
        ; add t.15{r2}, t.16{r1}
        add rsi, rdi
        ; load t.14{r1}, [t.15{r2}]
        mov dil, [rsi]
        ; or pattern{r0}, t.14{r1}
        or al, dil
        ; const j{r1}, 1
        mov dil, 1
        ; 32:3 for j < 29
        jmp _for_6
_for_6_body:
        ; shiftleft t.18{r0}, 1
        shl al, 1
        ; and t.17{r0}, 7
        and al, 7
        ; move t.22{r2}, j{r1}
        mov sil, dil
        ; add t.22{r2}, 1
        add sil, 1
        ; cast t.21{r2}(i64), t.22{r2}(u8)
        movzx rsi, sil
        ; addrof t.20{r3}, board
        lea rdx, [var_0]
        ; add t.20{r3}, t.21{r2}
        add rdx, rsi
        ; load t.19{r2}, [t.20{r3}]
        mov sil, [rdx]
        ; or pattern{r0}, t.19{r2}
        or al, sil
        ; const t.25{r2}, 110
        mov sil, 110
        ; move pattern{r4}, pattern{r0}
        mov cl, al
        ; shiftright t.24{r2}, pattern{r4}
        shr sil, cl
        ; and t.23{r2}, 1
        and sil, 1
        ; cast t.27{r3}(i64), j{r1}(u8)
        movzx rdx, dil
        ; addrof t.26{r4}, board
        lea rcx, [var_0]
        ; add t.26{r4}, t.27{r3}
        add rcx, rdx
        ; store [t.26{r4}], t.23{r2}
        mov [rcx], sil
        ; add j{r1}, 1
        add dil, 1
_for_6:
        ; branch j{r1} lt 29: for_6_body
        cmp dil, 29
        jb _for_6_body
        ; call printBoard[]
        call _printBoard
        ; add i{r8}, 1
        add bl, 1
_for_5:
        ; branch i{r8} lt 28: for_5_body
        cmp bl, 28
        jb _for_5_body
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
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

segment readable
        string_0 db '|', 0x0a, 0x00

