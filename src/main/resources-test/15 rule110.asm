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

        ; void printBoard
@printBoard:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.1(1@function,u8), 124
        mov al, 124
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call _, printChar [t.1(1@function,u8)]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; const i(0@function,u8), 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 11:2 for i < 30
@for_2:
        ; const t.3(3@function,u8), 30
        mov al, 30
        lea rbx, [rsp+3]
        mov [rbx], al
        ; lt t.2(2@function,bool), i(0@function,u8), t.3(3@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.2(2@function,bool), false, @for_2_break
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jz @for_2_break
        ; @for_2_body
        ; 12:3 if [...] == 0
        ; cast t.6(6@function,i64), i(0@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+8]
        mov [rax], rbx
        ; array t.7(7@function,u8*), board(0@global,u8*) + t.6(6@function,i64)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; load t.5(5@function,u8), [t.7(7@function,u8*)]
        lea rax, [rsp+16]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+5]
        mov [rbx], al
        ; const t.8(8@function,u8), 0
        mov al, 0
        lea rbx, [rsp+24]
        mov [rbx], al
        ; equals t.4(4@function,bool), t.5(5@function,u8), t.8(8@function,u8)
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4(4@function,bool), false, @if_3_else
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @if_3_else
        ; @if_3_then
        ; const t.9(9@function,u8), 32
        mov al, 32
        lea rbx, [rsp+25]
        mov [rbx], al
        ; call _, printChar [t.9(9@function,u8)]
        lea rax, [rsp+25]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; jump @if_3_end
        jmp @if_3_end
@if_3_else:
        ; const t.10(10@function,u8), 42
        mov al, 42
        lea rbx, [rsp+26]
        mov [rbx], al
        ; call _, printChar [t.10(10@function,u8)]
        lea rax, [rsp+26]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_3_end:
@for_2_continue:
        ; const t.11(11@function,u8), 1
        mov al, 1
        lea rbx, [rsp+27]
        mov [rbx], al
        ; add i(0@function,u8), i(0@function,u8), t.11(11@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+27]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; jump @for_2
        jmp @for_2
@for_2_break:
        ; const t.12(12@function,u8*), [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call _, printString [t.12(12@function,u8*)]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
@printBoard_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 176
        ; const i(0@function,u8), 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 23:2 for i < 30
@for_4:
        ; const t.5(5@function,u8), 30
        mov al, 30
        lea rbx, [rsp+5]
        mov [rbx], al
        ; lt t.4(4@function,bool), i(0@function,u8), t.5(5@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4(4@function,bool), false, @for_4_break
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @for_4_break
        ; @for_4_body
        ; const t.6(6@function,u8), 0
        mov al, 0
        lea rbx, [rsp+6]
        mov [rbx], al
        ; cast t.7(7@function,i64), i(0@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+8]
        mov [rax], rbx
        ; array t.8(8@function,u8*), board(0@global,u8*) + t.7(7@function,i64)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; store [t.8(8@function,u8*)], t.6(6@function,u8)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+6]
        mov cl, [rax]
        mov [rbx], cl
@for_4_continue:
        ; const t.9(9@function,u8), 1
        mov al, 1
        lea rbx, [rsp+24]
        mov [rbx], al
        ; add i(0@function,u8), i(0@function,u8), t.9(9@function,u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; jump @for_4
        jmp @for_4
@for_4_break:
        ; const t.10(10@function,u8), 1
        mov al, 1
        lea rbx, [rsp+25]
        mov [rbx], al
        ; const t.13(13@function,u8), 30
        mov al, 30
        lea rbx, [rsp+41]
        mov [rbx], al
        ; const t.14(14@function,u8), 1
        mov al, 1
        lea rbx, [rsp+42]
        mov [rbx], al
        ; sub t.12(12@function,u8), t.13(13@function,u8), t.14(14@function,u8)
        lea rax, [rsp+41]
        mov bl, [rax]
        lea rax, [rsp+42]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+40]
        mov [rax], bl
        ; cast t.11(11@function,i64), t.12(12@function,u8)
        lea rax, [rsp+40]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+32]
        mov [rax], rbx
        ; array t.15(15@function,u8*), board(0@global,u8*) + t.11(11@function,i64)
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; store [t.15(15@function,u8*)], t.10(10@function,u8)
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+25]
        mov cl, [rax]
        mov [rbx], cl
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const i(1@function,u8), 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 30:2 for i < 30 - 2
@for_5:
        ; const t.18(18@function,u8), 30
        mov al, 30
        lea rbx, [rsp+58]
        mov [rbx], al
        ; const t.19(19@function,u8), 2
        mov al, 2
        lea rbx, [rsp+59]
        mov [rbx], al
        ; sub t.17(17@function,u8), t.18(18@function,u8), t.19(19@function,u8)
        lea rax, [rsp+58]
        mov bl, [rax]
        lea rax, [rsp+59]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+57]
        mov [rax], bl
        ; lt t.16(16@function,bool), i(1@function,u8), t.17(17@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; branch t.16(16@function,bool), false, @for_5_break
        lea rax, [rsp+56]
        mov bl, [rax]
        or bl, bl
        jz @for_5_break
        ; @for_5_body
        ; const t.22(22@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; array t.23(23@function,u8*), board(0@global,u8*) + t.22(22@function,i64)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; load t.21(21@function,u8), [t.23(23@function,u8*)]
        lea rax, [rsp+72]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+61]
        mov [rbx], al
        ; const t.24(24@function,u8), 1
        mov al, 1
        lea rbx, [rsp+80]
        mov [rbx], al
        ; shiftleft t.20(20@function,u8), t.21(21@function,u8), t.24(24@function,u8)
        lea rax, [rsp+61]
        mov bl, [rax]
        lea rax, [rsp+80]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+60]
        mov [rax], bl
        ; const t.26(26@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; array t.27(27@function,u8*), board(0@global,u8*) + t.26(26@function,i64)
        lea rax, [rsp+88]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; load t.25(25@function,u8), [t.27(27@function,u8*)]
        lea rax, [rsp+96]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+81]
        mov [rbx], al
        ; or pattern(2@function,u8), t.20(20@function,u8), t.25(25@function,u8)
        lea rax, [rsp+60]
        mov bl, [rax]
        lea rax, [rsp+81]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const j(3@function,u8), 1
        mov al, 1
        lea rbx, [rsp+3]
        mov [rbx], al
        ; 32:3 for j < 30 - 1
