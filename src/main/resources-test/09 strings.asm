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
@printString:
        ; reserve space for local variables
        sub rsp, 16
        ; call length(1@function,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @strlen
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call _, printStringLength [str(0@argument,u8*), length(1@function,i64)]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; @printString_ret:
@printString_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar
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
        ; @printChar_ret:
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
@printUint:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos(2@function,u8), 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
        ; @while_1:
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
        ; @if_2_end:
@if_2_end:
        ; jump @while_1
        jmp @while_1
        ; @while_1_break:
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
        ; @printUint_ret:
@printUint_ret:
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf
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
        ; @if_3_end:
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
        ; @printIntLf_ret:
@printIntLf_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; i64 strlen
@strlen:
        ; reserve space for local variables
        sub rsp, 48
        ; const length(1@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 37:2 for *str != 0
        ; @for_4:
@for_4:
        ; load t.3(3@function,u8), [str(0@argument,u8*)]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; const t.4(4@function,u8), 0
        mov al, 0
        lea rbx, [rsp+10]
        mov [rbx], al
        ; notequals t.2(2@function,bool), t.3(3@function,u8), t.4(4@function,u8)
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2(2@function,bool), false, @for_4_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @for_4_break
        ; @for_4_body
        ; const t.5(5@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; add length(1@function,i64), length(1@function,i64), t.5(5@function,i64)
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; @for_4_continue:
@for_4_continue:
        ; cast t.7(7@function,i64), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8(8@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6(6@function,u8*), t.7(7@function,i64), t.8(8@function,i64)
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast str(0@argument,u8*), t.6(6@function,u8*)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; jump @for_4
        jmp @for_4
        ; @for_4_break:
@for_4_break:
        ; 40:9 return length
        ; ret length(1@function,i64)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; jump @strlen_ret
        jmp @strlen_ret
        ; @strlen_ret:
@strlen_ret:
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
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; const text(0@global,u8*), [string-0]
        lea rax, [string_0]
        lea rbx, [var_0]
        mov [rbx], rax
        ; end initialize global variables
        ; call _, printString [text(0@global,u8*)]
        lea rax, [var_0]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; call _, printLength []
        sub rsp, 8
          call @printLength
        add rsp, 8
        ; const t.2(2@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; addrof second(0@function,u8*), [text(0@global,u8*) + t.2(2@function,i64)]
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [var_0]
        mov rax, [rax]
        add rax, rbx
        lea rcx, [rsp+0]
        mov [rcx], rax
        ; call _, printString [second(0@function,u8*)]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; load chr(1@function,u8), [text(0@global,u8*)]
        lea rax, [var_0]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+8]
        mov [rbx], al
        ; cast t.3(3@function,i64), chr(1@function,u8)
        lea rax, [rsp+8]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+24]
        mov [rax], rbx
        ; call _, printIntLf [t.3(3@function,i64)]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; @main_ret:
@main_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void printLength
@printLength:
        ; reserve space for local variables
        sub rsp, 64
        ; const length(0@function,i16), 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; copy ptr(1@function,u8*), text(0@global,u8*)
        lea rax, [var_0]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; 16:2 for *ptr != 0
        ; @for_5:
@for_5:
        ; load t.3(3@function,u8), [ptr(1@function,u8*)]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+17]
        mov [rbx], al
        ; const t.4(4@function,u8), 0
        mov al, 0
        lea rbx, [rsp+18]
        mov [rbx], al
        ; notequals t.2(2@function,bool), t.3(3@function,u8), t.4(4@function,u8)
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.2(2@function,bool), false, @for_5_break
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz @for_5_break
        ; @for_5_body
        ; const t.5(5@function,i16), 1
        mov ax, 1
        lea rbx, [rsp+20]
        mov [rbx], ax
        ; add length(0@function,i16), length(0@function,i16), t.5(5@function,i16)
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+0]
        mov [rax], bx
        ; @for_5_continue:
@for_5_continue:
        ; cast t.7(7@function,i64), ptr(1@function,u8*)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8(8@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6(6@function,u8*), t.7(7@function,i64), t.8(8@function,i64)
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast ptr(1@function,u8*), t.6(6@function,u8*)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; jump @for_5
        jmp @for_5
        ; @for_5_break:
@for_5_break:
        ; cast t.9(9@function,i64), length(0@function,i16)
        lea rax, [rsp+0]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+48]
        mov [rax], rbx
        ; call _, printIntLf [t.9(9@function,i64)]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; @printLength_ret:
@printLength_ret:
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
