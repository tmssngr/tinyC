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
@printChar_ret:
        ; release space for local variables
        add rsp, 16
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
@for_1:
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
        ; branch t.2(2@function,bool), false, @for_1_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @for_1_break
        ; @for_1_body
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
@for_1_continue:
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
        ; jump @for_1
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; ret length(1@function,i64)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; jump @strlen_ret
        jmp @strlen_ret
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

        ; void printNibble
@printNibble:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.1(1@function,u8), 15
        mov al, 15
        lea rbx, [rsp+0]
        mov [rbx], al
        ; and x(0@argument,u8), x(0@argument,u8), t.1(1@function,u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+24]
        mov [rax], bl
        ; 5:2 if x > 9
        ; const t.3(3@function,u8), 9
        mov al, 9
        lea rbx, [rsp+2]
        mov [rbx], al
        ; gt t.2(2@function,bool), x(0@argument,u8), t.3(3@function,u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.2(2@function,bool), false, @if_2_end
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jz @if_2_end
        ; @if_2_then
        ; const t.6(6@function,u8), 65
        mov al, 65
        lea rbx, [rsp+5]
        mov [rbx], al
        ; const t.7(7@function,u8), 57
        mov al, 57
        lea rbx, [rsp+6]
        mov [rbx], al
        ; sub t.5(5@function,u8), t.6(6@function,u8), t.7(7@function,u8)
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+6]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+4]
        mov [rax], bl
        ; const t.8(8@function,u8), 1
        mov al, 1
        lea rbx, [rsp+7]
        mov [rbx], al
        ; sub t.4(4@function,u8), t.5(5@function,u8), t.8(8@function,u8)
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+7]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+3]
        mov [rax], bl
        ; add x(0@argument,u8), x(0@argument,u8), t.4(4@function,u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+24]
        mov [rax], bl
@if_2_end:
        ; const t.9(9@function,u8), 48
        mov al, 48
        lea rbx, [rsp+8]
        mov [rbx], al
        ; add x(0@argument,u8), x(0@argument,u8), t.9(9@function,u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+8]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+24]
        mov [rax], bl
        ; call _, printChar [x(0@argument,u8)]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@printNibble_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printHex2
@printHex2:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.2(2@function,u8), 16
        mov al, 16
        lea rbx, [rsp+1]
        mov [rbx], al
        ; div t.1(1@function,u8), x(0@argument,u8), t.2(2@function,u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov cl, [rax]
        movzx rax, bl
        movzx rcx, cl
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+0]
        mov [rdx], bl
        ; call _, printNibble [t.1(1@function,u8)]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printNibble
        add rsp, 8
        ; call _, printNibble [x(0@argument,u8)]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printNibble
        add rsp, 8
