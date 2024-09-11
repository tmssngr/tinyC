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
        ; addrof t.1(1@function,u8*), chr(0@argument,u8)
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2(2@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printStringLength [t.1(1@function,u8*), t.2(2@function,i64)]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
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
        ; const pos(2@function,u8), 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; const t.5(5@function,u8), 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; sub pos(2@function,u8), pos(2@function,u8), t.5(5@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.6(6@function,i64), 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; mod remainder(3@function,i64), number(0@argument,i64), t.6(6@function,i64)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.7(7@function,i64), 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number(0@argument,i64), number(0@argument,i64), t.7(7@function,i64)
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
        ; cast t.8(8@function,u8), remainder(3@function,i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9(9@function,u8), 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; add digit(4@function,u8), t.8(8@function,u8), t.9(9@function,u8)
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.10(10@function,i64), pos(2@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+64]
        mov [rax], rbx
        ; array t.11(11@function,u8*), buffer(1@function,u8*) + t.10(10@function,i64)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+0]
        add rax, rbx
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; store [t.11(11@function,u8*)], digit(4@function,u8)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; const t.13(13@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; equals t.12(12@function,bool), number(0@argument,i64), t.13(13@function,i64)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+80]
        mov [rax], bl
        ; branch t.12(12@function,bool), false, @if_2_end
        lea rax, [rsp+80]
        mov bl, [rax]
        or bl, bl
        jz @if_2_end
        ; @if_2_then
        ; jump @while_1_break
        jmp @while_1_break
@if_2_end:
        ; jump @while_1
        jmp @while_1
@while_1_break:
        ; cast t.15(15@function,i64), pos(2@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+104]
        mov [rax], rbx
        ; addrof t.14(14@function,u8*), [buffer(1@function,u8*) + t.15(15@function,i64)]
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+0]
        add rax, rbx
        lea rcx, [rsp+96]
        mov [rcx], rax
        ; const t.18(18@function,u8), 20
        mov al, 20
        lea rbx, [rsp+121]
        mov [rbx], al
        ; sub t.17(17@function,u8), t.18(18@function,u8), pos(2@function,u8)
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; cast t.16(16@function,i64), t.17(17@function,u8)
        lea rax, [rsp+120]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; call _, printStringLength [t.14(14@function,u8*), t.16(16@function,i64)]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+120]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printUint_ret:
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
        ; const t.2(2@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; lt t.1(1@function,bool), number(0@argument,i64), t.2(2@function,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        cmp rbx, rcx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1(1@function,bool), false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; @if_3_then
        ; const t.3(3@function,u8), 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call _, printChar [t.3(3@function,u8)]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; neg number(0@argument,i64), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.4(4@function,u8), 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call _, printChar [t.4(4@function,u8)]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@printIntLf_ret:
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
        ;   rsp+8: var t.1
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; const a(0@function,u8), 10
        mov al, 10
        lea rbx, [rsp+0]
        mov [rbx], al
        ; cast t.1(1@function,i64), a(0@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+8]
        mov [rax], rbx
        ; call _, printIntLf [t.1(1@function,i64)]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
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
