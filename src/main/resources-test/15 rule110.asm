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
        ; call r0(i64 length), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r0(i64 length)]
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
        ; addrof r0(u8* t.1), chr(0@argument,u8)
        lea rcx, [rsp+24]
        ; const r1(i64 t.2), 1
        mov rdx, 1
        ; call _, printStringLength [r0(u8* t.1), r1(i64 t.2)]
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
        ; const r0(i64 length), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r0(i64 length)
        lea rax, [rsp+0]
        mov [rax], rcx
@for_1:
        ; copy r0(u8* str), str(0@argument,u8*)
        lea rax, [rsp+56]
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
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; cast r0(i64 t.7), r0(u8* str)
        ; const r1(i64 t.8), 1
        mov rdx, 1
        ; add r0(i64 t.6), r0(i64 t.7), r1(i64 t.8)
        add rcx, rdx
        ; cast r0(u8* str), r0(i64 t.6)
        ; copy str(0@argument,u8*), r0(u8* str)
        lea rax, [rsp+56]
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
        ;   rsp+32: var t.9
        ;   rsp+33: var t.10
        ;   rsp+34: var t.11
        ;   rsp+35: var t.12
        ;   rsp+40: var t.13
@printBoard:
        ; reserve space for local variables
        sub rsp, 48
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
        ; cast r1(i64 t.7), r0(u8 i)
        movzx rdx, cl
        ; cast r1(u8* t.8), r1(i64 t.7)
        ; addrof r2(u8* t.6), [board(0@global,u8*)]
        lea r9, [var_0]
        ; add r1(u8* t.6), r2(u8* t.6), r1(u8* t.8)
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; load r1(u8 t.5), [r1(u8* t.6)]
        mov dl, [rdx]
        ; const r2(u8 t.9), 0
        mov r9b, 0
        ; equals r1(bool t.4), r1(u8 t.5), r2(u8 t.9)
        cmp dl, r9b
        sete dl
        ; branch r1(bool t.4), false, @if_3_else
        or dl, dl
        jz @if_3_else
        ; const r0(u8 t.10), 32
        mov cl, 32
        ; call _, printChar [r0(u8 t.10)]
        push rcx
          call @printChar
        add rsp, 8
        jmp @for_2_continue
@if_3_else:
        ; const r0(u8 t.11), 42
        mov cl, 42
        ; call _, printChar [r0(u8 t.11)]
        push rcx
          call @printChar
        add rsp, 8
@for_2_continue:
        ; const r0(u8 t.12), 1
        mov cl, 1
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.12)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_2
@for_2_break:
        ; const r0(u8* t.13), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0(u8* t.13)]
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
        ;   rsp+32: var t.10
        ;   rsp+33: var t.11
        ;   rsp+40: var t.12
        ;   rsp+48: var t.13
        ;   rsp+56: var t.14
        ;   rsp+64: var t.15
        ;   rsp+72: var t.16
        ;   rsp+73: var t.17
        ;   rsp+74: var t.18
        ;   rsp+75: var t.19
        ;   rsp+80: var t.20
        ;   rsp+88: var t.21
        ;   rsp+96: var t.22
        ;   rsp+104: var t.23
        ;   rsp+105: var t.24
        ;   rsp+112: var t.25
        ;   rsp+120: var t.26
        ;   rsp+128: var t.27
        ;   rsp+136: var t.28
        ;   rsp+137: var t.29
        ;   rsp+138: var t.30
        ;   rsp+139: var t.31
        ;   rsp+140: var t.32
        ;   rsp+141: var t.33
        ;   rsp+142: var t.34
        ;   rsp+144: var t.35
        ;   rsp+152: var t.36
        ;   rsp+160: var t.37
        ;   rsp+161: var t.38
        ;   rsp+168: var t.39
        ;   rsp+176: var t.40
        ;   rsp+177: var t.41
        ;   rsp+178: var t.42
        ;   rsp+179: var t.43
        ;   rsp+184: var t.44
        ;   rsp+192: var t.45
        ;   rsp+200: var t.46
        ;   rsp+208: var t.47
        ;   rsp+209: var t.48
