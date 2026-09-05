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

        ; void printBoard
        ;   rsp+0: var i
        ;   rsp+1: var t.1
        ;   rsp+2: var t.2
        ;   rsp+3: var t.3
        ;   rsp+8: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
@printBoard:
        ; reserve space for local variables
        sub rsp, 32
        ; call printChar@u8[124]
        mov  rax, 124
        push rax
          call @printChar@u8
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.5(i64), i(u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; addrof t.4, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.4, t.4, t.5
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; load t.3, [t.4]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+3]
        mov [rbx], al
        ; equals t.2, t.3, 0
        lea rax, [rsp+3]
        mov bl, [rax]
        cmp bl, 0
        sete bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.2, true, @if_3_then, @if_3_else
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jnz @if_3_then
        ; call printChar@u8[42]
        mov  rax, 42
        push rax
          call @printChar@u8
        add rsp, 8
        jmp @for_2_continue
@if_3_then:
        ; call printChar@u8[32]
        mov  rax, 32
        push rax
          call @printChar@u8
        add rsp, 8
@for_2_continue:
        ; add i, i, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
@for_2:
        ; lt t.1, i, 30
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 30
        setb bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.1, true, @for_2_body, @for_2_break
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jnz @for_2_body
        ; const t.6, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.6]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+2: var pattern
        ;   rsp+3: var j
        ;   rsp+4: var t.4
        ;   rsp+5: var t.5
        ;   rsp+8: var t.6
        ;   rsp+16: var t.7
        ;   rsp+24: var t.8
        ;   rsp+32: var t.9
        ;   rsp+40: var t.10
        ;   rsp+48: var t.11
        ;   rsp+49: var t.12
        ;   rsp+50: var t.13
        ;   rsp+56: var t.14
        ;   rsp+64: var t.15
        ;   rsp+72: var t.16
        ;   rsp+80: var t.17
        ;   rsp+88: var t.18
        ;   rsp+96: var t.19
        ;   rsp+97: var t.20
        ;   rsp+98: var t.21
        ;   rsp+99: var t.22
        ;   rsp+104: var t.23
        ;   rsp+112: var t.24
        ;   rsp+120: var t.25
        ;   rsp+121: var t.26
        ;   rsp+122: var t.27
        ;   rsp+123: var t.28
        ;   rsp+128: var t.29
        ;   rsp+136: var t.30
@main:
        ; reserve space for local variables
        sub rsp, 144
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const t.5, 0
        mov al, 0
        lea rbx, [rsp+5]
        mov [rbx], al
        ; cast t.7(i64), i(u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; addrof t.6, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.6, t.6, t.7
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; store [t.6], t.5
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        mov [rbx], cl
        ; add i, i, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
@for_4:
        ; lt t.4, i, 30
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 30
        setb bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4, true, @for_4_body, @for_4_break
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jnz @for_4_body
        ; const t.8, 1
        mov al, 1
        lea rbx, [rsp+24]
        mov [rbx], al
        ; const t.10, 29
        mov rax, 29
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; addrof t.9, [board]
        lea rax, [var_0]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; add t.9, t.9, t.10
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+32]
        mov [rax], rbx
        ; store [t.9], t.8
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        mov [rbx], cl
        ; call printBoard[]
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 30:2 for i < 28
        jmp @for_5
