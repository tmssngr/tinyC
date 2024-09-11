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
        sub rsp, 8
          call init
        add rsp, 8
          call @main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void printString
        ;   rsp+8: arg str
@printString:
        ; call r0(i64 length), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r0(i64 length)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ret

        ; void printChar
        ;   rsp+8: arg chr
@printChar:
        ; addrof r0(u8* t.1), chr(0@argument,u8)
        lea rcx, [rsp+8]
        ; const r1(i64 t.2), 1
        mov rdx, 1
        ; call _, printStringLength [r0(u8* t.1), r1(i64 t.2)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ret

        ; i64 strlen
        ;   rsp+24: arg str
        ;   rsp+0: var length
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0(i64 length), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r0(i64 length)
        lea rax, [rsp+0]
        mov [rax], rcx
@for_1:
        ; copy r0(u8* str), str(0@argument,u8*)
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; load r1(u8 t.3), [r0(u8* str)]
        mov dl, [rcx]
        ; const r2(u8 t.4), 0
        mov r9b, 0
        ; notequals r1(bool t.2), r1(u8 t.3), r2(u8 t.4)
        cmp dl, r9b
        setne dl
        ; branch r1(bool t.2), false, @for_1_break
        or dl, dl
        jz @for_1_break
        ; const r0(i64 t.5), 1
        mov rcx, 1
        ; copy r1(i64 length), length(1@function,i64)
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r0(i64 length), r1(i64 length), r0(i64 t.5)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; copy length(1@function,i64), r0(i64 length)
        lea rax, [rsp+0]
        mov [rax], rcx
        ; copy r0(u8* str), str(0@argument,u8*)
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; cast r0(i64 t.7), r0(u8* str)
        ; const r1(i64 t.8), 1
        mov rdx, 1
        ; add r0(i64 t.6), r0(i64 t.7), r1(i64 t.8)
        add rcx, rdx
        ; cast r0(u8* str), r0(i64 t.6)
        ; copy str(0@argument,u8*), r0(u8* str)
        lea rax, [rsp+24]
        mov [rax], rcx
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; copy r0(i64 length), length(1@function,i64)
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0(i64 length)
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength
@printStringLength:
        mov     rdi, rsp

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     rdx, [rdi+18h]
        mov     r8, [rdi+10h]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

        ; void printBoard
        ;   rsp+0: var i
@printBoard:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0(u8 t.1), 124
        mov cl, 124
        ; call _, printChar [r0(u8 t.1)]
        push rcx
          call @printChar
        add rsp, 8
        ; const r0(u8 i), 0
        mov cl, 0
        ; 11:2 for i < 30
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
@for_2:
        ; const r0(u8 t.3), 30
        mov cl, 30
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; lt r0(bool t.2), r1(u8 i), r0(u8 t.3)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.2), false, @for_2_break
        or cl, cl
        jz @for_2_break
        ; 12:3 if [...] == 0
        ; copy r0(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov cl, [rax]
        ; cast r1(i64 t.6), r0(u8 i)
        movzx rdx, cl
        ; array r1(u8* t.7), board(0@global,u8*) + r1(i64 t.6)
        lea rax, [var_0]
        add rdx, rax
        ; load r1(u8 t.5), [r1(u8* t.7)]
        mov dl, [rdx]
        ; const r2(u8 t.8), 0
        mov r9b, 0
        ; equals r1(bool t.4), r1(u8 t.5), r2(u8 t.8)
        cmp dl, r9b
        sete dl
        ; branch r1(bool t.4), false, @if_3_else
        or dl, dl
        jz @if_3_else
        ; const r0(u8 t.9), 32
        mov cl, 32
        ; call _, printChar [r0(u8 t.9)]
        push rcx
          call @printChar
        add rsp, 8
        jmp @for_2_continue
@if_3_else:
        ; const r0(u8 t.10), 42
        mov cl, 42
        ; call _, printChar [r0(u8 t.10)]
        push rcx
          call @printChar
        add rsp, 8
@for_2_continue:
        ; const r0(u8 t.11), 1
        mov cl, 1
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.11)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_2
@for_2_break:
        ; const r0(u8* t.12), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0(u8* t.12)]
        push rcx
          call @printString
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+2: var pattern
        ;   rsp+3: var j
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0(u8 i), 0
        mov cl, 0
        ; 23:2 for i < 30
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
@for_4:
        ; const r0(u8 t.5), 30
        mov cl, 30
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; lt r0(bool t.4), r1(u8 i), r0(u8 t.5)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.4), false, @for_4_break
        or cl, cl
        jz @for_4_break
        ; const r0(u8 t.6), 0
        mov cl, 0
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; cast r2(i64 t.7), r1(u8 i)
        movzx r9, dl
        ; array r2(u8* t.8), board(0@global,u8*) + r2(i64 t.7)
        lea rax, [var_0]
        add r9, rax
        ; store [r2(u8* t.8)], r0(u8 t.6)
        mov [r9], cl
        ; const r0(u8 t.9), 1
        mov cl, 1
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.9)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_4
@for_4_break:
        ; const r0(u8 t.10), 1
        mov cl, 1
        ; const r1(u8 t.12), 29
        mov dl, 29
        ; cast r1(i64 t.11), r1(u8 t.12)
        movzx rdx, dl
        ; array r1(u8* t.13), board(0@global,u8*) + r1(i64 t.11)
        lea rax, [var_0]
        add rdx, rax
        ; store [r1(u8* t.13)], r0(u8 t.10)
        mov [rdx], cl
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const r0(u8 i), 0
        mov cl, 0
        ; 30:2 for i < 28
        ; copy i(1@function,u8), r0(u8 i)
        lea rax, [rsp+1]
        mov [rax], cl
