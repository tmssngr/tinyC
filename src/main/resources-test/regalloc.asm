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

        ; u8 simple
@simple:
        sub rsp, 8
        ; const r1, 4
        mov cl, 4
        ; const r2, 3
        mov dl, 3
        ; move r0, r1
        mov al, cl
        ; sub r0, r0, r2
        sub al, dl
        ; 5:9 return one
        add rsp, 8
        ret

        ; u8 registerHint
        ;   rsp+16: arg a
        ;   rsp+24: arg b
@registerHint:
        sub rsp, 8
        ; 9:11 return a + b
        ; move r0, r1
        mov al, cl
        ; add r0, r0, r2
        add al, dl
        add rsp, 8
        ret

        ; u8 max
        ;   rsp+16: arg a
        ;   rsp+24: arg b
@max:
        sub rsp, 8
        ; 13:2 if a < b
        ; lt r3, r1, r2
        cmp cl, dl
        setb r8b
        ; branch r3, true, @if_1_then
        or r8b, r8b
        jnz @if_1_then
        ; 16:9 return a
        ; move r0, r1
        mov al, cl
        jmp @max_ret
@if_1_then:
        ; 14:10 return b
        ; move r0, r2
        mov al, dl
@max_ret:
        add rsp, 8
        ret

        ; i16 fibonacci
        ;   rsp+16: arg i
@fibonacci:
        sub rsp, 8
        ; const r0, 0
        mov ax, 0
        ; const r2, 1
        mov dx, 1
        ; 22:2 while i > 0
        jmp @while_2
@while_2_body:
        ; const r3, 1
        mov r8b, 1
        ; sub r1, r1, r3
        sub cl, r8b
        ; move r3, r0
        mov r8w, ax
        ; add r3, r3, r2
        add r8w, dx
        ; move r0, r2
        mov ax, dx
        ; move r2, r3
        mov dx, r8w
@while_2:
        ; const r3, 0
        mov r8b, 0
        ; gt r3, r1, r3
        cmp cl, r8b
        seta r8b
        ; branch r3, true, @while_2_body
        or r8b, r8b
        jnz @while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; call r0, simple, []
        sub rsp, 20h; shadow space
        call @simple
        add rsp, 20h
        ; move r6, r0
        mov bl, al
        ; const r7, 2
        mov r12b, 2
        ; move r1, r6
        mov cl, bl
        ; move r2, r7
        mov dl, r12b
        ; call _, registerHint [r1, r2]
        sub rsp, 20h; shadow space
        call @registerHint
        add rsp, 20h
        ; move r1, r6
        mov cl, bl
        ; move r2, r7
        mov dl, r12b
        ; call r0, max, [r1, r2]
        sub rsp, 20h; shadow space
        call @max
        add rsp, 20h
        ; const r1, 5
        mov cl, 5
        ; call r0, fibonacci, [r1]
        sub rsp, 20h; shadow space
        call @fibonacci
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
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
