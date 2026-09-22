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
          call _main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void main
        ;   rsp+0: var i.1
        ;   rsp+1: var i.2
        ;   rsp+2: var i.3
_main:
        ; reserve space for local variables
        sub rsp, 16
        ; const i.1, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 3:2 while true
        ; move i.2, i.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
_while_1:
        ; move i.3, i.2
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; add i.3, i.3, 1
        lea rax, [rsp+2]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+2]
        mov [rax], bl
        ; move i.2, i.3
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        jmp _while_1
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