@for_6:
        ; const t.30(30@function,u8), 30
        mov al, 30
        lea rbx, [rsp+106]
        mov [rbx], al
        ; const t.31(31@function,u8), 1
        mov al, 1
        lea rbx, [rsp+107]
        mov [rbx], al
        ; sub t.29(29@function,u8), t.30(30@function,u8), t.31(31@function,u8)
        lea rax, [rsp+106]
        mov bl, [rax]
        lea rax, [rsp+107]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+105]
        mov [rax], bl
        ; lt t.28(28@function,bool), j(3@function,u8), t.29(29@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+105]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+104]
        mov [rax], bl
        ; branch t.28(28@function,bool), false, @for_6_break
        lea rax, [rsp+104]
        mov bl, [rax]
        or bl, bl
        jz @for_6_break
        ; @for_6_body
        ; const t.34(34@function,u8), 1
        mov al, 1
        lea rbx, [rsp+110]
        mov [rbx], al
        ; shiftleft t.33(33@function,u8), pattern(2@function,u8), t.34(34@function,u8)
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+110]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+109]
        mov [rax], bl
        ; const t.35(35@function,u8), 7
        mov al, 7
        lea rbx, [rsp+111]
        mov [rbx], al
        ; and t.32(32@function,u8), t.33(33@function,u8), t.35(35@function,u8)
        lea rax, [rsp+109]
        mov bl, [rax]
        lea rax, [rsp+111]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+108]
        mov [rax], bl
        ; const t.39(39@function,u8), 1
        mov al, 1
        lea rbx, [rsp+129]
        mov [rbx], al
        ; add t.38(38@function,u8), j(3@function,u8), t.39(39@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+129]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+128]
        mov [rax], bl
        ; cast t.37(37@function,i64), t.38(38@function,u8)
        lea rax, [rsp+128]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+120]
        mov [rax], rbx
        ; array t.40(40@function,u8*), board(0@global,u8*) + t.37(37@function,i64)
        lea rax, [rsp+120]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+136]
        mov [rbx], rax
        ; load t.36(36@function,u8), [t.40(40@function,u8*)]
        lea rax, [rsp+136]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+112]
        mov [rbx], al
        ; or pattern(2@function,u8), t.32(32@function,u8), t.36(36@function,u8)
        lea rax, [rsp+108]
        mov bl, [rax]
        lea rax, [rsp+112]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const t.43(43@function,u8), 110
        mov al, 110
        lea rbx, [rsp+146]
        mov [rbx], al
        ; shiftright t.42(42@function,u8), t.43(43@function,u8), pattern(2@function,u8)
        lea rax, [rsp+146]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+145]
        mov [rax], bl
        ; const t.44(44@function,u8), 1
        mov al, 1
        lea rbx, [rsp+147]
        mov [rbx], al
        ; and t.41(41@function,u8), t.42(42@function,u8), t.44(44@function,u8)
        lea rax, [rsp+145]
        mov bl, [rax]
        lea rax, [rsp+147]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+144]
        mov [rax], bl
        ; cast t.45(45@function,i64), j(3@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+152]
        mov [rax], rbx
        ; array t.46(46@function,u8*), board(0@global,u8*) + t.45(45@function,i64)
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [var_0]
        add rax, rbx
        lea rbx, [rsp+160]
        mov [rbx], rax
        ; store [t.46(46@function,u8*)], t.41(41@function,u8)
        lea rax, [rsp+160]
        mov rbx, [rax]
        lea rax, [rsp+144]
        mov cl, [rax]
        mov [rbx], cl
@for_6_continue:
        ; const t.47(47@function,u8), 1
        mov al, 1
        lea rbx, [rsp+168]
        mov [rbx], al
        ; add j(3@function,u8), j(3@function,u8), t.47(47@function,u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+168]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+3]
        mov [rax], bl
        ; jump @for_6
        jmp @for_6
@for_6_break:
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
@for_5_continue:
        ; const t.48(48@function,u8), 1
        mov al, 1
        lea rbx, [rsp+169]
        mov [rbx], al
        ; add i(1@function,u8), i(1@function,u8), t.48(48@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+169]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        ; jump @for_5
        jmp @for_5
@for_5_break:
@main_ret:
        ; release space for local variables
        add rsp, 176
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
        ; variable 0: board (240)
        var_0 rb 240

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

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
