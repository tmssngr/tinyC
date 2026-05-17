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

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; call printStringLength@@u8@u8[t.1, t.2]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+136: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+40: var t.5
        ;   rsp+48: var t.6
        ;   rsp+56: var t.7
        ;   rsp+57: var t.8
        ;   rsp+64: var t.9
        ;   rsp+72: var t.10
        ;   rsp+80: var t.11
        ;   rsp+88: var t.12
        ;   rsp+96: var t.13
        ;   rsp+104: var t.14
        ;   rsp+112: var t.15
        ;   rsp+120: var t.16
        ;   rsp+121: var t.17
@printUint@i64:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 25:2 while true
@while_1:
        ; dec pos
        lea rax, [rsp+20]
        mov bl, [rax]
        dec bl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.5, 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; move remainder, number
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, t.5
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.6, 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number, number, t.6
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+136]
        mov [rdx], rbx
        ; cast t.7(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.8, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; move digit, t.7
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, t.8
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.10(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.11(u8*), t.10(i64)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.9, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.9, t.9, t.11
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.9], digit
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 31:3 if number == 0
        ; equals t.12, number, 0
        lea rax, [rsp+136]
        mov rbx, [rax]
        cmp rbx, 0
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.12, false, @while_1, @while_1_break
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.14(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+104]
        mov [rax], rbx
        ; cast t.15(u8*), t.14(i64)
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov [rax], rbx
        ; addrof t.13, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; add t.13, t.13, t.15
        lea rax, [rsp+96]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+96]
        mov [rax], rbx
        ; const t.17, 20
        mov al, 20
        lea rbx, [rsp+121]
        mov [rbx], al
        ; move t.16, t.17
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+120]
        mov [rax], bl
        ; sub t.16, t.16, pos
        lea rax, [rsp+120]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.13, t.16]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+128]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
@printIntLf@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
@printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; 51:2 if number < 0
        ; lt t.1, number, 0
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end, @if_3_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.2, 45
        mov al, 45
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call printChar@u8[t.2]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+24]
        mov [rax], rbx
@if_3_end:
        ; call printUint@i64[number]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printUint@i64
        add rsp, 8
        ; const t.3, 10
        mov al, 10
        lea rbx, [rsp+2]
        mov [rbx], al
        ; call printChar@u8[t.3]
        lea rax, [rsp+2]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2
@printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+8: var b
        ;   rsp+16: var c
        ;   rsp+24: var d
        ;   rsp+32: var t.4
        ;   rsp+34: var t.5
        ;   rsp+36: var t.6
        ;   rsp+38: var t.7
        ;   rsp+40: var t.8
@main:
        ; reserve space for local variables
        sub rsp, 48
        ; begin initialize global variables
        ; end initialize global variables
        ; const a, 10
        mov ax, 10
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; call printIntLf@i16[a]
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; addrof b, a
        lea rax, [rsp+0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; load t.4, [b]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+32]
        mov [rbx], ax
        ; const t.5, 1
        mov ax, 1
        lea rbx, [rsp+34]
        mov [rbx], ax
        ; move c, t.4
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+16]
        mov [rax], bx
        ; sub c, c, t.5
        lea rax, [rsp+16]
        mov bx, [rax]
        lea rax, [rsp+34]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+16]
        mov [rax], bx
        ; call printIntLf@i16[c]
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; addrof d, c
        lea rax, [rsp+16]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; load t.7, [d]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+38]
        mov [rbx], ax
        ; const t.8, 1
        mov ax, 1
        lea rbx, [rsp+40]
        mov [rbx], ax
        ; move t.6, t.7
        lea rax, [rsp+38]
        mov bx, [rax]
        lea rax, [rsp+36]
        mov [rax], bx
        ; sub t.6, t.6, t.8
        lea rax, [rsp+36]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+36]
        mov [rax], bx
        ; store [d], t.6
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+36]
        mov cx, [rax]
        mov [rbx], cx
        ; call printIntLf@i16[c]
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; release space for local variables
        add rsp, 48
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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