@for_5:
        ; const r0(u8 t.15), 28
        mov cl, 28
        ; copy r1(u8 i), i(1@function,u8)
        lea rax, [rsp+1]
        mov dl, [rax]
        ; lt r0(bool t.14), r1(u8 i), r0(u8 t.15)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.14), false, @main_ret
        or cl, cl
        jz @main_ret
        ; const r0(i64 t.18), 0
        mov rcx, 0
        ; array r0(u8* t.19), board(0@global,u8*) + r0(i64 t.18)
        lea rax, [var_0]
        add rcx, rax
        ; load r0(u8 t.17), [r0(u8* t.19)]
        mov cl, [rcx]
        ; const r1(u8 t.20), 1
        mov dl, 1
        ; shiftleft r0(u8 t.16), r0(u8 t.17), r1(u8 t.20)
        mov al, cl
        mov cl, dl
        shl al, cl
        mov cl, al
        ; const r1(i64 t.22), 1
        mov rdx, 1
        ; array r1(u8* t.23), board(0@global,u8*) + r1(i64 t.22)
        lea rax, [var_0]
        add rdx, rax
        ; load r1(u8 t.21), [r1(u8* t.23)]
        mov dl, [rdx]
        ; or r0(u8 pattern), r0(u8 t.16), r1(u8 t.21)
        or cl, dl
        ; const r1(u8 j), 1
        mov dl, 1
        ; 32:3 for j < 29
        ; copy pattern(2@function,u8), r0(u8 pattern)
        lea rax, [rsp+2]
        mov [rax], cl
        ; copy j(3@function,u8), r1(u8 j)
        lea rax, [rsp+3]
        mov [rax], dl
@for_6:
        ; const r0(u8 t.25), 29
        mov cl, 29
        ; copy r1(u8 j), j(3@function,u8)
        lea rax, [rsp+3]
        mov dl, [rax]
        ; lt r0(bool t.24), r1(u8 j), r0(u8 t.25)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.24), false, @for_6_break
        or cl, cl
        jz @for_6_break
        ; const r0(u8 t.28), 1
        mov cl, 1
        ; copy r1(u8 pattern), pattern(2@function,u8)
        lea rax, [rsp+2]
        mov dl, [rax]
        ; shiftleft r0(u8 t.27), r1(u8 pattern), r0(u8 t.28)
        mov al, dl
        shl al, cl
        mov cl, al
        ; const r1(u8 t.29), 7
        mov dl, 7
        ; and r0(u8 t.26), r0(u8 t.27), r1(u8 t.29)
        and cl, dl
        ; const r1(u8 t.33), 1
        mov dl, 1
        ; copy r2(u8 j), j(3@function,u8)
        lea rax, [rsp+3]
        mov r9b, [rax]
        ; add r1(u8 t.32), r2(u8 j), r1(u8 t.33)
        mov al, r9b
        add al, dl
        mov dl, al
        ; cast r1(i64 t.31), r1(u8 t.32)
        movzx rdx, dl
        ; array r1(u8* t.34), board(0@global,u8*) + r1(i64 t.31)
        lea rax, [var_0]
        add rdx, rax
        ; load r1(u8 t.30), [r1(u8* t.34)]
        mov dl, [rdx]
        ; or r0(u8 pattern), r0(u8 t.26), r1(u8 t.30)
        or cl, dl
        ; const r1(u8 t.37), 110
        mov dl, 110
        ; shiftright r1(u8 t.36), r1(u8 t.37), r0(u8 pattern)
        mov rbx, rcx
        mov al, dl
        shr al, cl
        mov dl, al
        mov rcx, rbx
        ; const r3(u8 t.38), 1
        mov r10b, 1
        ; and r1(u8 t.35), r1(u8 t.36), r3(u8 t.38)
        and dl, r10b
        ; cast r3(i64 t.39), r2(u8 j)
        movzx r10, r9b
        ; array r3(u8* t.40), board(0@global,u8*) + r3(i64 t.39)
        lea rax, [var_0]
        add r10, rax
        ; store [r3(u8* t.40)], r1(u8 t.35)
        mov [r10], dl
        ; copy pattern(2@function,u8), r0(u8 pattern)
        lea rax, [rsp+2]
        mov [rax], cl
        ; const r0(u8 t.41), 1
        mov cl, 1
        ; copy r1(u8 j), j(3@function,u8)
        lea rax, [rsp+3]
        mov dl, [rax]
        ; add r0(u8 j), r1(u8 j), r0(u8 t.41)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy j(3@function,u8), r0(u8 j)
        lea rax, [rsp+3]
        mov [rax], cl
        jmp @for_6
@for_6_break:
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const r0(u8 t.42), 1
        mov cl, 1
        ; copy r1(u8 i), i(1@function,u8)
        lea rax, [rsp+1]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.42)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(1@function,u8), r0(u8 i)
        lea rax, [rsp+1]
        mov [rax], cl
        jmp @for_5
@main_ret:
        ; release space for local variables
        add rsp, 16
        ret
init:
        sub rsp, 20h
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
        add rsp, 20h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: board (240)
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
