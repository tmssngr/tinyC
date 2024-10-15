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

        ; void printUint
        ;   rsp+136: arg number
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
        ;   rsp+121: var t.18
@printUint:
        ; reserve space for local variables
        sub rsp, 128
        ; const r0(u8 pos), 20
        mov cl, 20
        ; 13:2 while true
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r0(u8 t.5), 1
        mov cl, 1
        ; copy r1(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r0(u8 pos), r1(u8 pos), r0(u8 t.5)
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r1(i64 t.6), 10
        mov rdx, 10
        ; copy r2(i64 number), number(0@argument,i64)
        lea rax, [rsp+136]
        mov r9, [rax]
        ; mod r1(i64 remainder), r2(i64 number), r1(i64 t.6)
        mov rax, r9
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r3(i64 t.7), 10
        mov r10, 10
        ; div r2(i64 number), r2(i64 number), r3(i64 t.7)
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r1(u8 t.8), r1(i64 remainder)
        ; const r3(u8 t.9), 48
        mov r10b, 48
        ; add r1(u8 digit), r1(u8 t.8), r3(u8 t.9)
        add dl, r10b
        ; cast r3(i64 t.10), r0(u8 pos)
        movzx r10, cl
        ; array r3(u8* t.11), buffer(1@function,u8*) + r3(i64 t.10)
        lea rax, [rsp+0]
        add r10, rax
        ; store [r3(u8* t.11)], r1(u8 digit)
        mov [r10], dl
        ; 19:3 if number == 0
        ; const r1(i64 t.13), 0
        mov rdx, 0
        ; equals r1(bool t.12), r2(i64 number), r1(i64 t.13)
        cmp r9, rdx
        sete dl
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
        ; copy number(0@argument,i64), r2(i64 number)
        lea rax, [rsp+136]
        mov [rax], r9
        ; branch r1(bool t.12), false, @while_1
        or dl, dl
        jz @while_1
        ; copy r0(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64 t.15), r0(u8 pos)
        movzx rdx, cl
        ; addrof r1(u8* t.14), [buffer(1@function,u8*) + r1(i64 t.15)]
        lea rax, [rsp+0]
        add rdx, rax
        ; const r2(u8 t.18), 20
        mov r9b, 20
        ; sub r0(u8 t.17), r2(u8 t.18), r0(u8 pos)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64 t.16), r0(u8 t.17)
        movzx rcx, cl
        ; call _, printStringLength [r1(u8* t.14), r0(i64 t.16)]
        push rdx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 128
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
        ; 27:2 if number < 0
        ; const r0(i64 t.2), 0
        mov rcx, 0
        ; copy r1(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rdx, [rax]
        ; lt r0(bool t.1), r1(i64 number), r0(i64 t.2)
        cmp rdx, rcx
        setl cl
        ; branch r0(bool t.1), false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; const r0(u8 t.3), 45
        mov cl, 45
        ; call _, printChar [r0(u8 t.3)]
        push rcx
          call @printChar
        add rsp, 8
        ; copy r0(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rcx, [rax]
        ; neg r0(i64 number), r0(i64 number)
        neg rcx
        ; copy number(0@argument,i64), r0(i64 number)
        lea rax, [rsp+40]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r0(u8 t.4), 10
        mov cl, 10
        ; call _, printChar [r0(u8 t.4)]
        push rcx
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
        ;   rsp+0: var chr
        ;   rsp+1: var result
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+24: var t.4
        ;   rsp+25: var t.5
        ;   rsp+32: var t.6
        ;   rsp+40: var t.7
        ;   rsp+48: var t.8
        ;   rsp+56: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+73: var t.12
        ;   rsp+80: var t.13
        ;   rsp+88: var t.14
        ;   rsp+96: var t.15
        ;   rsp+104: var t.16
        ;   rsp+112: var t.17
        ;   rsp+120: var t.18
        ;   rsp+128: var t.19
        ;   rsp+136: var t.20
        ;   rsp+144: var t.21
@main:
        ; reserve space for local variables
        sub rsp, 160
        ; const r0(u8 chr), 32
        mov cl, 32
        ; const r1(i64 t.2), 0
        mov rdx, 0
        ; array r1(u8* t.3), chars(0@global,u8*) + r1(i64 t.2)
        lea rax, [var_0]
        add rdx, rax
        ; store [r1(u8* t.3)], r0(u8 chr)
        mov [rdx], cl
        ; const r0(i64 t.6), 0
        mov rcx, 0
        ; array r0(u8* t.7), chars(0@global,u8*) + r0(i64 t.6)
        lea rax, [var_0]
        add rcx, rax
        ; load r0(u8 t.5), [r0(u8* t.7)]
        mov cl, [rcx]
        ; const r1(u8 t.8), 1
        mov dl, 1
        ; add r0(u8 t.4), r0(u8 t.5), r1(u8 t.8)
        add cl, dl
        ; const r1(i64 t.9), 1
        mov rdx, 1
        ; array r1(u8* t.10), chars(0@global,u8*) + r1(i64 t.9)
        lea rax, [var_0]
        add rdx, rax
        ; store [r1(u8* t.10)], r0(u8 t.4)
        mov [rdx], cl
        ; const r0(i64 t.13), 1
        mov rcx, 1
        ; array r0(u8* t.14), chars(0@global,u8*) + r0(i64 t.13)
        lea rax, [var_0]
        add rcx, rax
        ; load r0(u8 t.12), [r0(u8* t.14)]
        mov cl, [rcx]
        ; const r1(u8 t.15), 2
        mov dl, 2
        ; add r0(u8 t.11), r0(u8 t.12), r1(u8 t.15)
        add cl, dl
        ; const r1(u8 t.17), 2
        mov dl, 2
        ; cast r1(i64 t.16), r1(u8 t.17)
        movzx rdx, dl
        ; array r1(u8* t.18), chars(0@global,u8*) + r1(i64 t.16)
        lea rax, [var_0]
        add rdx, rax
        ; store [r1(u8* t.18)], r0(u8 t.11)
        mov [rdx], cl
        ; const r0(i64 t.19), 2
        mov rcx, 2
        ; array r0(u8* t.20), chars(0@global,u8*) + r0(i64 t.19)
        lea rax, [var_0]
        add rcx, rax
        ; load r0(u8 result), [r0(u8* t.20)]
        mov cl, [rcx]
        ; cast r0(i64 t.21), r0(u8 result)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.21)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 160
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
        ; variable 0: chars (2048)
        var_0 rb 2048

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
