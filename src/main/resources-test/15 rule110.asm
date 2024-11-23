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
        ; call length, strlen, [str]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @strlen
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call _, printStringLength [str, length]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
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
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 37:2 for *str != 0
@for_1:
        ; load t.3, [str]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+10]
        mov [rbx], al
        ; notequals t.2, t.3, t.4
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2, false, @for_1_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @for_1_break
        ; const t.5, 1
        mov rax, 1
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; add length, length, t.5
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; cast t.7, str
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8, 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6, t.7, t.8
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast str, t.6
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; void printBoard
        ;   rsp+0: var i
        ;   rsp+1: var t.1
        ;   rsp+2: var t.2
        ;   rsp+3: var t.3
        ;   rsp+4: var t.4
        ;   rsp+5: var t.5
        ;   rsp+8: var t.6
        ;   rsp+16: var t.7
        ;   rsp+24: var t.8
        ;   rsp+32: var t.9
        ;   rsp+33: var t.10
        ;   rsp+34: var t.11
        ;   rsp+35: var t.12
        ;   rsp+40: var t.13
@printBoard:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.1, 124
        mov al, 124
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call _, printChar [t.1]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 11:2 for i < 30
@for_2:
        ; const t.3, 30
        mov al, 30
        lea rbx, [rsp+3]
        mov [rbx], al
        ; lt t.2, i, t.3
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.2, false, @for_2_break
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jz @for_2_break
        ; 12:3 if [...] == 0
        ; cast t.7, i
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast t.8, t.7
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
        ; load t.5, [t.6]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+5]
        mov [rbx], al
        ; const t.9, 0
        mov al, 0
        lea rbx, [rsp+32]
        mov [rbx], al
        ; equals t.4, t.5, t.9
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4, false, @if_3_else
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @if_3_else
        ; const t.10, 32
        mov al, 32
        lea rbx, [rsp+33]
        mov [rbx], al
        ; call _, printChar [t.10]
        lea rax, [rsp+33]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        jmp @for_2_continue
@if_3_else:
        ; const t.11, 42
        mov al, 42
        lea rbx, [rsp+34]
        mov [rbx], al
        ; call _, printChar [t.11]
        lea rax, [rsp+34]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@for_2_continue:
        ; const t.12, 1
        mov al, 1
        lea rbx, [rsp+35]
        mov [rbx], al
        ; add i, i, t.12
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+35]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        jmp @for_2
@for_2_break:
        ; const t.13, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; call _, printString [t.13]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printString
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
        ;   rsp+6: var t.6
        ;   rsp+8: var t.7
        ;   rsp+16: var t.8
        ;   rsp+24: var t.9
        ;   rsp+32: var t.10
        ;   rsp+33: var t.11
        ;   rsp+40: var t.12
        ;   rsp+48: var t.13
        ;   rsp+56: var t.14
        ;   rsp+64: var t.15
        ;   rsp+72: var t.16
        ;   rsp+73: var t.17
        ;   rsp+74: var t.18
        ;   rsp+75: var t.19
        ;   rsp+80: var t.20
        ;   rsp+88: var t.21
        ;   rsp+96: var t.22
        ;   rsp+104: var t.23
        ;   rsp+105: var t.24
        ;   rsp+112: var t.25
        ;   rsp+120: var t.26
        ;   rsp+128: var t.27
        ;   rsp+136: var t.28
        ;   rsp+137: var t.29
        ;   rsp+138: var t.30
        ;   rsp+139: var t.31
        ;   rsp+140: var t.32
        ;   rsp+141: var t.33
        ;   rsp+142: var t.34
        ;   rsp+144: var t.35
        ;   rsp+152: var t.36
        ;   rsp+160: var t.37
        ;   rsp+161: var t.38
        ;   rsp+168: var t.39
        ;   rsp+176: var t.40
        ;   rsp+177: var t.41
        ;   rsp+178: var t.42
        ;   rsp+179: var t.43
        ;   rsp+184: var t.44
        ;   rsp+192: var t.45
        ;   rsp+200: var t.46
        ;   rsp+208: var t.47
        ;   rsp+209: var t.48
