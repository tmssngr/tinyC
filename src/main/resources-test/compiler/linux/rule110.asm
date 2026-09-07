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
        ; move str{r1}, str{r8}
        mov rdi, rbx
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
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
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
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rdi, 1
_for_1:
        ; load t.2{r2}, [str{r1}]
        mov sil, [rdi]
        ; branch t.2{r2} notequals 0: for_1_body, for_1_break
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
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
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
        ; cast t.3{r9}(i64), i{r8}(u8)
        movzx r12, bl
        ; addrof t.2{r0}, [board]
        lea rax, [var_0]
        ; add t.2{r0}, t.2{r0}, t.3{r9}
        add rax, r12
        ; load t.1{r9}, [t.2{r0}]
        mov r12b, [rax]
        ; branch t.1{r9} equals 0: if_3_then, if_3_else
        cmp r12b, 0
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
        ; add i{r8}, i{r8}, 1
        add bl, 1
_for_2:
        ; branch i{r8} lt 30: for_2_body, for_2_break
        cmp bl, 30
        jb _for_2_body
        ; const t.4{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.4{r1}]
        call _printString@@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const i{r8}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp _for_4
_for_4_body:
        ; const t.4{r9}, 0
        mov r12b, 0
        ; cast t.6{r0}(i64), i{r8}(u8)
        movzx rax, bl
        ; addrof t.5{r1}, [board]
        lea rdi, [var_0]
        ; add t.5{r1}, t.5{r1}, t.6{r0}
        add rdi, rax
        ; store [t.5{r1}], t.4{r9}
        mov [rdi], r12b
        ; add i{r8}, i{r8}, 1
        add bl, 1
_for_4:
        ; branch i{r8} lt 30: for_4_body, for_4_break
        cmp bl, 30
        jb _for_4_body
        ; const t.7{r8}, 1
        mov bl, 1
        ; const t.9{r9}, 29
        mov r12, 29
        ; addrof t.8{r0}, [board]
        lea rax, [var_0]
        ; add t.8{r0}, t.8{r0}, t.9{r9}
        add rax, r12
        ; store [t.8{r0}], t.7{r8}
        mov [rax], bl
        ; call printBoard[]
        call _printBoard
        ; const i{r8}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp _for_5
_for_5_body:
        ; const t.13{r9}, 0
        mov r12, 0
        ; addrof t.12{r0}, [board]
        lea rax, [var_0]
        ; add t.12{r0}, t.12{r0}, t.13{r9}
        add rax, r12
        ; load t.11{r9}, [t.12{r0}]
        mov r12b, [rax]
        ; shiftleft t.10{r9}, t.10{r9}, 1
        shl r12b, 1
        ; const t.16{r0}, 1
        mov rax, 1
        ; addrof t.15{r1}, [board]
        lea rdi, [var_0]
        ; add t.15{r1}, t.15{r1}, t.16{r0}
        add rdi, rax
        ; load t.14{r0}, [t.15{r1}]
        mov al, [rdi]
        ; or pattern{r9}, pattern{r9}, t.14{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp _for_6
_for_6_body:
        ; shiftleft t.18{r9}, t.18{r9}, 1
        shl r12b, 1
        ; and t.17{r9}, t.17{r9}, 7
        and r12b, 7
        ; move t.22{r1}, j{r0}
        mov dil, al
        ; add t.22{r1}, t.22{r1}, 1
        add dil, 1
        ; cast t.21{r1}(i64), t.22{r1}(u8)
        movzx rdi, dil
        ; addrof t.20{r2}, [board]
        lea rsi, [var_0]
        ; add t.20{r2}, t.20{r2}, t.21{r1}
        add rsi, rdi
        ; load t.19{r1}, [t.20{r2}]
        mov dil, [rsi]
        ; or pattern{r9}, pattern{r9}, t.19{r1}
        or r12b, dil
        ; const t.25{r1}, 110
        mov dil, 110
        ; move pattern{r4}, pattern{r9}
        mov cl, r12b
        ; shiftright t.24{r1}, t.24{r1}, pattern{r4}
        shr dil, cl
        ; and t.23{r1}, t.23{r1}, 1
        and dil, 1
        ; cast t.27{r2}(i64), j{r0}(u8)
        movzx rsi, al
        ; addrof t.26{r3}, [board]
        lea rdx, [var_0]
        ; add t.26{r3}, t.26{r3}, t.27{r2}
        add rdx, rsi
        ; store [t.26{r3}], t.23{r1}
        mov [rdx], dil
        ; add j{r0}, j{r0}, 1
        add al, 1
_for_6:
        ; branch j{r0} lt 29: for_6_body, for_6_break
        cmp al, 29
        jb _for_6_body
        ; call printBoard[]
        call _printBoard
        ; add i{r8}, i{r8}, 1
        add bl, 1
_for_5:
        ; branch i{r8} lt 28: for_5_body, main_ret
        cmp bl, 28
        jb _for_5_body
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

segment readable writable
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

segment readable
        string_0 db '|', 0x0a, 0x00

