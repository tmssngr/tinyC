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

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+16: var t.4
        ;   rsp+24: var t.5
        ;   rsp+32: var t.6
@strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 61:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; inc length
        lea rax, [rsp+0]
        mov rbx, [rax]
        inc rbx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; cast t.5(i64), str(u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; const t.6, 1
        mov rax, 1
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; move t.4, t.5
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        ; add t.4, t.4, t.6
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast str(u8*), t.4(i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
@for_1:
        ; load t.3, [str]
        lea rax, [rsp+56]
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
        ; 64:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
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
        ;   rsp+4: var t.4
        ;   rsp+8: var t.5
        ;   rsp+16: var t.6
        ;   rsp+24: var t.7
        ;   rsp+32: var t.8
        ;   rsp+33: var t.9
        ;   rsp+40: var t.10
@printBoard:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.1, 124
        mov al, 124
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call printChar@u8[t.1]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
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
        ; cast t.6(i64), i(u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast t.7(u8*), t.6(i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; addrof t.5, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.5, t.5, t.7
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; load t.4, [t.5]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+4]
        mov [rbx], al
        ; equals t.3, t.4, 0
        lea rax, [rsp+4]
        mov bl, [rax]
        cmp bl, 0
        sete bl
        lea rax, [rsp+3]
        mov [rax], bl
        ; branch t.3, true, @if_3_then, @if_3_else
        lea rax, [rsp+3]
        mov bl, [rax]
        or bl, bl
        jnz @if_3_then
        ; const t.9, 42
        mov al, 42
        lea rbx, [rsp+33]
        mov [rbx], al
        ; call printChar@u8[t.9]
        lea rax, [rsp+33]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        jmp @for_2_continue
@if_3_then:
        ; const t.8, 32
        mov al, 32
        lea rbx, [rsp+32]
        mov [rbx], al
        ; call printChar@u8[t.8]
        lea rax, [rsp+32]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
@for_2_continue:
        ; inc i
        lea rax, [rsp+0]
        mov bl, [rax]
        inc bl
        lea rax, [rsp+0]
        mov [rax], bl
@for_2:
        ; lt t.2, i, 30
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 30
        setb bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.2, true, @for_2_body, @for_2_break
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jnz @for_2_body
        ; const t.10, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; call printString@@u8[t.10]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 48
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
        ;   rsp+56: var t.12
        ;   rsp+64: var t.13
        ;   rsp+65: var t.14
        ;   rsp+66: var t.15
        ;   rsp+72: var t.16
        ;   rsp+80: var t.17
        ;   rsp+88: var t.18
        ;   rsp+96: var t.19
        ;   rsp+97: var t.20
        ;   rsp+104: var t.21
        ;   rsp+112: var t.22
        ;   rsp+120: var t.23
        ;   rsp+128: var t.24
        ;   rsp+129: var t.25
        ;   rsp+130: var t.26
        ;   rsp+131: var t.27
        ;   rsp+132: var t.28
        ;   rsp+133: var t.29
        ;   rsp+136: var t.30
        ;   rsp+144: var t.31
        ;   rsp+152: var t.32
        ;   rsp+153: var t.33
        ;   rsp+160: var t.34
        ;   rsp+168: var t.35
        ;   rsp+169: var t.36
        ;   rsp+170: var t.37
        ;   rsp+171: var t.38
        ;   rsp+176: var t.39
        ;   rsp+184: var t.40
        ;   rsp+192: var t.41
@main:
        ; reserve space for local variables
        sub rsp, 208
        ; begin initialize global variables
        ; end initialize global variables
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
        ; cast t.8(u8*), t.7(i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; addrof t.6, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.6, t.6, t.8
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+24]
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
        ; inc i
        lea rax, [rsp+0]
        mov bl, [rax]
        inc bl
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
        ; const t.9, 1
        mov al, 1
        lea rbx, [rsp+32]
        mov [rbx], al
        ; const t.11, 29
        mov rax, 29
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; cast t.12(u8*), t.11(i64)
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; addrof t.10, [board]
        lea rax, [var_0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.10, t.10, t.12
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; store [t.10], t.9
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+32]
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
        ; const t.17, 0
        mov rax, 0
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; cast t.18(u8*), t.17(i64)
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov [rax], rbx
        ; addrof t.16, [board]
        lea rax, [var_0]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; add t.16, t.16, t.18
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+72]
        mov [rax], rbx
        ; load t.15, [t.16]
        lea rax, [rsp+72]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+66]
        mov [rbx], al
        ; const t.19, 1
        mov al, 1
        lea rbx, [rsp+96]
        mov [rbx], al
        ; move t.14, t.15
        lea rax, [rsp+66]
        mov bl, [rax]
        lea rax, [rsp+65]
        mov [rax], bl
        ; shiftleft t.14, t.14, t.19
        lea rax, [rsp+65]
        mov bl, [rax]
        lea rax, [rsp+96]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+65]
        mov [rax], bl
        ; const t.22, 1
        mov rax, 1
        lea rbx, [rsp+112]
        mov [rbx], rax
        ; cast t.23(u8*), t.22(i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.21, [board]
        lea rax, [var_0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.21, t.21, t.23
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; load t.20, [t.21]
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+97]
        mov [rbx], al
        ; move pattern, t.14
        lea rax, [rsp+65]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; or pattern, pattern, t.20
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+97]
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
        ; const t.27, 1
        mov al, 1
        lea rbx, [rsp+131]
        mov [rbx], al
        ; move t.26, pattern
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+130]
        mov [rax], bl
        ; shiftleft t.26, t.26, t.27
        lea rax, [rsp+130]
        mov bl, [rax]
        lea rax, [rsp+131]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+130]
        mov [rax], bl
        ; const t.28, 7
        mov al, 7
        lea rbx, [rsp+132]
        mov [rbx], al
        ; move t.25, t.26
        lea rax, [rsp+130]
        mov bl, [rax]
        lea rax, [rsp+129]
        mov [rax], bl
        ; and t.25, t.25, t.28
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+132]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+129]
        mov [rax], bl
        ; const t.33, 1
        mov al, 1
        lea rbx, [rsp+153]
        mov [rbx], al
        ; move t.32, j
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+152]
        mov [rax], bl
        ; add t.32, t.32, t.33
        lea rax, [rsp+152]
        mov bl, [rax]
        lea rax, [rsp+153]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+152]
        mov [rax], bl
        ; cast t.31(i64), t.32(u8)
        lea rax, [rsp+152]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+144]
        mov [rax], rbx
        ; cast t.34(u8*), t.31(i64)
        lea rax, [rsp+144]
        mov rbx, [rax]
        lea rax, [rsp+160]
        mov [rax], rbx
        ; addrof t.30, [board]
        lea rax, [var_0]
        lea rbx, [rsp+136]
        mov [rbx], rax
        ; add t.30, t.30, t.34
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+160]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+136]
        mov [rax], rbx
        ; load t.29, [t.30]
        lea rax, [rsp+136]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+133]
        mov [rbx], al
        ; move pattern, t.25
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; or pattern, pattern, t.29
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+133]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const t.37, 110
        mov al, 110
        lea rbx, [rsp+170]
        mov [rbx], al
        ; move t.36, t.37
        lea rax, [rsp+170]
        mov bl, [rax]
        lea rax, [rsp+169]
        mov [rax], bl
        ; shiftright t.36, t.36, pattern
        lea rax, [rsp+169]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+169]
        mov [rax], bl
        ; const t.38, 1
        mov al, 1
        lea rbx, [rsp+171]
        mov [rbx], al
        ; move t.35, t.36
        lea rax, [rsp+169]
        mov bl, [rax]
        lea rax, [rsp+168]
        mov [rax], bl
        ; and t.35, t.35, t.38
        lea rax, [rsp+168]
        mov bl, [rax]
        lea rax, [rsp+171]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+168]
        mov [rax], bl
        ; cast t.40(i64), j(u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+184]
        mov [rax], rbx
        ; cast t.41(u8*), t.40(i64)
        lea rax, [rsp+184]
        mov rbx, [rax]
        lea rax, [rsp+192]
        mov [rax], rbx
        ; addrof t.39, [board]
        lea rax, [var_0]
        lea rbx, [rsp+176]
        mov [rbx], rax
        ; add t.39, t.39, t.41
        lea rax, [rsp+176]
        mov rbx, [rax]
        lea rax, [rsp+192]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+176]
        mov [rax], rbx
        ; store [t.39], t.35
        lea rax, [rsp+176]
        mov rbx, [rax]
        lea rax, [rsp+168]
        mov cl, [rax]
        mov [rbx], cl
        ; inc j
        lea rax, [rsp+3]
        mov bl, [rax]
        inc bl
        lea rax, [rsp+3]
        mov [rax], bl
@for_6:
        ; lt t.24, j, 29
        lea rax, [rsp+3]
        mov bl, [rax]
        cmp bl, 29
        setb bl
        lea rax, [rsp+128]
        mov [rax], bl
        ; branch t.24, true, @for_6_body, @for_6_break
        lea rax, [rsp+128]
        mov bl, [rax]
        or bl, bl
        jnz @for_6_body
        ; call printBoard[]
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; inc i
        lea rax, [rsp+1]
        mov bl, [rax]
        inc bl
        lea rax, [rsp+1]
        mov [rax], bl
@for_5:
        ; lt t.13, i, 28
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 28
        setb bl
        lea rax, [rsp+64]
        mov [rax], bl
        ; branch t.13, true, @for_5_body, @main_ret
        lea rax, [rsp+64]
        mov bl, [rax]
        or bl, bl
        jnz @for_5_body
        ; release space for local variables
        add rsp, 208
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
