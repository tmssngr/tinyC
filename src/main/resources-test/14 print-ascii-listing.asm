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
        ; call r.0(0@register,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r.0(0@register,i64)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printString_ret:
        ret

        ; void printChar
        ;   rsp+8: arg chr
@printChar:
        ; addrof r.0(0@register,u8*), chr(0@argument,u8)
        lea rax, [rsp+8]
        mov rcx, rax
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; call _, printStringLength [r.0(0@register,u8*), r.1(1@register,i64)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
        ret

        ; i64 strlen
        ;   rsp+24: arg str
        ;   rsp+0: var length
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rbx, [rsp+0]
        mov [rbx], rcx
@for_1:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rbx, [rsp+24]
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
        ; @for_1_body
@for_1_body:
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
@for_1_continue:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rbx, [rsp+24]
        mov rcx, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8*)
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; add r.0(0@register,i64), r.0(0@register,i64), r.1(1@register,i64)
        add rcx, rdx
        ; cast r.0(0@register,u8*), r.0(0@register,i64)
        ; copy str(0@argument,u8*), r.0(0@register,u8*)
        lea rbx, [rsp+24]
        mov [rbx], rcx
        ; jump @for_1
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; copy r.0(0@register,i64), length(1@function,i64)
        lea rbx, [rsp+0]
        mov rcx, [rbx]
        ; ret r.0(0@register,i64)
        mov rax, rcx
@strlen_ret:
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

        ; void printNibble
        ;   rsp+8: arg x
@printNibble:
        ; const r.0(0@register,u8), 15
        mov cl, 15
        ; copy r.1(1@register,u8), x(0@argument,u8)
        lea rbx, [rsp+8]
        mov dl, [rbx]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; 5:2 if x > 9
        ; const r.1(1@register,u8), 9
        mov dl, 9
        ; gt r.1(1@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        seta dl
        ; copy x(0@argument,u8), r.0(0@register,u8)
        lea rbx, [rsp+8]
        mov [rbx], cl
        ; branch r.1(1@register,bool), false, @if_2_end
        or dl, dl
        jz @if_2_end
        ; @if_2_then
@if_2_then:
        ; const r.0(0@register,u8), 7
        mov cl, 7
        ; copy r.1(1@register,u8), x(0@argument,u8)
        lea rbx, [rsp+8]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy x(0@argument,u8), r.0(0@register,u8)
        lea rbx, [rsp+8]
        mov [rbx], cl
@if_2_end:
        ; const r.0(0@register,u8), 48
        mov cl, 48
        ; copy r.1(1@register,u8), x(0@argument,u8)
        lea rbx, [rsp+8]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
@printNibble_ret:
        ret

        ; void printHex2
        ;   rsp+8: arg x
@printHex2:
        ; const r.0(0@register,u8), 4
        mov cl, 4
        ; copy r.1(1@register,u8), x(0@argument,u8)
        lea rbx, [rsp+8]
        mov dl, [rbx]
        ; shiftright r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        shr al, cl
        mov cl, al
        ; call _, printNibble [r.0(0@register,u8)]
        push rcx
          call @printNibble
        add rsp, 8
        ; call _, printNibble [x(0@argument,u8)]
        lea rax, [rsp+8]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
@printHex2_ret:
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; begin initialize global variables
        ; end initialize global variables
        ; const r.0(0@register,u8*), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; 19:2 for i < 16
        ; copy i(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
@for_3:
        ; const r.0(0@register,u8), 16
        mov cl, 16
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        cmp dl, cl
        setb cl
        ; branch r.0(0@register,bool), false, @for_3_break
        or cl, cl
        jz @for_3_break
        ; @for_3_body
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; const r.0(0@register,u8), 7
        mov cl, 7
        ; copy r.1(1@register,u8), i(0@function,u8)
        lea rbx, [rsp+0]
        mov dl, [rbx]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.2(2@register,u8)
        cmp cl, r9b
        sete cl
        ; branch r.0(0@register,bool), false, @if_4_end
        or cl, cl
        jz @if_4_end
        ; @if_4_then
@if_4_then:
        ; const r.0(0@register,u8), 32
        mov cl, 32
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
@if_4_end:
        ; call _, printNibble [i(0@function,u8)]
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
@for_3_continue:
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
        ; jump @for_3
        jmp @for_3
@for_3_break:
        ; const r.0(0@register,u8), 10
        mov cl, 10
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; const r.0(0@register,u8), 32
        mov cl, 32
        ; 27:2 for i < 128
        ; copy i(1@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+1]
        mov [rbx], cl
@for_5:
        ; const r.0(0@register,u8), 128
        mov cl, 128
        ; copy r.1(1@register,u8), i(1@function,u8)
        lea rbx, [rsp+1]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        cmp dl, cl
        setb cl
        ; branch r.0(0@register,bool), false, @for_5_break
        or cl, cl
        jz @for_5_break
        ; @for_5_body
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; const r.0(0@register,u8), 15
        mov cl, 15
        ; copy r.1(1@register,u8), i(1@function,u8)
        lea rbx, [rsp+1]
        mov dl, [rbx]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.2(2@register,u8)
        cmp cl, r9b
        sete cl
        ; branch r.0(0@register,bool), false, @if_6_end
        or cl, cl
        jz @if_6_end
        ; @if_6_then
@if_6_then:
        ; call _, printHex2 [i(1@function,u8)]
        lea rax, [rsp+1]
        mov al, [rax]
        push rax
          call @printHex2
        add rsp, 8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const r.0(0@register,u8), 7
        mov cl, 7
        ; copy r.1(1@register,u8), i(1@function,u8)
        lea rbx, [rsp+1]
        mov dl, [rbx]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.2(2@register,u8)
        cmp cl, r9b
        sete cl
        ; branch r.0(0@register,bool), false, @if_7_end
        or cl, cl
        jz @if_7_end
        ; @if_7_then
@if_7_then:
        ; const r.0(0@register,u8), 32
        mov cl, 32
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
@if_7_end:
        ; call _, printChar [i(1@function,u8)]
        lea rax, [rsp+1]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 35:3 if i & 15 == 15
        ; const r.0(0@register,u8), 15
        mov cl, 15
        ; copy r.1(1@register,u8), i(1@function,u8)
        lea rbx, [rsp+1]
        mov dl, [rbx]
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        and al, cl
        mov cl, al
        ; const r.2(2@register,u8), 15
        mov r9b, 15
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.2(2@register,u8)
        cmp cl, r9b
        sete cl
        ; branch r.0(0@register,bool), false, @if_8_end
        or cl, cl
        jz @if_8_end
        ; @if_8_then
@if_8_then:
        ; const r.0(0@register,u8), 10
        mov cl, 10
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
@if_8_end:
@for_5_continue:
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
        ; jump @for_5
        jmp @for_5
@for_5_break:
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
