format pe64 console
include 'win64ax.inc'

STD_IN_HANDLE = -10
STD_OUT_HANDLE = -11
STD_ERR_HANDLE = -12

entry start

section '.text' code readable executable

start:
        ; alignment
        and rsp, -16
        call init
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString@@u8
        ;   rsp+48: arg str
@printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call @strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar@u8
        ;   rsp+64: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+64]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
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
        add rcx, 1
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp dl, 0
        setne dl
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or dl, dl
        jnz @for_1_body
        ; 72:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
@printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printBoard
@printBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const arg.0.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.0.0{r1}]
        call @printChar@u8
        ; const i{r6}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.5{r7}(i64), i{r6}(u8)
        movzx r12, bl
        ; addrof t.4{r0}, [board]
        lea rax, [var_0]
        ; add t.4{r0}, t.4{r0}, t.5{r7}
        add rax, r12
        ; load t.3{r7}, [t.4{r0}]
        mov r12b, [rax]
        ; equals t.2{r7}, t.3{r7}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.2{r7}, true, @if_3_then, @if_3_else
        or r12b, r12b
        jnz @if_3_then
        ; const arg.2.0{r1}, 42
        mov cl, 42
        ; call printChar@u8[arg.2.0{r1}]
        call @printChar@u8
        jmp @for_2_continue
@if_3_then:
        ; const arg.1.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.1.0{r1}]
        call @printChar@u8
@for_2_continue:
        ; add i{r6}, i{r6}, 1
        add bl, 1
@for_2:
        ; lt t.1{r7}, i{r6}, 30
        cmp bl, 30
        setb r12b
        ; branch t.1{r7}, true, @for_2_body, @for_2_break
        or r12b, r12b
        jnz @for_2_body
        ; const t.6{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.6{r1}]
        call @printString@@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const i{r6}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const t.5{r7}, 0
        mov r12b, 0
        ; cast t.7{r0}(i64), i{r6}(u8)
        movzx rax, bl
        ; addrof t.6{r1}, [board]
        lea rcx, [var_0]
        ; add t.6{r1}, t.6{r1}, t.7{r0}
        add rcx, rax
        ; store [t.6{r1}], t.5{r7}
        mov [rcx], r12b
        ; add i{r6}, i{r6}, 1
        add bl, 1
@for_4:
        ; lt t.4{r7}, i{r6}, 30
        cmp bl, 30
        setb r12b
        ; branch t.4{r7}, true, @for_4_body, @for_4_break
        or r12b, r12b
        jnz @for_4_body
        ; const t.8{r6}, 1
        mov bl, 1
        ; const t.10{r7}, 29
        mov r12, 29
        ; addrof t.9{r0}, [board]
        lea rax, [var_0]
        ; add t.9{r0}, t.9{r0}, t.10{r7}
        add rax, r12
        ; store [t.9{r0}], t.8{r6}
        mov [rax], bl
        ; call printBoard[]
        call @printBoard
        ; const i{r6}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp @for_5
@for_5_body:
        ; const t.15{r7}, 0
        mov r12, 0
        ; addrof t.14{r0}, [board]
        lea rax, [var_0]
        ; add t.14{r0}, t.14{r0}, t.15{r7}
        add rax, r12
        ; load t.13{r7}, [t.14{r0}]
        mov r12b, [rax]
        ; shiftleft t.12{r7}, t.12{r7}, 1
        shl r12b, 1
        ; const t.18{r0}, 1
        mov rax, 1
        ; addrof t.17{r2}, [board]
        lea rdx, [var_0]
        ; add t.17{r2}, t.17{r2}, t.18{r0}
        add rdx, rax
        ; load t.16{r0}, [t.17{r2}]
        mov al, [rdx]
        ; or pattern{r7}, pattern{r7}, t.16{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; shiftleft t.21{r7}, t.21{r7}, 1
        shl r12b, 1
        ; and t.20{r7}, t.20{r7}, 7
        and r12b, 7
        ; move t.25{r2}, j{r0}
        mov dl, al
        ; add t.25{r2}, t.25{r2}, 1
        add dl, 1
        ; cast t.24{r2}(i64), t.25{r2}(u8)
        movzx rdx, dl
        ; addrof t.23{r3}, [board]
        lea r8, [var_0]
        ; add t.23{r3}, t.23{r3}, t.24{r2}
        add r8, rdx
        ; load t.22{r2}, [t.23{r3}]
        mov dl, [r8]
        ; or pattern{r7}, pattern{r7}, t.22{r2}
        or r12b, dl
        ; const t.28{r2}, 110
        mov dl, 110
        ; move pattern{r1}, pattern{r7}
        mov cl, r12b
        ; shiftright t.27{r2}, t.27{r2}, pattern{r1}
        shr dl, cl
        ; move t.26{r1}, t.27{r2}
        mov cl, dl
        ; and t.26{r1}, t.26{r1}, 1
        and cl, 1
        ; cast t.30{r2}(i64), j{r0}(u8)
        movzx rdx, al
        ; addrof t.29{r3}, [board]
        lea r8, [var_0]
        ; add t.29{r3}, t.29{r3}, t.30{r2}
        add r8, rdx
        ; store [t.29{r3}], t.26{r1}
        mov [r8], cl
        ; add j{r0}, j{r0}, 1
        add al, 1
@for_6:
        ; lt t.19{r1}, j{r0}, 29
        cmp al, 29
        setb cl
        ; branch t.19{r1}, true, @for_6_body, @for_6_break
        or cl, cl
        jnz @for_6_body
        ; call printBoard[]
        call @printBoard
        ; add i{r6}, i{r6}, 1
        add bl, 1
@for_5:
        ; lt t.11{r0}, i{r6}, 28
        cmp bl, 28
        setb al
        ; branch t.11{r0}, true, @for_5_body, @main_ret
        or al, al
        jnz @for_5_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

init:
        sub rsp, 28h
          mov rcx, STD_IN_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdIn]
          mov qword [rcx], rax

          mov rcx, STD_OUT_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdOut]
          mov qword [rcx], rax

          mov rcx, STD_ERR_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdErr]
          mov qword [rcx], rax
        add rsp, 28h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        msvcrt,'MSVCRT.DLL'

import kernel32,\
       ExitProcess,'ExitProcess',\
       GetStdHandle,'GetStdHandle',\
       SetConsoleCursorPosition,'SetConsoleCursorPosition',\
       WriteFile,'WriteFile'

import msvcrt,\
       _getch,'_getch'
