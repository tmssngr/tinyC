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
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2, 1
        mov rax, 1
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printStringLength [t.1, t.2]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
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
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; const t.5, 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; sub pos, pos, t.5
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.6, 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; move remainder, number
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, t.6
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
        ; const t.7, 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number, number, t.7
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+152]
        mov [rdx], rbx
        ; cast t.8(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; move digit, t.8
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, t.9
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.11(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.12(u8*), t.11(i64)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.10, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.10, t.10, t.12
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.10], digit
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; const t.14, 0
        mov rax, 0
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; equals t.13, number, t.14
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.13, false, @while_1
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.16(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; cast t.17(u8*), t.16(i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.15, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.15, t.15, t.17
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.20, 20
        mov al, 20
        lea rbx, [rsp+137]
        mov [rbx], al
        ; move t.19, t.20
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+136]
        mov [rax], bl
        ; sub t.19, t.19, pos
        lea rax, [rsp+136]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.18(i64), t.19(u8)
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printStringLength [t.15, t.18]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+136]
        mov rbx, [rax]
        push rbx
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
        ; const t.2, 0
        mov rax, 0
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; lt t.1, number, t.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        cmp rbx, rcx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.3, 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call _, printChar [t.3]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.4, 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call _, printChar [t.4]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var foo
        ;   rsp+2: var bar
        ;   rsp+4: var bazz
        ;   rsp+6: var a
        ;   rsp+8: var b
        ;   rsp+10: var t.5
        ;   rsp+16: var t.6
        ;   rsp+24: var t.7
        ;   rsp+26: var t.8
        ;   rsp+32: var t.9
        ;   rsp+40: var t.10
        ;   rsp+48: var t.11
        ;   rsp+56: var t.12
        ;   rsp+64: var t.13
        ;   rsp+72: var t.14
        ;   rsp+74: var t.15
        ;   rsp+80: var t.16
        ;   rsp+88: var t.17
        ;   rsp+96: var t.18
        ;   rsp+104: var t.19
        ;   rsp+112: var t.20
        ;   rsp+120: var t.21
@main:
        ; reserve space for local variables
        sub rsp, 128
        ; const t.5, 22
        mov al, 22
        lea rbx, [rsp+10]
        mov [rbx], al
        ; cast foo(i16), t.5(u8)
        lea rax, [rsp+10]
        mov bl, [rax]
        movzx bx, bl
        lea rax, [rsp+0]
        mov [rax], bx
        ; move bar, foo
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mul bar, bar, foo
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        movsx rbx, bx
        movsx rcx, cx
        imul  rbx, rcx
        lea rax, [rsp+2]
        mov [rax], bx
        ; const foo, 1
        mov ax, 1
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; move t.7, bar
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; add t.7, t.7, foo
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+24]
        mov [rax], bx
        ; cast t.6(i64), t.7(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+16]
        mov [rax], rbx
        ; call _, printIntLf [t.6]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.8, 21
        mov al, 21
        lea rbx, [rsp+26]
        mov [rbx], al
        ; cast foo(i16), t.8(u8)
        lea rax, [rsp+26]
        mov bl, [rax]
        movzx bx, bl
        lea rax, [rsp+0]
        mov [rax], bx
        ; cast t.9(i64), foo(i16)
        lea rax, [rsp+0]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+32]
        mov [rax], rbx
        ; call _, printIntLf [t.9]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; cast t.10(i64), bazz(i16)
        lea rax, [rsp+4]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; call _, printIntLf [t.10]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const a, 1000
        mov ax, 1000
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; const b, 10
        mov ax, 10
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; move t.12, a
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov [rax], bx
        ; div t.12, t.12, b
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+56]
        mov [rdx], bx
        ; cast t.11(i64), t.12(i16)
        lea rax, [rsp+56]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+48]
        mov [rax], rbx
        ; call _, printIntLf [t.11]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.15, 255
        mov ax, 255
        lea rbx, [rsp+74]
        mov [rbx], ax
        ; move t.14, a
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+72]
        mov [rax], bx
        ; and t.14, t.14, t.15
        lea rax, [rsp+72]
        mov bx, [rax]
        lea rax, [rsp+74]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+72]
        mov [rax], bx
        ; cast t.13(i64), t.14(i16)
        lea rax, [rsp+72]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; call _, printIntLf [t.13]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const a, 10
        mov ax, 10
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; const b, 1
        mov ax, 1
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; move t.17, a
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+88]
        mov [rax], bx
        ; shiftright t.17, t.17, b
        lea rax, [rsp+88]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        sar bx, cl
        lea rax, [rsp+88]
        mov [rax], bx
        ; cast t.16(i64), t.17(i16)
        lea rax, [rsp+88]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+80]
        mov [rax], rbx
        ; call _, printIntLf [t.16]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const a, 9
        mov ax, 9
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; const b, 2
        mov ax, 2
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; move t.19, a
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+104]
        mov [rax], bx
        ; shiftright t.19, t.19, b
        lea rax, [rsp+104]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        sar bx, cl
        lea rax, [rsp+104]
        mov [rax], bx
        ; cast t.18(i64), t.19(i16)
        lea rax, [rsp+104]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+96]
        mov [rax], rbx
        ; call _, printIntLf [t.18]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const a, 1
        mov ax, 1
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; move t.21, a
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+120]
        mov [rax], bx
        ; shiftleft t.21, t.21, b
        lea rax, [rsp+120]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        sal bx, cl
        lea rax, [rsp+120]
        mov [rax], bx
        ; cast t.20(i64), t.21(i16)
        lea rax, [rsp+120]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+112]
        mov [rax], rbx
        ; call _, printIntLf [t.20]
        lea rax, [rsp+112]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 128
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