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
        ; call r0, strlen, [str]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str, r0]
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
        ; addrof r0, chr
        lea rcx, [rsp+8]
        ; const r1, 1
        mov rdx, 1
        ; call _, printStringLength [r0, r1]
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
        ; const r0, 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
@for_1:
        ; move r0, str
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; load r1, [r0]
        mov dl, [rcx]
        ; const r2, 0
        mov r9b, 0
        ; notequals r1, r1, r2
        cmp dl, r9b
        setne dl
        ; branch r1, false, @for_1_break
        or dl, dl
        jz @for_1_break
        ; const r0, 1
        mov rcx, 1
        ; move r1, length
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; move r1, str
        lea rax, [rsp+24]
        mov rdx, [rax]
        ; cast r1(i64), r1(u8*)
        ; const r2, 1
        mov r9, 1
        ; add r1, r1, r2
        add rdx, r9
        ; cast r1(u8*), r1(i64)
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
        ; move str, r1
        lea rax, [rsp+24]
        mov [rax], rdx
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; move r0, length
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; void printBoard
        ;   rsp+0: var i
@printBoard:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0, 124
        mov cl, 124
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; const r0, 0
        mov cl, 0
        ; 11:2 for i < 30
        ; move i, r0
        lea rax, [rsp+0]
        mov [rax], cl
@for_2:
        ; const r0, 30
        mov cl, 30
        ; move r1, i
        lea rax, [rsp+0]
        mov dl, [rax]
        ; lt r0, r1, r0
        cmp dl, cl
        setb cl
        ; branch r0, false, @for_2_break
        or cl, cl
        jz @for_2_break
        ; 12:3 if [...] == 0
        ; move r0, i
        lea rax, [rsp+0]
        mov cl, [rax]
        ; cast r1(i64), r0(u8)
        movzx rdx, cl
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [board]
        lea r9, [var_0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; load r1, [r1]
        mov dl, [rdx]
        ; const r2, 0
        mov r9b, 0
        ; equals r1, r1, r2
        cmp dl, r9b
        sete dl
        ; branch r1, false, @if_3_else
        or dl, dl
        jz @if_3_else
        ; const r0, 32
        mov cl, 32
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        jmp @for_2_continue
@if_3_else:
        ; const r0, 42
        mov cl, 42
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
@for_2_continue:
        ; const r0, 1
        mov cl, 1
        ; move r1, i
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; move i, r0
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_2
@for_2_break:
        ; const r0, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0]
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
        ; const r0, 0
        mov cl, 0
        ; 23:2 for i < 30
        ; move i, r0
        lea rax, [rsp+0]
        mov [rax], cl
@for_4:
        ; const r0, 30
        mov cl, 30
        ; move r1, i
        lea rax, [rsp+0]
        mov dl, [rax]
        ; lt r0, r1, r0
        cmp dl, cl
        setb cl
        ; branch r0, false, @for_4_break
        or cl, cl
        jz @for_4_break
        ; const r0, 0
        mov cl, 0
        ; move r1, i
        lea rax, [rsp+0]
        mov dl, [rax]
        ; cast r2(i64), r1(u8)
        movzx r9, dl
        ; cast r2(u8*), r2(i64)
        ; addrof r3, [board]
        lea r10, [var_0]
        ; add r2, r3, r2
        mov rax, r10
        add rax, r9
        mov r9, rax
        ; store [r2], r0
        mov [r9], cl
        ; const r0, 1
        mov cl, 1
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; move i, r0
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_4
@for_4_break:
        ; const r0, 1
        mov cl, 1
        ; const r1, 29
        mov dl, 29
        ; cast r1(i64), r1(u8)
        movzx rdx, dl
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [board]
        lea r9, [var_0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; store [r1], r0
        mov [rdx], cl
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const r0, 0
        mov cl, 0
        ; 30:2 for i < 28
        ; move i, r0
        lea rax, [rsp+1]
        mov [rax], cl
@for_5:
        ; const r0, 28
        mov cl, 28
        ; move r1, i
        lea rax, [rsp+1]
        mov dl, [rax]
        ; lt r0, r1, r0
        cmp dl, cl
        setb cl
        ; branch r0, false, @main_ret
        or cl, cl
        jz @main_ret
        ; const r0, 0
        mov rcx, 0
        ; cast r0(u8*), r0(i64)
        ; addrof r1, [board]
        lea rdx, [var_0]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; load r0, [r0]
        mov cl, [rcx]
        ; const r1, 1
        mov dl, 1
        ; shiftleft r0, r0, r1
        mov al, cl
        mov cl, dl
        shl al, cl
        mov cl, al
        ; const r1, 1
        mov rdx, 1
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [board]
        lea r9, [var_0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; load r1, [r1]
        mov dl, [rdx]
        ; or r0, r0, r1
        or cl, dl
        ; const r1, 1
        mov dl, 1
        ; 32:3 for j < 29
        ; move pattern, r0
        lea rax, [rsp+2]
        mov [rax], cl
        ; move j, r1
        lea rax, [rsp+3]
        mov [rax], dl
@for_6:
        ; const r0, 29
        mov cl, 29
        ; move r1, j
        lea rax, [rsp+3]
        mov dl, [rax]
        ; lt r0, r1, r0
        cmp dl, cl
        setb cl
        ; branch r0, false, @for_6_break
        or cl, cl
        jz @for_6_break
        ; const r0, 1
        mov cl, 1
        ; move r1, pattern
        lea rax, [rsp+2]
        mov dl, [rax]
        ; shiftleft r0, r1, r0
        mov al, dl
        shl al, cl
        mov cl, al
        ; const r1, 7
        mov dl, 7
        ; and r0, r0, r1
        and cl, dl
        ; const r1, 1
        mov dl, 1
        ; move r2, j
        lea rax, [rsp+3]
        mov r9b, [rax]
        ; move r3, r2
        mov r10b, r9b
        ; add r1, r3, r1
        mov al, r10b
        add al, dl
        mov dl, al
        ; cast r1(i64), r1(u8)
        movzx rdx, dl
        ; cast r1(u8*), r1(i64)
        ; addrof r3, [board]
        lea r10, [var_0]
        ; add r1, r3, r1
        mov rax, r10
        add rax, rdx
        mov rdx, rax
        ; load r1, [r1]
        mov dl, [rdx]
        ; or r0, r0, r1
        or cl, dl
        ; const r1, 110
        mov dl, 110
        ; shiftright r1, r1, r0
        mov rbx, rcx
        mov al, dl
        shr al, cl
        mov dl, al
        mov rcx, rbx
        ; const r3, 1
        mov r10b, 1
        ; and r1, r1, r3
        and dl, r10b
        ; cast r3(i64), r2(u8)
        movzx r10, r9b
        ; cast r3(u8*), r3(i64)
        ; addrof r2, [board]
        lea r9, [var_0]
        ; add r2, r2, r3
        add r9, r10
        ; store [r2], r1
        mov [r9], dl
        ; const r1, 1
        mov dl, 1
        ; move r2, j
        lea rax, [rsp+3]
        mov r9b, [rax]
        ; add r1, r2, r1
        mov al, r9b
        add al, dl
        mov dl, al
        ; move pattern, r0
        lea rax, [rsp+2]
        mov [rax], cl
        ; move j, r1
        lea rax, [rsp+3]
        mov [rax], dl
        jmp @for_6
@for_6_break:
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const r0, 1
        mov cl, 1
        ; move r1, i
        lea rax, [rsp+1]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; move i, r0
        lea rax, [rsp+1]
        mov [rax], cl
        jmp @for_5
@main_ret:
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
