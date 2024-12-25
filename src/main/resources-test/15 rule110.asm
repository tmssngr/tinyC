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

        ; void printString
        ;   rsp+16: arg str
@printString:
        ; save globbered non-volatile registers
        push rbx
        ; move r6, r1
        mov rbx, rcx
        ; move r1, r6
        mov rcx, rbx
        ; call r0, strlen, [r1]
        sub rsp, 20h; shadow space
        call @strlen
        add rsp, 20h
        ; move r1, r6
        mov rcx, rbx
        ; move r2, r0
        mov rdx, rax
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; void printChar
        ;   rsp+16: arg chr
@printChar:
        ; save globbered non-volatile registers
        push rbx
        ; addrof r6, chr
        lea rbx, [rsp+16]
        ; const r2, 1
        mov rdx, 1
        ; move chr, r1
        lea r11, [rsp+16]
        mov [r11], cl
        ; move r1, r6
        mov rcx, rbx
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const r0, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; const r2, 1
        mov rdx, 1
        ; add r0, r0, r2
        add rax, rdx
        ; cast r2(i64), r1(u8*)
        mov rdx, rcx
        ; const r3, 1
        mov r8, 1
        ; add r2, r2, r3
        add rdx, r8
        ; cast r1(u8*), r2(i64)
        mov rcx, rdx
@for_1:
        ; load r2, [r1]
        mov dl, [rcx]
        ; const r3, 0
        mov r8b, 0
        ; notequals r2, r2, r3
        cmp dl, r8b
        setne dl
        ; branch r2, true, @for_1_body
        or dl, dl
        jnz @for_1_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void printBoard
@printBoard:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; const r1, 124
        mov cl, 124
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const r6, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast r7(i64), r6(u8)
        movzx r12, bl
        ; cast r7(u8*), r7(i64)
        ; addrof r0, [board]
        lea rax, [var_0]
        ; add r0, r0, r7
        add rax, r12
        ; load r7, [r0]
        mov r12b, [rax]
        ; const r0, 0
        mov al, 0
        ; equals r7, r7, r0
        cmp r12b, al
        sete r12b
        ; branch r7, true, @if_3_then
        or r12b, r12b
        jnz @if_3_then
        ; const r1, 42
        mov cl, 42
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        jmp @for_2_continue
@if_3_then:
        ; const r1, 32
        mov cl, 32
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@for_2_continue:
        ; const r7, 1
        mov r12b, 1
        ; add r6, r6, r7
        add bl, r12b
@for_2:
        ; const r7, 30
        mov r12b, 30
        ; lt r7, r6, r7
        cmp bl, r12b
        setb r12b
        ; branch r7, true, @for_2_body
        or r12b, r12b
        jnz @for_2_body
        ; const r1, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const r6, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const r7, 0
        mov r12b, 0
        ; cast r0(i64), r6(u8)
        movzx rax, bl
        ; cast r0(u8*), r0(i64)
        ; addrof r1, [board]
        lea rcx, [var_0]
        ; add r1, r1, r0
        add rcx, rax
        ; store [r1], r7
        mov [rcx], r12b
        ; const r7, 1
        mov r12b, 1
        ; add r6, r6, r7
        add bl, r12b
@for_4:
        ; const r7, 30
        mov r12b, 30
        ; lt r7, r6, r7
        cmp bl, r12b
        setb r12b
        ; branch r7, true, @for_4_body
        or r12b, r12b
        jnz @for_4_body
        ; const r6, 1
        mov bl, 1
        ; const r7, 29
        mov r12b, 29
        ; cast r7(i64), r7(u8)
        movzx r12, r12b
        ; cast r7(u8*), r7(i64)
        ; addrof r0, [board]
        lea rax, [var_0]
        ; add r0, r0, r7
        add rax, r12
        ; store [r0], r6
        mov [rax], bl
        ; call _, printBoard []
        sub rsp, 20h; shadow space
        call @printBoard
        add rsp, 20h
        ; const r6, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp @for_5
@for_5_body:
        ; const r7, 0
        mov r12, 0
        ; cast r7(u8*), r7(i64)
        ; addrof r0, [board]
        lea rax, [var_0]
        ; add r0, r0, r7
        add rax, r12
        ; load r7, [r0]
        mov r12b, [rax]
        ; const r1, 1
        mov cl, 1
        ; shiftleft r7, r7, r1
        shl r12b, cl
        ; const r0, 1
        mov rax, 1
        ; cast r0(u8*), r0(i64)
        ; addrof r2, [board]
        lea rdx, [var_0]
        ; add r2, r2, r0
        add rdx, rax
        ; load r0, [r2]
        mov al, [rdx]
        ; or r7, r7, r0
        or r12b, al
        ; const r0, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; const r1, 1
        mov cl, 1
        ; move r2, r7
        mov dl, r12b
        ; shiftleft r2, r2, r1
        shl dl, cl
        ; const r3, 7
        mov r8b, 7
        ; and r2, r2, r3
        and dl, r8b
        ; const r3, 1
        mov r8b, 1
        ; move r4, r0
        mov r9b, al
        ; add r4, r4, r3
        add r9b, r8b
        ; cast r3(i64), r4(u8)
        movzx r8, r9b
        ; cast r3(u8*), r3(i64)
        ; addrof r4, [board]
        lea r9, [var_0]
        ; add r4, r4, r3
        add r9, r8
        ; load r3, [r4]
        mov r8b, [r9]
        ; move r7, r2
        mov r12b, dl
        ; or r7, r7, r3
        or r12b, r8b
        ; const r2, 110
        mov dl, 110
        ; move r1, r7
        mov cl, r12b
        ; shiftright r2, r2, r1
        shr dl, cl
        ; const r1, 1
        mov cl, 1
        ; and r2, r2, r1
        and dl, cl
        ; cast r1(i64), r0(u8)
        movzx rcx, al
        ; cast r1(u8*), r1(i64)
        ; addrof r3, [board]
        lea r8, [var_0]
        ; add r3, r3, r1
        add r8, rcx
        ; store [r3], r2
        mov [r8], dl
        ; const r1, 1
        mov cl, 1
        ; add r0, r0, r1
        add al, cl
@for_6:
        ; const r1, 29
        mov cl, 29
        ; lt r1, r0, r1
        cmp al, cl
        setb cl
        ; branch r1, true, @for_6_body
        or cl, cl
        jnz @for_6_body
        ; call _, printBoard []
        sub rsp, 20h; shadow space
        call @printBoard
        add rsp, 20h
        ; const r0, 1
        mov al, 1
        ; add r6, r6, r0
        add bl, al
@for_5:
        ; const r0, 28
        mov al, 28
        ; lt r0, r6, r0
        cmp bl, al
        setb al
        ; branch r0, true, @for_5_body
        or al, al
        jnz @for_5_body
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
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
