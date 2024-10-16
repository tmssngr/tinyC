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

        ; void printChar
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof r1(u8* t.1), chr(0@argument,u8)
        lea rbx, [rsp+24]
        ; const r2(i64 t.2), 1
        mov rcx, 1
        ; call _, printStringLength [r1(u8* t.1), r2(i64 t.2)]
        push rbx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
        ;   rsp+152: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+57: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+80: var t.12
        ;   rsp+88: var t.13
        ;   rsp+96: var t.14
        ;   rsp+104: var t.15
        ;   rsp+112: var t.16
        ;   rsp+120: var t.17
        ;   rsp+128: var t.18
        ;   rsp+136: var t.19
        ;   rsp+137: var t.20
@printUint:
        ; reserve space for local variables
        sub rsp, 144
        ; const r0(u8 pos), 20
        mov al, 20
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], al
        ; 13:2 while true
@while_1:
        ; copy r2(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; copy r1(i64 number), number(0@argument,i64)
        lea rax, [rsp+152]
        mov rbx, [rax]
        ; copy r3(i64 number), r1(i64 number)
        mov rdx, rbx
        ; const r4(u8 t.5), 1
        mov r9b, 1
        ; sub r2(u8 pos), r2(u8 pos), r4(u8 t.5)
        sub cl, r9b
        ; const r4(i64 t.6), 10
        mov r9, 10
        ; mod r3(i64 remainder), r3(i64 number), r4(i64 t.6)
        mov rax, rdx
        mov rbx, r9
        cqo
        idiv rbx
        ; const r4(i64 t.7), 10
        mov r9, 10
        ; div r1(i64 number), r1(i64 number), r4(i64 t.7)
        push rdx
        mov rax, rbx
        mov rbx, r9
        cqo
        idiv rbx
        mov rbx, rax
        pop rdx
        ; cast r3(u8 t.8), r3(i64 remainder)
        ; const r4(u8 t.9), 48
        mov r9b, 48
        ; add r3(u8 digit), r3(u8 t.8), r4(u8 t.9)
        add dl, r9b
        ; copy pos(2@function,u8), r2(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
        ; cast r2(i64 t.11), r2(u8 pos)
        movzx rcx, cl
        ; cast r4(u8* t.12), r2(i64 t.11)
        mov r9, rcx
        ; addrof r2(u8* t.10), [buffer(1@function,u8*)]
        lea rcx, [rsp+0]
        ; add r2(u8* t.10), r2(u8* t.10), r4(u8* t.12)
        add rcx, r9
        ; store [r2(u8* t.10)], r3(u8 digit)
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r2(i64 t.14), 0
        mov rcx, 0
        ; copy number(0@argument,i64), r1(i64 number)
        lea rax, [rsp+152]
        mov [rax], rbx
        ; equals r1(bool t.13), r1(i64 number), r2(i64 t.14)
        cmp rbx, rcx
        sete bl
        ; branch r1(bool t.13), false, @while_1
        or bl, bl
        jz @while_1
        ; copy r3(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov dl, [rax]
        ; cast r1(i64 t.16), r3(u8 pos)
        movzx rbx, dl
        ; cast r2(u8* t.17), r1(i64 t.16)
        mov rcx, rbx
        ; addrof r1(u8* t.15), [buffer(1@function,u8*)]
        lea rbx, [rsp+0]
        ; add r1(u8* t.15), r1(u8* t.15), r2(u8* t.17)
        add rbx, rcx
        ; const r2(u8 t.20), 20
        mov cl, 20
        ; sub r2(u8 t.19), r2(u8 t.20), r3(u8 pos)
        sub cl, dl
        ; cast r2(i64 t.18), r2(u8 t.19)
        movzx rcx, cl
        ; call _, printStringLength [r1(u8* t.15), r2(i64 t.18)]
        push rbx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 144
        ret

        ; void printIntLf
        ;   rsp+40: arg number
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
@printIntLf:
        ; reserve space for local variables
        sub rsp, 32
        ; copy r1(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 27:2 if number < 0
        ; const r2(i64 t.2), 0
        mov rcx, 0
        ; copy number(0@argument,i64), r1(i64 number)
        lea rax, [rsp+40]
        mov [rax], rbx
        ; lt r1(bool t.1), r1(i64 number), r2(i64 t.2)
        cmp rbx, rcx
        setl bl
        ; branch r1(bool t.1), false, @if_3_end
        or bl, bl
        jz @if_3_end
        ; copy r5(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov r10, [rax]
        ; const r1(u8 t.3), 45
        mov bl, 45
        ; call _, printChar [r1(u8 t.3)]
        push rbx
          call @printChar
        add rsp, 8
        ; copy r1(i64 number), r5(i64 number)
        mov rbx, r10
        ; neg r0(i64 number), r1(i64 number)
        mov rax, rbx
        neg rax
        ; copy number(0@argument,i64), r0(i64 number)
        lea rax, [rsp+40]
        mov [rax], rax
@if_3_end:
        ; copy r1(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; call _, printUint [r1(i64 number)]
        push rbx
          call @printUint
        add rsp, 8
        ; const r1(u8 t.4), 10
        mov bl, 10
        ; call _, printChar [r1(u8 t.4)]
        push rbx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 32
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

        ; void main
        ;   rsp+0: var a
        ;   rsp+1: var b
        ;   rsp+2: var t.2
        ;   rsp+8: var t.3
        ;   rsp+16: var t.4
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const r1(u8 a), 1
        mov bl, 1
        ; const r2(u8 b), 2
        mov cl, 2
        ; 6:2 if a > b
        ; copy b(1@function,u8), r2(u8 b)
        lea rax, [rsp+1]
        mov [rax], cl
        ; copy a(0@function,u8), r1(u8 a)
        lea rax, [rsp+0]
        mov [rax], bl
        ; gt r1(bool t.2), r1(u8 a), r2(u8 b)
        cmp bl, cl
        seta bl
        ; branch r1(bool t.2), false, @if_4_else
        or bl, bl
        jz @if_4_else
        ; copy r1(u8 a), a(0@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; cast r1(i64 t.3), r1(u8 a)
        movzx rbx, bl
        ; call _, printIntLf [r1(i64 t.3)]
        push rbx
          call @printIntLf
        add rsp, 8
        jmp @main_ret
@if_4_else:
        ; copy r1(u8 b), b(1@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        ; cast r1(i64 t.4), r1(u8 b)
        movzx rbx, bl
        ; call _, printIntLf [r1(i64 t.4)]
        push rbx
          call @printIntLf
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 32
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
