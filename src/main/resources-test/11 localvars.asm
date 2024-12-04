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
        ; const r0, 20
        mov cl, 20
        ; 13:2 while true
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r0, 1
        mov cl, 1
        ; move r1, pos
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r0, r1, r0
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r1, 10
        mov rdx, 10
        ; move r2, number
        lea rax, [rsp+152]
        mov r9, [rax]
        ; move r3, r2
        mov r10, r9
        ; mod r1, r3, r1
        mov rax, r10
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r3, 10
        mov r10, 10
        ; div r2, r2, r3
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r1(u8), r1(i64)
        ; const r3, 48
        mov r10b, 48
        ; add r1, r1, r3
        add dl, r10b
        ; cast r3(i64), r0(u8)
        movzx r10, cl
        ; cast r3(u8*), r3(i64)
        ; Spill pos
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
        ; addrof r0, [buffer]
        lea rcx, [rsp+0]
        ; add r0, r0, r3
        add rcx, r10
        ; store [r0], r1
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r0, 0
        mov rcx, 0
        ; equals r0, r2, r0
        cmp r9, rcx
        sete cl
        ; move number, r2
        lea rax, [rsp+152]
        mov [rax], r9
        ; branch r0, false, @while_1
        or cl, cl
        jz @while_1
        ; move r0, pos
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64), r0(u8)
        movzx rdx, cl
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [buffer]
        lea r9, [rsp+0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; const r2, 20
        mov r9b, 20
        ; sub r0, r2, r0
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; call _, printStringLength [r1, r0]
        push rdx
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
        ; 27:2 if number < 0
        ; const r0, 0
        mov rcx, 0
        ; move r1, number
        lea rax, [rsp+40]
        mov rdx, [rax]
        ; lt r0, r1, r0
        cmp rdx, rcx
        setl cl
        ; branch r0, false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; const r0, 45
        mov cl, 45
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; move r0, number
        lea rax, [rsp+40]
        mov rcx, [rax]
        ; neg r0, r0
        neg rcx
        ; move number, r0
        lea rax, [rsp+40]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r0, 10
        mov cl, 10
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+8: var t.1
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, 10
        mov cl, 10
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
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