@main:
        ; reserve space for local variables
        sub rsp, 224
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 23:2 for i < 30
@for_4:
        ; const t.5, 30
        mov al, 30
        lea rbx, [rsp+5]
        mov [rbx], al
        ; lt t.4, i, t.5
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.4, false, @for_4_break
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @for_4_break
        ; const t.6, 0
        mov al, 0
        lea rbx, [rsp+6]
        mov [rbx], al
        ; cast t.8, i
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast t.9, t.8
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; addrof t.7, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.7, t.7, t.9
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; store [t.7], t.6
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+6]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.10, 1
        mov al, 1
        lea rbx, [rsp+32]
        mov [rbx], al
        ; add i, i, t.10
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        jmp @for_4
@for_4_break:
        ; const t.11, 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; const t.14, 29
        mov al, 29
        lea rbx, [rsp+56]
        mov [rbx], al
        ; cast t.13, t.14
        lea rax, [rsp+56]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+48]
        mov [rax], rbx
        ; cast t.15, t.13
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov [rax], rbx
        ; addrof t.12, [board]
        lea rax, [var_0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.12, t.12, t.15
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; store [t.12], t.11
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        mov [rbx], cl
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 30:2 for i < 28
@for_5:
        ; const t.17, 28
        mov al, 28
        lea rbx, [rsp+73]
        mov [rbx], al
        ; lt t.16, i, t.17
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+73]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+72]
        mov [rax], bl
        ; branch t.16, false, @main_ret
        lea rax, [rsp+72]
        mov bl, [rax]
        or bl, bl
        jz @main_ret
        ; const t.21, 0
        mov rax, 0
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; cast t.22, t.21
        lea rax, [rsp+88]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov [rax], rbx
        ; addrof t.20, [board]
        lea rax, [var_0]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; add t.20, t.20, t.22
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+80]
        mov [rax], rbx
        ; load t.19, [t.20]
        lea rax, [rsp+80]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+75]
        mov [rbx], al
        ; const t.23, 1
        mov al, 1
        lea rbx, [rsp+104]
        mov [rbx], al
        ; shiftleft t.18, t.19, t.23
        lea rax, [rsp+75]
        mov bl, [rax]
        lea rax, [rsp+104]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+74]
        mov [rax], bl
        ; const t.26, 1
        mov rax, 1
        lea rbx, [rsp+120]
        mov [rbx], rax
        ; cast t.27, t.26
        lea rax, [rsp+120]
        mov rbx, [rax]
        lea rax, [rsp+128]
        mov [rax], rbx
        ; addrof t.25, [board]
        lea rax, [var_0]
        lea rbx, [rsp+112]
        mov [rbx], rax
        ; add t.25, t.25, t.27
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+128]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+112]
        mov [rax], rbx
        ; load t.24, [t.25]
        lea rax, [rsp+112]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+105]
        mov [rbx], al
        ; or pattern, t.18, t.24
        lea rax, [rsp+74]
        mov bl, [rax]
        lea rax, [rsp+105]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const j, 1
        mov al, 1
        lea rbx, [rsp+3]
        mov [rbx], al
        ; 32:3 for j < 29
@for_6:
        ; const t.29, 29
        mov al, 29
        lea rbx, [rsp+137]
        mov [rbx], al
        ; lt t.28, j, t.29
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+137]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+136]
        mov [rax], bl
        ; branch t.28, false, @for_6_break
        lea rax, [rsp+136]
        mov bl, [rax]
        or bl, bl
        jz @for_6_break
        ; const t.32, 1
        mov al, 1
        lea rbx, [rsp+140]
        mov [rbx], al
        ; shiftleft t.31, pattern, t.32
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+140]
        mov cl, [rax]
        shl bl, cl
        lea rax, [rsp+139]
        mov [rax], bl
        ; const t.33, 7
        mov al, 7
        lea rbx, [rsp+141]
        mov [rbx], al
        ; and t.30, t.31, t.33
        lea rax, [rsp+139]
        mov bl, [rax]
        lea rax, [rsp+141]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+138]
        mov [rax], bl
        ; const t.38, 1
        mov al, 1
        lea rbx, [rsp+161]
        mov [rbx], al
        ; add t.37, j, t.38
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+161]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+160]
        mov [rax], bl
        ; cast t.36, t.37
        lea rax, [rsp+160]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+152]
        mov [rax], rbx
        ; cast t.39, t.36
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+168]
        mov [rax], rbx
        ; addrof t.35, [board]
        lea rax, [var_0]
        lea rbx, [rsp+144]
        mov [rbx], rax
        ; add t.35, t.35, t.39
        lea rax, [rsp+144]
        mov rbx, [rax]
        lea rax, [rsp+168]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+144]
        mov [rax], rbx
        ; load t.34, [t.35]
        lea rax, [rsp+144]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+142]
        mov [rbx], al
        ; or pattern, t.30, t.34
        lea rax, [rsp+138]
        mov bl, [rax]
        lea rax, [rsp+142]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const t.42, 110
        mov al, 110
        lea rbx, [rsp+178]
        mov [rbx], al
        ; shiftright t.41, t.42, pattern
        lea rax, [rsp+178]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+177]
        mov [rax], bl
        ; const t.43, 1
        mov al, 1
        lea rbx, [rsp+179]
        mov [rbx], al
        ; and t.40, t.41, t.43
        lea rax, [rsp+177]
        mov bl, [rax]
        lea rax, [rsp+179]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+176]
        mov [rax], bl
        ; cast t.45, j
        lea rax, [rsp+3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+192]
        mov [rax], rbx
        ; cast t.46, t.45
        lea rax, [rsp+192]
        mov rbx, [rax]
        lea rax, [rsp+200]
        mov [rax], rbx
        ; addrof t.44, [board]
        lea rax, [var_0]
        lea rbx, [rsp+184]
        mov [rbx], rax
        ; add t.44, t.44, t.46
        lea rax, [rsp+184]
        mov rbx, [rax]
        lea rax, [rsp+200]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+184]
        mov [rax], rbx
        ; store [t.44], t.40
        lea rax, [rsp+184]
        mov rbx, [rax]
        lea rax, [rsp+176]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.47, 1
        mov al, 1
        lea rbx, [rsp+208]
        mov [rbx], al
        ; add j, j, t.47
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+208]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+3]
        mov [rax], bl
        jmp @for_6
@for_6_break:
        ; call _, printBoard []
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; const t.48, 1
        mov al, 1
        lea rbx, [rsp+209]
        mov [rbx], al
        ; add i, i, t.48
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+209]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        jmp @for_5
@main_ret:
        ; release space for local variables
        add rsp, 224
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
        ; variable 0: board (u8*/240)
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
