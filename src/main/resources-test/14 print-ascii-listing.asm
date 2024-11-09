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
        ; call r0, strlen, [str]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str, r0]
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
        ; addrof r0, chr
        lea rcx, [rsp+24]
        ; const r1, 1
        mov rdx, 1
        ; call _, printStringLength [r0, r1]
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
        ; const r0, 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
        jmp @for_1
@for_1_body:
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
        lea rax, [rsp+56]
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
        lea rax, [rsp+56]
        mov [rax], rdx
@for_1:
        ; move r0, str
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; load r1, [r0]
        mov dl, [rcx]
        ; const r2, 0
        mov r9b, 0
        ; notequals r1, r1, r2
        cmp dl, r9b
        setne dl
        ; branch r1, true, @for_1_body
        or dl, dl
        jnz @for_1_body
        ; 40:9 return length
        ; move r0, length
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
        ret

        ; void printNibble
        ;   rsp+24: arg x
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
        ;   rsp+4: var t.5
@printNibble:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0, 15
        mov cl, 15
        ; move r1, x
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r0, r1, r0
        mov al, dl
        and al, cl
        mov cl, al
        ; 5:2 if x > 9
        ; const r1, 9
        mov dl, 9
        ; gt r1, r0, r1
        cmp cl, dl
        seta dl
        ; move x, r0
        lea rax, [rsp+24]
        mov [rax], cl
        ; branch r1, false, @if_2_end
        or dl, dl
        jz @if_2_end
        ; const r0, 7
        mov cl, 7
        ; move r1, x
        lea rax, [rsp+24]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; move x, r0
        lea rax, [rsp+24]
        mov [rax], cl
@if_2_end:
        ; const r0, 48
        mov cl, 48
        ; move r1, x
        lea rax, [rsp+24]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printHex2
        ;   rsp+24: arg x
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
@printHex2:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0, 4
        mov cl, 4
        ; move r1, x
        lea rax, [rsp+24]
        mov dl, [rax]
        ; move r2, r1
        mov r9b, dl
        ; shiftright r0, r2, r0
        mov al, r9b
        shr al, cl
        mov cl, al
        ; call _, printNibble [r0]
        push rcx
          call @printNibble
        add rsp, 8
        ; call _, printNibble [x]
        lea rax, [rsp+24]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
        ;   rsp+18: var t.5
        ;   rsp+19: var t.6
        ;   rsp+20: var t.7
        ;   rsp+21: var t.8
        ;   rsp+22: var t.9
        ;   rsp+23: var t.10
        ;   rsp+24: var t.11
        ;   rsp+25: var t.12
        ;   rsp+26: var t.13
        ;   rsp+27: var t.14
        ;   rsp+28: var t.15
        ;   rsp+29: var t.16
        ;   rsp+30: var t.17
        ;   rsp+31: var t.18
        ;   rsp+32: var t.19
        ;   rsp+33: var t.20
        ;   rsp+34: var t.21
        ;   rsp+35: var t.22
        ;   rsp+36: var t.23
        ;   rsp+37: var t.24
        ;   rsp+38: var t.25
        ;   rsp+39: var t.26
        ;   rsp+40: var t.27
        ;   rsp+41: var t.28
@main:
        ; reserve space for local variables
        sub rsp, 48
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; const r0, 0
        mov cl, 0
        ; 19:2 for i < 16
        ; move i, r0
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; const r0, 7
        mov cl, 7
        ; move r1, i
        lea rax, [rsp+0]
        mov dl, [rax]
        ; move r2, r1
        mov r9b, dl
        ; and r0, r2, r0
        mov al, r9b
        and al, cl
        mov cl, al
        ; const r2, 0
        mov r9b, 0
        ; equals r0, r0, r2
        cmp cl, r9b
        sete cl
        ; branch r0, false, @if_4_end
        or cl, cl
        jz @if_4_end
        ; const r0, 32
        mov cl, 32
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
@if_4_end:
        ; call _, printNibble [i]
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
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
@for_3:
        ; const r0, 16
        mov cl, 16
        ; move r1, i
        lea rax, [rsp+0]
        mov dl, [rax]
        ; lt r0, r1, r0
        cmp dl, cl
        setb cl
        ; branch r0, true, @for_3_body
        or cl, cl
        jnz @for_3_body
        ; const r0, 10
        mov cl, 10
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; const r0, 32
        mov cl, 32
        ; 27:2 for i < 128
        ; move i, r0
        lea rax, [rsp+1]
        mov [rax], cl
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; const r0, 15
        mov cl, 15
        ; move r1, i
        lea rax, [rsp+1]
        mov dl, [rax]
        ; move r2, r1
        mov r9b, dl
        ; and r0, r2, r0
        mov al, r9b
        and al, cl
        mov cl, al
        ; const r2, 0
        mov r9b, 0
        ; equals r0, r0, r2
        cmp cl, r9b
        sete cl
        ; branch r0, false, @if_6_end
        or cl, cl
        jz @if_6_end
        ; call _, printHex2 [i]
        lea rax, [rsp+1]
        mov al, [rax]
        push rax
          call @printHex2
        add rsp, 8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const r0, 7
        mov cl, 7
        ; move r1, i
        lea rax, [rsp+1]
        mov dl, [rax]
        ; move r2, r1
        mov r9b, dl
        ; and r0, r2, r0
        mov al, r9b
        and al, cl
        mov cl, al
        ; const r2, 0
        mov r9b, 0
        ; equals r0, r0, r2
        cmp cl, r9b
        sete cl
        ; branch r0, false, @if_7_end
        or cl, cl
        jz @if_7_end
        ; const r0, 32
        mov cl, 32
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
@if_7_end:
        ; call _, printChar [i]
        lea rax, [rsp+1]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 35:3 if i & 15 == 15
        ; const r0, 15
        mov cl, 15
        ; move r1, i
        lea rax, [rsp+1]
        mov dl, [rax]
        ; move r2, r1
        mov r9b, dl
        ; and r0, r2, r0
        mov al, r9b
        and al, cl
        mov cl, al
        ; const r2, 15
        mov r9b, 15
        ; equals r0, r0, r2
        cmp cl, r9b
        sete cl
        ; branch r0, false, @for_5_continue
        or cl, cl
        jz @for_5_continue
        ; const r0, 10
        mov cl, 10
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
@for_5_continue:
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
@for_5:
        ; const r0, 128
        mov cl, 128
        ; move r1, i
        lea rax, [rsp+1]
        mov dl, [rax]
        ; lt r0, r1, r0
        cmp dl, cl
        setb cl
        ; branch r0, true, @for_5_body
        or cl, cl
        jnz @for_5_body
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

section '.data' data readable
        string_0 db ' x', 0x00

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