@printHex2_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.2(2@function,u8*), [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printString [t.2(2@function,u8*)]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const i(0@function,u8), 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 19:2 for i < 16
@for_3:
        ; const t.4(4@function,u8), 16
        mov al, 16
        lea rbx, [rsp+17]
        mov [rbx], al
        ; lt t.3(3@function,bool), i(0@function,u8), t.4(4@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.3(3@function,bool), false, @for_3_break
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz @for_3_break
        ; @for_3_body
        ; 20:3 if i & 7 == 0
        ; const t.7(7@function,u8), 7
        mov al, 7
        lea rbx, [rsp+20]
        mov [rbx], al
        ; and t.6(6@function,u8), i(0@function,u8), t.7(7@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+19]
        mov [rax], bl
        ; const t.8(8@function,u8), 0
        mov al, 0
        lea rbx, [rsp+21]
        mov [rbx], al
        ; equals t.5(5@function,bool), t.6(6@function,u8), t.8(8@function,u8)
        lea rax, [rsp+19]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+18]
        mov [rax], bl
        ; branch t.5(5@function,bool), false, @if_4_end
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jz @if_4_end
        ; @if_4_then
        ; const t.9(9@function,u8), 32
        mov al, 32
        lea rbx, [rsp+22]
        mov [rbx], al
        ; call _, printChar [t.9(9@function,u8)]
        lea rax, [rsp+22]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_4_end:
        ; call _, printNibble [i(0@function,u8)]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printNibble
        add rsp, 8
@for_3_continue:
        ; const t.10(10@function,u8), 1
        mov al, 1
        lea rbx, [rsp+23]
        mov [rbx], al
        ; add i(0@function,u8), i(0@function,u8), t.10(10@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; jump @for_3
        jmp @for_3
@for_3_break:
        ; const t.11(11@function,u8), 10
        mov al, 10
        lea rbx, [rsp+24]
        mov [rbx], al
        ; call _, printChar [t.11(11@function,u8)]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; const i(1@function,u8), 32
        mov al, 32
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 27:2 for i < 128
@for_5:
        ; const t.13(13@function,u8), 128
        mov al, 128
        lea rbx, [rsp+26]
        mov [rbx], al
        ; lt t.12(12@function,bool), i(1@function,u8), t.13(13@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+26]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+25]
        mov [rax], bl
        ; branch t.12(12@function,bool), false, @for_5_break
        lea rax, [rsp+25]
        mov bl, [rax]
        or bl, bl
        jz @for_5_break
        ; @for_5_body
        ; 28:3 if i & 15 == 0
        ; const t.16(16@function,u8), 15
        mov al, 15
        lea rbx, [rsp+29]
        mov [rbx], al
        ; and t.15(15@function,u8), i(1@function,u8), t.16(16@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+29]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+28]
        mov [rax], bl
        ; const t.17(17@function,u8), 0
        mov al, 0
        lea rbx, [rsp+30]
        mov [rbx], al
        ; equals t.14(14@function,bool), t.15(15@function,u8), t.17(17@function,u8)
        lea rax, [rsp+28]
        mov bl, [rax]
        lea rax, [rsp+30]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+27]
        mov [rax], bl
        ; branch t.14(14@function,bool), false, @if_6_end
        lea rax, [rsp+27]
        mov bl, [rax]
        or bl, bl
        jz @if_6_end
        ; @if_6_then
        ; call _, printHex2 [i(1@function,u8)]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printHex2
        add rsp, 8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const t.20(20@function,u8), 7
        mov al, 7
        lea rbx, [rsp+33]
        mov [rbx], al
        ; and t.19(19@function,u8), i(1@function,u8), t.20(20@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; const t.21(21@function,u8), 0
        mov al, 0
        lea rbx, [rsp+34]
        mov [rbx], al
        ; equals t.18(18@function,bool), t.19(19@function,u8), t.21(21@function,u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+34]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+31]
        mov [rax], bl
        ; branch t.18(18@function,bool), false, @if_7_end
        lea rax, [rsp+31]
        mov bl, [rax]
        or bl, bl
        jz @if_7_end
        ; @if_7_then
        ; const t.22(22@function,u8), 32
        mov al, 32
        lea rbx, [rsp+35]
        mov [rbx], al
        ; call _, printChar [t.22(22@function,u8)]
        lea rax, [rsp+35]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_7_end:
        ; call _, printChar [i(1@function,u8)]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; 35:3 if i & 15 == 15
        ; const t.25(25@function,u8), 15
        mov al, 15
        lea rbx, [rsp+38]
        mov [rbx], al
        ; and t.24(24@function,u8), i(1@function,u8), t.25(25@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+38]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+37]
        mov [rax], bl
        ; const t.26(26@function,u8), 15
        mov al, 15
        lea rbx, [rsp+39]
        mov [rbx], al
        ; equals t.23(23@function,bool), t.24(24@function,u8), t.26(26@function,u8)
        lea rax, [rsp+37]
        mov bl, [rax]
        lea rax, [rsp+39]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+36]
        mov [rax], bl
        ; branch t.23(23@function,bool), false, @if_8_end
        lea rax, [rsp+36]
        mov bl, [rax]
        or bl, bl
        jz @if_8_end
        ; @if_8_then
        ; const t.27(27@function,u8), 10
        mov al, 10
        lea rbx, [rsp+40]
        mov [rbx], al
        ; call _, printChar [t.27(27@function,u8)]
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_8_end:
@for_5_continue:
        ; const t.28(28@function,u8), 1
        mov al, 1
        lea rbx, [rsp+41]
        mov [rbx], al
        ; add i(1@function,u8), i(1@function,u8), t.28(28@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+41]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        ; jump @for_5
        jmp @for_5
@for_5_break:
@main_ret:
        ; release space for local variables
        add rsp, 48
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

section '.data' data readable
        string_0 db ' x', 0x00

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