@for_5_body:
        ; const t.15, 0
        mov rax, 0
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; addrof t.14, [board]
        lea rax, [var_0]
        lea rbx, [rsp+56]
        mov [rbx], rax
        ; add t.14, t.14, t.15
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+56]
        mov [rax], rbx
        ; load t.13, [t.14]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+50]
        mov [rbx], al
        ; move t.12, t.13
        lea rax, [rsp+50]
        mov bl, [rax]
        lea rax, [rsp+49]
        mov [rax], bl
        ; shiftleft t.12, t.12, 1
        lea rax, [rsp+49]
        mov bl, [rax]
        shl bl, 1
        lea rax, [rsp+49]
        mov [rax], bl
        ; const t.18, 1
        mov rax, 1
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; addrof t.17, [board]
        lea rax, [var_0]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; add t.17, t.17, t.18
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+80]
        mov [rax], rbx
        ; load t.16, [t.17]
        lea rax, [rsp+80]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+72]
        mov [rbx], al
        ; move pattern, t.12
        lea rax, [rsp+49]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; or pattern, pattern, t.16
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const j, 1
        mov al, 1
        lea rbx, [rsp+3]
        mov [rbx], al
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; move t.21, pattern
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+98]
        mov [rax], bl
        ; shiftleft t.21, t.21, 1
        lea rax, [rsp+98]
        mov bl, [rax]
        shl bl, 1
        lea rax, [rsp+98]
        mov [rax], bl
        ; move t.20, t.21
        lea rax, [rsp+98]
        mov bl, [rax]
        lea rax, [rsp+97]
        mov [rax], bl
        ; and t.20, t.20, 7
        lea rax, [rsp+97]
        mov bl, [rax]
        and bl, 7
        lea rax, [rsp+97]
        mov [rax], bl
        ; move t.25, j
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+120]
        mov [rax], bl
        ; add t.25, t.25, 1
        lea rax, [rsp+120]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+120]
        mov [rax], bl
        ; cast t.24(i64), t.25(u8)
        lea rax, [rsp+120]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; addrof t.23, [board]
        lea rax, [var_0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.23, t.23, t.24
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; load t.22, [t.23]
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+99]
        mov [rbx], al
        ; move pattern, t.20
        lea rax, [rsp+97]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; or pattern, pattern, t.22
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+99]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const t.28, 110
        mov al, 110
        lea rbx, [rsp+123]
        mov [rbx], al
        ; move t.27, t.28
        lea rax, [rsp+123]
        mov bl, [rax]
        lea rax, [rsp+122]
        mov [rax], bl
        ; shiftright t.27, t.27, pattern
        lea rax, [rsp+122]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+122]
        mov [rax], bl
        ; move t.26, t.27
        lea rax, [rsp+122]
        mov bl, [rax]
        lea rax, [rsp+121]
        mov [rax], bl
        ; and t.26, t.26, 1
        lea rax, [rsp+121]
        mov bl, [rax]
        and bl, 1
        lea rax, [rsp+121]
        mov [rax], bl
        ; cast t.30(i64), j(u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+136]
        mov [rax], rbx
        ; addrof t.29, [board]
        lea rax, [var_0]
        lea rbx, [rsp+128]
        mov [rbx], rax
        ; add t.29, t.29, t.30
        lea rax, [rsp+128]
        mov rbx, [rax]
        lea rax, [rsp+136]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+128]
        mov [rax], rbx
        ; store [t.29], t.26
        lea rax, [rsp+128]
        mov rbx, [rax]
        lea rax, [rsp+121]
        mov cl, [rax]
        mov [rbx], cl
        ; add j, j, 1
        lea rax, [rsp+3]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+3]
        mov [rax], bl
@for_6:
        ; lt t.19, j, 29
        lea rax, [rsp+3]
        mov bl, [rax]
        cmp bl, 29
        setb bl
        lea rax, [rsp+96]
        mov [rax], bl
        ; branch t.19, true, @for_6_body, @for_6_break
        lea rax, [rsp+96]
        mov bl, [rax]
        or bl, bl
        jnz @for_6_body
        ; call printBoard[]
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; add i, i, 1
        lea rax, [rsp+1]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+1]
        mov [rax], bl
@for_5:
        ; lt t.11, i, 28
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 28
        setb bl
        lea rax, [rsp+48]
        mov [rax], bl
        ; branch t.11, true, @for_5_body, @main_ret
        lea rax, [rsp+48]
        mov bl, [rax]
        or bl, bl
        jnz @for_5_body
        ; release space for local variables
        add rsp, 144
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
        ; variable 0: board[] (u8*/240)
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