@main:
        ; reserve space for local variables
        sub rsp, 224
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
        ; cast r2(i64 t.8), r1(u8 i)
        movzx r9, dl
        ; cast r2(u8* t.9), r2(i64 t.8)
        ; addrof r3(u8* t.7), [board(0@global,u8*)]
        lea r10, [var_0]
        ; add r2(u8* t.7), r3(u8* t.7), r2(u8* t.9)
        mov rax, r10
        add rax, r9
        mov r9, rax
        ; store [r2(u8* t.7)], r0(u8 t.6)
        mov [r9], cl
        ; const r0(u8 t.10), 1
        mov cl, 1
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.10)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_4
@for_4_break:
        ; const r0(u8 t.11), 1
        mov cl, 1
        ; const r1(u8 t.14), 29
        mov dl, 29
        ; cast r1(i64 t.13), r1(u8 t.14)
        movzx rdx, dl
        ; cast r1(u8* t.15), r1(i64 t.13)
        ; addrof r2(u8* t.12), [board(0@global,u8*)]
        lea r9, [var_0]
        ; add r1(u8* t.12), r2(u8* t.12), r1(u8* t.15)
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; store [r1(u8* t.12)], r0(u8 t.11)
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
        ; const r0(u8 t.17), 28
        mov cl, 28
        ; copy r1(u8 i), i(1@function,u8)
        lea rax, [rsp+1]
        mov dl, [rax]
        ; lt r0(bool t.16), r1(u8 i), r0(u8 t.17)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.16), false, @main_ret
        or cl, cl
        jz @main_ret
        ; const r0(i64 t.21), 0
        mov rcx, 0
        ; cast r0(u8* t.22), r0(i64 t.21)
        ; addrof r1(u8* t.20), [board(0@global,u8*)]
        lea rdx, [var_0]
        ; add r0(u8* t.20), r1(u8* t.20), r0(u8* t.22)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; load r0(u8 t.19), [r0(u8* t.20)]
        mov cl, [rcx]
        ; const r1(u8 t.23), 1
        mov dl, 1
        ; shiftleft r0(u8 t.18), r0(u8 t.19), r1(u8 t.23)
        mov al, cl
        mov cl, dl
        shl al, cl
        mov cl, al
        ; const r1(i64 t.26), 1
        mov rdx, 1
        ; cast r1(u8* t.27), r1(i64 t.26)
        ; addrof r2(u8* t.25), [board(0@global,u8*)]
        lea r9, [var_0]
        ; add r1(u8* t.25), r2(u8* t.25), r1(u8* t.27)
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; load r1(u8 t.24), [r1(u8* t.25)]
        mov dl, [rdx]
        ; or r0(u8 pattern), r0(u8 t.18), r1(u8 t.24)
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
        ; const r0(u8 t.29), 29
        mov cl, 29
        ; copy r1(u8 j), j(3@function,u8)
        lea rax, [rsp+3]
        mov dl, [rax]
        ; lt r0(bool t.28), r1(u8 j), r0(u8 t.29)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.28), false, @for_6_break
        or cl, cl
        jz @for_6_break
        ; const r0(u8 t.32), 1
        mov cl, 1
        ; copy r1(u8 pattern), pattern(2@function,u8)
        lea rax, [rsp+2]
        mov dl, [rax]
        ; shiftleft r0(u8 t.31), r1(u8 pattern), r0(u8 t.32)
        mov al, dl
        shl al, cl
        mov cl, al
        ; const r1(u8 t.33), 7
        mov dl, 7
        ; and r0(u8 t.30), r0(u8 t.31), r1(u8 t.33)
        and cl, dl
        ; const r1(u8 t.38), 1
        mov dl, 1
        ; copy r2(u8 j), j(3@function,u8)
        lea rax, [rsp+3]
        mov r9b, [rax]
        ; add r1(u8 t.37), r2(u8 j), r1(u8 t.38)
        mov al, r9b
        add al, dl
        mov dl, al
        ; cast r1(i64 t.36), r1(u8 t.37)
        movzx rdx, dl
        ; cast r1(u8* t.39), r1(i64 t.36)
        ; addrof r3(u8* t.35), [board(0@global,u8*)]
        lea r10, [var_0]
        ; add r1(u8* t.35), r3(u8* t.35), r1(u8* t.39)
        mov rax, r10
        add rax, rdx
        mov rdx, rax
        ; load r1(u8 t.34), [r1(u8* t.35)]
        mov dl, [rdx]
        ; or r0(u8 pattern), r0(u8 t.30), r1(u8 t.34)
        or cl, dl
        ; const r1(u8 t.42), 110
        mov dl, 110
        ; shiftright r1(u8 t.41), r1(u8 t.42), r0(u8 pattern)
        mov rbx, rcx
        mov al, dl
        shr al, cl
        mov dl, al
        mov rcx, rbx
        ; const r3(u8 t.43), 1
        mov r10b, 1
        ; and r1(u8 t.40), r1(u8 t.41), r3(u8 t.43)
        and dl, r10b
        ; cast r3(i64 t.45), r2(u8 j)
        movzx r10, r9b
        ; cast r3(u8* t.46), r3(i64 t.45)
        ; addrof r2(u8* t.44), [board(0@global,u8*)]
        lea r9, [var_0]
        ; add r2(u8* t.44), r2(u8* t.44), r3(u8* t.46)
        add r9, r10
        ; store [r2(u8* t.44)], r1(u8 t.40)
        mov [r9], dl
        ; copy pattern(2@function,u8), r0(u8 pattern)
        lea rax, [rsp+2]
        mov [rax], cl
        ; const r0(u8 t.47), 1
        mov cl, 1
        ; copy r1(u8 j), j(3@function,u8)
        lea rax, [rsp+3]
        mov dl, [rax]
        ; add r0(u8 j), r1(u8 j), r0(u8 t.47)
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
        ; const r0(u8 t.48), 1
        mov cl, 1
        ; copy r1(u8 i), i(1@function,u8)
        lea rax, [rsp+1]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.48)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(1@function,u8), r0(u8 i)
        lea rax, [rsp+1]
        mov [rax], cl
        jmp @for_5
@main_ret:
        ; release space for local variables
        add rsp, 224
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
