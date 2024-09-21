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
        ;   rsp+24: arg str
        ;   rsp+0: var length
@printString:
        ; reserve space for local variables
        sub rsp, 16
        ; call r.0(0@register,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r.0(0@register,i64)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof r.0(0@register,u8*), chr(0@argument,u8)
        lea rax, [rsp+24]
        mov rcx, rax
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; call _, printStringLength [r.0(0@register,u8*), r.1(1@register,i64)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
@strlen:
        ; reserve space for local variables
        sub rsp, 48
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rbx, [rsp+0]
        mov [rbx], rcx
@for_1:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rbx, [rsp+56]
        mov rcx, [rbx]
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        mov dl, [rcx]
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; notequals r.1(1@register,bool), r.1(1@register,u8), r.2(2@register,u8)
        cmp dl, r9b
        setne dl
        ; branch r.1(1@register,bool), false, @for_1_break
        or dl, dl
        jz @for_1_break
        ; const r.0(0@register,i64), 1
        mov rcx, 1
        ; copy r.1(1@register,i64), length(1@function,i64)
        lea rbx, [rsp+0]
        mov rdx, [rbx]
        ; add r.0(0@register,i64), r.1(1@register,i64), r.0(0@register,i64)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rbx, [rsp+0]
        mov [rbx], rcx
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rbx, [rsp+56]
        mov rcx, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8*)
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; add r.0(0@register,i64), r.0(0@register,i64), r.1(1@register,i64)
        add rcx, rdx
        ; cast r.0(0@register,u8*), r.0(0@register,i64)
        ; copy str(0@argument,u8*), r.0(0@register,u8*)
        lea rbx, [rsp+56]
        mov [rbx], rcx
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; copy r.0(0@register,i64), length(1@function,i64)
        lea rbx, [rsp+0]
        mov rcx, [rbx]
        ; ret r.0(0@register,i64)
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
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
        ;   rsp+1: var t.1
        ;   rsp+2: var t.2
        ;   rsp+3: var t.3
        ;   rsp+4: var t.4
        ;   rsp+5: var t.5
        ;   rsp+8: var t.6
        ;   rsp+16: var t.7
        ;   rsp+24: var t.8
        ;   rsp+25: var t.9
        ;   rsp+26: var t.10
        ;   rsp+27: var t.11
        ;   rsp+32: var t.12
@printBoard:
        ; reserve space for local variables
        sub rsp, 48
        ; const r.0(0@register,u8), 124
        mov cl, 124
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; 11:2 for i < 30
        ; copy i(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
@for_2:
        ; const r.0(0@register,u8), 30
        mov cl, 30
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        cmp dl, cl
        setb cl
        ; branch r.0(0@register,bool), false, @for_2_break
        or cl, cl
        jz @for_2_break
        ; 12:3 if [...] == 0
        ; copy r.0(0@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov cl, [rbx]
        ; cast r.1(1@register,i64), r.0(0@register,u8)
        movzx rdx, cl
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i64)
        lea rax, [var_0]
        add rdx, rax
        ; load r.1(1@register,u8), [r.1(1@register,u8*)]
        mov dl, [rdx]
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; equals r.1(1@register,bool), r.1(1@register,u8), r.2(2@register,u8)
        cmp dl, r9b
        sete dl
        ; branch r.1(1@register,bool), false, @if_3_else
        or dl, dl
        jz @if_3_else
        ; const r.0(0@register,u8), 32
        mov cl, 32
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        jmp @for_2_continue
@if_3_else:
        ; const r.0(0@register,u8), 42
        mov cl, 42
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
@for_2_continue:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
        jmp @for_2
@for_2_break:
        ; const r.0(0@register,u8*), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+2: var pattern
        ;   rsp+3: var j
        ;   rsp+4: var t.4
        ;   rsp+5: var t.5
        ;   rsp+6: var t.6
        ;   rsp+8: var t.7
        ;   rsp+16: var t.8
        ;   rsp+24: var t.9
        ;   rsp+25: var t.10
        ;   rsp+32: var t.11
        ;   rsp+40: var t.12
        ;   rsp+48: var t.13
        ;   rsp+56: var t.14
        ;   rsp+57: var t.15
        ;   rsp+58: var t.16
        ;   rsp+59: var t.17
        ;   rsp+64: var t.18
        ;   rsp+72: var t.19
        ;   rsp+80: var t.20
        ;   rsp+81: var t.21
        ;   rsp+88: var t.22
        ;   rsp+96: var t.23
        ;   rsp+104: var t.24
        ;   rsp+105: var t.25
        ;   rsp+106: var t.26
        ;   rsp+107: var t.27
        ;   rsp+108: var t.28
        ;   rsp+109: var t.29
        ;   rsp+110: var t.30
        ;   rsp+112: var t.31
        ;   rsp+120: var t.32
        ;   rsp+121: var t.33
        ;   rsp+128: var t.34
        ;   rsp+136: var t.35
        ;   rsp+137: var t.36
        ;   rsp+138: var t.37
        ;   rsp+139: var t.38
        ;   rsp+144: var t.39
        ;   rsp+152: var t.40
        ;   rsp+160: var t.41
        ;   rsp+161: var t.42
@main:
        ; reserve space for local variables
        sub rsp, 176
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; 23:2 for i < 30
        ; copy i(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
@for_4:
        ; const r.0(0@register,u8), 30
        mov cl, 30
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        cmp dl, cl
        setb cl
        ; branch r.0(0@register,bool), false, @for_4_break
        or cl, cl
        jz @for_4_break
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; cast r.2(2@register,i64), r.1(1@register,u8)
        movzx r9, dl
        ; array r.2(2@register,u8*), board(0@global,u8*) + r.2(2@register,i64)
        lea rax, [var_0]
        add r9, rax
        ; store [r.2(2@register,u8*)], r.0(0@register,u8)
        mov [r9], cl
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
        jmp @for_4
@for_4_break:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; const r.1(1@register,u8), 29
        mov dl, 29
        ; cast r.1(1@register,i64), r.1(1@register,u8)
        movzx rdx, dl
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i64)
        lea rax, [var_0]
        add rdx, rax
        ; store [r.1(1@register,u8*)], r.0(0@register,u8)
        mov [rdx], cl
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; 30:2 for i < 28
        ; copy i(1@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+1]
        mov [rbx], cl
@for_5:
        ; const r.0(0@register,u8), 28
        mov cl, 28
        ; copy r.1(1@register,u8), i(1@function,u8)
        lea rbx, [rsp+1]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        cmp dl, cl
        setb cl
        ; branch r.0(0@register,bool), false, @main_ret
        or cl, cl
        jz @main_ret
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; array r.0(0@register,u8*), board(0@global,u8*) + r.0(0@register,i64)
        lea rax, [var_0]
        add rcx, rax
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        mov cl, [rcx]
        ; const r.1(1@register,u8), 1
        mov dl, 1
        ; shiftleft r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        mov al, cl
        mov cl, dl
        shl al, cl
        mov cl, al
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i64)
        lea rax, [var_0]
        add rdx, rax
        ; load r.1(1@register,u8), [r.1(1@register,u8*)]
        mov dl, [rdx]
        ; or r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        or cl, dl
        ; const r.1(1@register,u8), 1
        mov dl, 1
        ; 32:3 for j < 29
        ; copy pattern(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+2]
        mov [rbx], cl
        ; copy j(3@function,u8), r.1(1@register,u8)
        lea rbx, [rsp+3]
        mov [rbx], dl
@for_6:
        ; const r.0(0@register,u8), 29
        mov cl, 29
        ; copy r.1(1@register,u8), j(3@function,u8)
        lea rbx, [rsp+3]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        cmp dl, cl
        setb cl
        ; branch r.0(0@register,bool), false, @for_6_break
        or cl, cl
        jz @for_6_break
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), pattern(2@function,u8)
        lea rbx, [rsp+2]
        mov dl, [rbx]
        ; shiftleft r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        shl al, cl
        mov cl, al
        ; const r.1(1@register,u8), 7
        mov dl, 7
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        and cl, dl
        ; const r.1(1@register,u8), 1
        mov dl, 1
        ; copy r.2(2@register,u8), j(3@function,u8)
        lea rbx, [rsp+3]
        mov r9b, [rbx]
        ; add r.1(1@register,u8), r.2(2@register,u8), r.1(1@register,u8)
        mov al, r9b
        add al, dl
        mov dl, al
        ; cast r.1(1@register,i64), r.1(1@register,u8)
        movzx rdx, dl
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i64)
        lea rax, [var_0]
        add rdx, rax
        ; load r.1(1@register,u8), [r.1(1@register,u8*)]
        mov dl, [rdx]
        ; or r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        or cl, dl
        ; const r.1(1@register,u8), 110
        mov dl, 110
        ; shiftright r.1(1@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov rbx, rcx
        mov al, dl
        shr al, cl
        mov dl, al
        mov rcx, rbx
        ; const r.3(3@register,u8), 1
        mov r10b, 1
        ; and r.1(1@register,u8), r.1(1@register,u8), r.3(3@register,u8)
        and dl, r10b
        ; cast r.3(3@register,i64), r.2(2@register,u8)
        movzx r10, r9b
        ; array r.3(3@register,u8*), board(0@global,u8*) + r.3(3@register,i64)
        lea rax, [var_0]
        add r10, rax
        ; store [r.3(3@register,u8*)], r.1(1@register,u8)
        mov [r10], dl
        ; copy pattern(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+2]
        mov [rbx], cl
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), j(3@function,u8)
        lea rbx, [rsp+3]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy j(3@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+3]
        mov [rbx], cl
        jmp @for_6
@for_6_break:
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), i(1@function,u8)
        lea rbx, [rsp+1]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(1@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+1]
        mov [rbx], cl
        jmp @for_5
@main_ret:
        ; release space for local variables
        add rsp, 176
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
