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
        lea rax, [rsp+152]
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
        ; cast r3(i64 t.11), r0(u8 pos)
        movzx r10, cl
        ; cast r3(u8* t.12), r3(i64 t.11)
        ; Spill pos
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
        ; addrof r0(u8* t.10), [buffer(1@function,u8*)]
        lea rcx, [rsp+0]
        ; add r0(u8* t.10), r0(u8* t.10), r3(u8* t.12)
        add rcx, r10
        ; store [r0(u8* t.10)], r1(u8 digit)
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r0(i64 t.14), 0
        mov rcx, 0
        ; equals r0(bool t.13), r2(i64 number), r0(i64 t.14)
        cmp r9, rcx
        sete cl
        ; copy number(0@argument,i64), r2(i64 number)
        lea rax, [rsp+152]
        mov [rax], r9
        ; branch r0(bool t.13), false, @while_1
        or cl, cl
        jz @while_1
        ; copy r0(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64 t.16), r0(u8 pos)
        movzx rdx, cl
        ; cast r1(u8* t.17), r1(i64 t.16)
        ; addrof r2(u8* t.15), [buffer(1@function,u8*)]
        lea r9, [rsp+0]
        ; add r1(u8* t.15), r2(u8* t.15), r1(u8* t.17)
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; const r2(u8 t.20), 20
        mov r9b, 20
        ; sub r0(u8 t.19), r2(u8 t.20), r0(u8 pos)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64 t.18), r0(u8 t.19)
        movzx rcx, cl
        ; call _, printStringLength [r1(u8* t.15), r0(i64 t.18)]
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
@for_4:
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
        ; branch r1(bool t.2), false, @for_4_break
        or dl, dl
        jz @for_4_break
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
        jmp @for_4
@for_4_break:
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

        ; void main
        ;   rsp+0: var second
        ;   rsp+8: var chr
        ;   rsp+16: var t.2
        ;   rsp+24: var t.3
        ;   rsp+32: var t.4
@main:
        ; reserve space for local variables
        sub rsp, 48
        ; begin initialize global variables
        ; const r0(u8* text), [string-0]
        lea rcx, [string_0]
        ; end initialize global variables
        ; copy text(0@global,u8*), r0(u8* text)
        lea rax, [var_0]
        mov [rax], rcx
        ; call _, printString [r0(u8* text)]
        push rcx
          call @printString
        add rsp, 8
        ; call _, printLength []
        sub rsp, 8
          call @printLength
        add rsp, 8
        ; const r0(i64 t.2), 1
        mov rcx, 1
        ; cast r0(u8* t.3), r0(i64 t.2)
        ; copy r1(u8* text), text(0@global,u8*)
        lea rax, [var_0]
        mov rdx, [rax]
        ; copy r2(u8* second), r1(u8* text)
        mov r9, rdx
        ; add r0(u8* second), r2(u8* second), r0(u8* t.3)
        mov rax, r9
        add rax, rcx
        mov rcx, rax
        ; call _, printString [r0(u8* second)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(u8* text), text(0@global,u8*)
        lea rax, [var_0]
        mov rcx, [rax]
        ; load r0(u8 chr), [r0(u8* text)]
        mov cl, [rcx]
        ; cast r0(i64 t.4), r0(u8 chr)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.4)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 48
        ret

        ; void printLength
        ;   rsp+0: var length
        ;   rsp+8: var ptr
        ;   rsp+16: var t.2
        ;   rsp+17: var t.3
        ;   rsp+18: var t.4
        ;   rsp+20: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
        ;   rsp+48: var t.9
@printLength:
        ; reserve space for local variables
        sub rsp, 64
        ; const r0(i16 length), 0
        mov cx, 0
        ; copy r1(u8* text), text(0@global,u8*)
        lea rax, [var_0]
        mov rdx, [rax]
        ; copy r1(u8* ptr), r1(u8* text)
        mov rdx, rdx
        ; 16:2 for *ptr != 0
        ; copy length(0@function,i16), r0(i16 length)
        lea rax, [rsp+0]
        mov [rax], cx
        ; copy ptr(1@function,u8*), r1(u8* ptr)
        lea rax, [rsp+8]
        mov [rax], rdx
@for_5:
        ; copy r0(u8* ptr), ptr(1@function,u8*)
        lea rax, [rsp+8]
        mov rcx, [rax]
        ; load r1(u8 t.3), [r0(u8* ptr)]
        mov dl, [rcx]
        ; const r2(u8 t.4), 0
        mov r9b, 0
        ; notequals r1(bool t.2), r1(u8 t.3), r2(u8 t.4)
        cmp dl, r9b
        setne dl
        ; branch r1(bool t.2), false, @for_5_break
        or dl, dl
        jz @for_5_break
        ; const r0(i16 t.5), 1
        mov cx, 1
        ; copy r1(i16 length), length(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r0(i16 length), r1(i16 length), r0(i16 t.5)
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; copy length(0@function,i16), r0(i16 length)
        lea rax, [rsp+0]
        mov [rax], cx
        ; copy r0(u8* ptr), ptr(1@function,u8*)
        lea rax, [rsp+8]
        mov rcx, [rax]
        ; cast r0(i64 t.7), r0(u8* ptr)
        ; const r1(i64 t.8), 1
        mov rdx, 1
        ; add r0(i64 t.6), r0(i64 t.7), r1(i64 t.8)
        add rcx, rdx
        ; cast r0(u8* ptr), r0(i64 t.6)
        ; copy ptr(1@function,u8*), r0(u8* ptr)
        lea rax, [rsp+8]
        mov [rax], rcx
        jmp @for_5
@for_5_break:
        ; copy r0(i16 length), length(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; cast r0(i64 t.9), r0(i16 length)
        movzx rcx, cx
        ; call _, printIntLf [r0(i64 t.9)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 64
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
        ; variable 0: text (8)
        var_0 rb 8

section '.data' data readable
        string_0 db 'hello world', 0x0a, 0x00

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
