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

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var t.1
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; 3:2 while true
        ; copy i(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
@while_1:
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
        ; jump @while_1
        jmp @while_1
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
