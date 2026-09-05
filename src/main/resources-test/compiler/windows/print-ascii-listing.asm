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

        ; void printString@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length
@printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length]
        lea rax, [rsp+24]
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

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
@printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@u8[t.1, 1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        mov  rax, 1
        push rax
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
@strlen@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; add length, length, 1
        lea rax, [rsp+0]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+0]
        mov [rax], rbx
        ; add str, str, 1
        lea rax, [rsp+24]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+24]
        mov [rax], rbx
@for_1:
        ; load t.3, [str]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; notequals t.2, t.3, 0
        lea rax, [rsp+9]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2, true, @for_1_body, @for_1_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz @for_1_body
        ; 67:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
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

        ; void printNibble@u8
        ;   rsp+24: arg x
        ;   rsp+0: var t.1
@printNibble@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; and x, x, 15
        lea rax, [rsp+24]
        mov bl, [rax]
        and bl, 15
        lea rax, [rsp+24]
        mov [rax], bl
        ; 5:2 if x > 9
        ; gt t.1, x, 9
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 9
        seta bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_2_end, @if_2_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_2_end
        ; add x, x, 7
        lea rax, [rsp+24]
        mov bl, [rax]
        add bl, 7
        lea rax, [rsp+24]
        mov [rax], bl
@if_2_end:
        ; add x, x, 48
        lea rax, [rsp+24]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+24]
        mov [rax], bl
        ; call printChar@u8[x]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printHex2@u8
        ;   rsp+24: arg x
        ;   rsp+0: var t.1
@printHex2@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; move t.1, x
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; shiftright t.1, t.1, 4
        lea rax, [rsp+0]
        mov bl, [rax]
        shr bl, 4
        lea rax, [rsp+0]
        mov [rax], bl
        ; call printNibble@u8[t.1]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printNibble@u8
        add rsp, 8
        ; call printNibble@u8[x]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printNibble@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
        ;   rsp+18: var t.5
        ;   rsp+19: var t.6
        ;   rsp+20: var t.7
        ;   rsp+21: var t.8
        ;   rsp+22: var t.9
        ;   rsp+23: var t.10
        ;   rsp+24: var t.11
        ;   rsp+25: var t.12
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; const t.2, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.2]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 19:2 for i < 16
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; move t.5, i
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+18]
        mov [rax], bl
        ; and t.5, t.5, 7
        lea rax, [rsp+18]
        mov bl, [rax]
        and bl, 7
        lea rax, [rsp+18]
        mov [rax], bl
        ; equals t.4, t.5, 0
        lea rax, [rsp+18]
        mov bl, [rax]
        cmp bl, 0
        sete bl
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.4, false, @if_4_end, @if_4_then
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        jz @if_4_end
        ; call printChar@u8[32]
        mov  rax, 32
        push rax
          call @printChar@u8
        add rsp, 8
@if_4_end:
        ; call printNibble@u8[i]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printNibble@u8
        add rsp, 8
        ; add i, i, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
@for_3:
        ; lt t.3, i, 16
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 16
        setb bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.3, true, @for_3_body, @for_3_break
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz @for_3_body
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
          call @printChar@u8
        add rsp, 8
        ; const i, 32
        mov al, 32
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; move t.8, i
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
        ; and t.8, t.8, 15
        lea rax, [rsp+21]
        mov bl, [rax]
        and bl, 15
        lea rax, [rsp+21]
        mov [rax], bl
        ; equals t.7, t.8, 0
        lea rax, [rsp+21]
        mov bl, [rax]
        cmp bl, 0
        sete bl
        lea rax, [rsp+20]
        mov [rax], bl
        ; branch t.7, false, @if_6_end, @if_6_then
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jz @if_6_end
        ; call printHex2@u8[i]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printHex2@u8
        add rsp, 8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; move t.10, i
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov [rax], bl
        ; and t.10, t.10, 7
        lea rax, [rsp+23]
        mov bl, [rax]
        and bl, 7
        lea rax, [rsp+23]
        mov [rax], bl
        ; equals t.9, t.10, 0
        lea rax, [rsp+23]
        mov bl, [rax]
        cmp bl, 0
        sete bl
        lea rax, [rsp+22]
        mov [rax], bl
        ; branch t.9, false, @if_7_end, @if_7_then
        lea rax, [rsp+22]
        mov bl, [rax]
        or bl, bl
        jz @if_7_end
        ; call printChar@u8[32]
        mov  rax, 32
        push rax
          call @printChar@u8
        add rsp, 8
@if_7_end:
        ; call printChar@u8[i]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; 35:3 if i & 15 == 15
        ; move t.12, i
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+25]
        mov [rax], bl
        ; and t.12, t.12, 15
        lea rax, [rsp+25]
        mov bl, [rax]
        and bl, 15
        lea rax, [rsp+25]
        mov [rax], bl
        ; equals t.11, t.12, 15
        lea rax, [rsp+25]
        mov bl, [rax]
        cmp bl, 15
        sete bl
        lea rax, [rsp+24]
        mov [rax], bl
        ; branch t.11, false, @for_5_continue, @if_8_then
        lea rax, [rsp+24]
        mov bl, [rax]
        or bl, bl
        jz @for_5_continue
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
          call @printChar@u8
        add rsp, 8
@for_5_continue:
        ; add i, i, 1
        lea rax, [rsp+1]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+1]
        mov [rax], bl
@for_5:
        ; lt t.6, i, 128
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 128
        setb bl
        lea rax, [rsp+19]
        mov [rax], bl
        ; branch t.6, true, @for_5_body, @main_ret
        lea rax, [rsp+19]
        mov bl, [rax]
        or bl, bl
        jnz @for_5_body
        ; release space for local variables
        add rsp, 32
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
