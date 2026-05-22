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
        ; const t.2{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
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
        ; 61:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; const t.5{r2}, 1
        mov rdx, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rdx
        ; const t.6{r2}, 1
        mov rdx, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rcx, rdx
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; const t.4{r3}, 0
        mov r8b, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp dl, r8b
        setne dl
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or dl, dl
        jnz @for_1_body
        ; 64:9 return length
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
        ; const t.1{r1}, 124
        mov cl, 124
        ; call printChar@u8[t.1{r1}]
        call @printChar@u8
        ; const i{r6}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.7{r7}(i64), i{r6}(u8)
        movzx r12, bl
        ; addrof t.6{r0}, [board]
        lea rax, [var_0]
        ; add t.6{r0}, t.6{r0}, t.7{r7}
        add rax, r12
        ; load t.5{r7}, [t.6{r0}]
        mov r12b, [rax]
        ; const t.8{r0}, 0
        mov al, 0
        ; equals t.4{r7}, t.5{r7}, t.8{r0}
        cmp r12b, al
        sete r12b
        ; branch t.4{r7}, true, @if_3_then, @if_3_else
        or r12b, r12b
        jnz @if_3_then
        ; const t.10{r1}, 42
        mov cl, 42
        ; call printChar@u8[t.10{r1}]
        call @printChar@u8
        jmp @for_2_continue
@if_3_then:
        ; const t.9{r1}, 32
        mov cl, 32
        ; call printChar@u8[t.9{r1}]
        call @printChar@u8
@for_2_continue:
        ; const t.11{r7}, 1
        mov r12b, 1
        ; add i{r6}, i{r6}, t.11{r7}
        add bl, r12b
@for_2:
        ; const t.3{r7}, 30
        mov r12b, 30
        ; lt t.2{r7}, i{r6}, t.3{r7}
        cmp bl, r12b
        setb r12b
        ; branch t.2{r7}, true, @for_2_body, @for_2_break
        or r12b, r12b
        jnz @for_2_body
        ; const t.12{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.12{r1}]
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
        ; begin initialize global variables
        ; end initialize global variables
        ; const i{r6}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const t.6{r7}, 0
        mov r12b, 0
        ; cast t.8{r0}(i64), i{r6}(u8)
        movzx rax, bl
        ; addrof t.7{r1}, [board]
        lea rcx, [var_0]
        ; add t.7{r1}, t.7{r1}, t.8{r0}
        add rcx, rax
        ; store [t.7{r1}], t.6{r7}
        mov [rcx], r12b
        ; const t.9{r7}, 1
        mov r12b, 1
        ; add i{r6}, i{r6}, t.9{r7}
        add bl, r12b
@for_4:
        ; const t.5{r7}, 30
        mov r12b, 30
        ; lt t.4{r7}, i{r6}, t.5{r7}
        cmp bl, r12b
        setb r12b
        ; branch t.4{r7}, true, @for_4_body, @for_4_break
        or r12b, r12b
        jnz @for_4_body
        ; const t.10{r6}, 1
        mov bl, 1
        ; const t.12{r7}, 29
        mov r12, 29
        ; addrof t.11{r0}, [board]
        lea rax, [var_0]
        ; add t.11{r0}, t.11{r0}, t.12{r7}
        add rax, r12
        ; store [t.11{r0}], t.10{r6}
        mov [rax], bl
        ; call printBoard[]
        call @printBoard
        ; const i{r6}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp @for_5
@for_5_body:
        ; const t.18{r7}, 0
        mov r12, 0
        ; addrof t.17{r0}, [board]
        lea rax, [var_0]
        ; add t.17{r0}, t.17{r0}, t.18{r7}
        add rax, r12
        ; load t.16{r7}, [t.17{r0}]
        mov r12b, [rax]
        ; const t.19{r1}, 1
        mov cl, 1
        ; shiftleft t.15{r7}, t.15{r7}, t.19{r1}
        shl r12b, cl
        ; const t.22{r0}, 1
        mov rax, 1
        ; addrof t.21{r2}, [board]
        lea rdx, [var_0]
        ; add t.21{r2}, t.21{r2}, t.22{r0}
        add rdx, rax
        ; load t.20{r0}, [t.21{r2}]
        mov al, [rdx]
        ; or pattern{r7}, pattern{r7}, t.20{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; const t.27{r1}, 1
        mov cl, 1
        ; shiftleft t.26{r7}, t.26{r7}, t.27{r1}
        shl r12b, cl
        ; const t.28{r2}, 7
        mov dl, 7
        ; and t.25{r7}, t.25{r7}, t.28{r2}
        and r12b, dl
        ; const t.33{r2}, 1
        mov dl, 1
        ; move t.32{r3}, j{r0}
        mov r8b, al
        ; add t.32{r3}, t.32{r3}, t.33{r2}
        add r8b, dl
        ; cast t.31{r2}(i64), t.32{r3}(u8)
        movzx rdx, r8b
        ; addrof t.30{r3}, [board]
        lea r8, [var_0]
        ; add t.30{r3}, t.30{r3}, t.31{r2}
        add r8, rdx
        ; load t.29{r2}, [t.30{r3}]
        mov dl, [r8]
        ; or pattern{r7}, pattern{r7}, t.29{r2}
        or r12b, dl
        ; const t.36{r2}, 110
        mov dl, 110
        ; move pattern{r1}, pattern{r7}
        mov cl, r12b
        ; shiftright t.35{r2}, t.35{r2}, pattern{r1}
        shr dl, cl
        ; const t.37{r1}, 1
        mov cl, 1
        ; and t.34{r2}, t.34{r2}, t.37{r1}
        and dl, cl
        ; cast t.39{r1}(i64), j{r0}(u8)
        movzx rcx, al
        ; addrof t.38{r3}, [board]
        lea r8, [var_0]
        ; add t.38{r3}, t.38{r3}, t.39{r1}
        add r8, rcx
        ; store [t.38{r3}], t.34{r2}
        mov [r8], dl
        ; const t.40{r1}, 1
        mov cl, 1
        ; add j{r0}, j{r0}, t.40{r1}
        add al, cl
@for_6:
        ; const t.24{r1}, 29
        mov cl, 29
        ; lt t.23{r1}, j{r0}, t.24{r1}
        cmp al, cl
        setb cl
        ; branch t.23{r1}, true, @for_6_body, @for_6_break
        or cl, cl
        jnz @for_6_body
        ; call printBoard[]
        call @printBoard
        ; const t.41{r0}, 1
        mov al, 1
        ; add i{r6}, i{r6}, t.41{r0}
        add bl, al
@for_5:
        ; const t.14{r0}, 28
        mov al, 28
        ; lt t.13{r0}, i{r6}, t.14{r0}
        cmp bl, al
        setb al
        ; branch t.13{r0}, true, @for_5_body, @main_ret
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
