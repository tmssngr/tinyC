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

        ; void printNibble
        ;   rsp+24: arg x
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
        ;   rsp+4: var t.5
@printNibble:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.1, 15
        mov al, 15
        lea rbx, [rsp+0]
        mov [rbx], al
        ; and x, x, t.1
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+24]
        mov [rax], bl
        ; 5:2 if x > 9
        ; const t.3, 9
        mov al, 9
        lea rbx, [rsp+2]
        mov [rbx], al
        ; gt t.2, x, t.3
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.2, false, @if_2_end
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jz @if_2_end
        ; const t.4, 7
        mov al, 7
        lea rbx, [rsp+3]
        mov [rbx], al
        ; add x, x, t.4
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+24]
        mov [rax], bl
@if_2_end:
        ; const t.5, 48
        mov al, 48
        lea rbx, [rsp+4]
        mov [rbx], al
        ; add x, x, t.5
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+24]
        mov [rax], bl
        ; call _, printChar [x]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printHex2
        ;   rsp+24: arg x
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
@printHex2:
        ; reserve space for local variables
        sub rsp, 16
        ; const t.2, 4
        mov al, 4
        lea rbx, [rsp+1]
        mov [rbx], al
        ; shiftright t.1, x, t.2
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        ; call _, printNibble [t.1]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printNibble
        add rsp, 8
        ; call _, printNibble [x]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printNibble
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
        ;   rsp+26: var t.13
        ;   rsp+27: var t.14
        ;   rsp+28: var t.15
        ;   rsp+29: var t.16
        ;   rsp+30: var t.17
        ;   rsp+31: var t.18
        ;   rsp+32: var t.19
        ;   rsp+33: var t.20
        ;   rsp+34: var t.21
        ;   rsp+35: var t.22
        ;   rsp+36: var t.23
        ;   rsp+37: var t.24
        ;   rsp+38: var t.25
        ;   rsp+39: var t.26
        ;   rsp+40: var t.27
        ;   rsp+41: var t.28
@main:
        ; reserve space for local variables
        sub rsp, 48
        ; const t.2, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printString [t.2]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 19:2 for i < 16
@for_3:
        ; const t.4, 16
        mov al, 16
        lea rbx, [rsp+17]
        mov [rbx], al
        ; lt t.3, i, t.4
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.3, false, @for_3_break
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz @for_3_break
        ; 20:3 if i & 7 == 0
        ; const t.7, 7
        mov al, 7
        lea rbx, [rsp+20]
        mov [rbx], al
        ; and t.6, i, t.7
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+19]
        mov [rax], bl
        ; const t.8, 0
        mov al, 0
        lea rbx, [rsp+21]
        mov [rbx], al
        ; equals t.5, t.6, t.8
        lea rax, [rsp+19]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+18]
        mov [rax], bl
        ; branch t.5, false, @if_4_end
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jz @if_4_end
        ; const t.9, 32
        mov al, 32
        lea rbx, [rsp+22]
        mov [rbx], al
        ; call _, printChar [t.9]
        lea rax, [rsp+22]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_4_end:
        ; call _, printNibble [i]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printNibble
        add rsp, 8
        ; const t.10, 1
        mov al, 1
        lea rbx, [rsp+23]
        mov [rbx], al
        ; add i, i, t.10
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+23]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        jmp @for_3
@for_3_break:
        ; const t.11, 10
        mov al, 10
        lea rbx, [rsp+24]
        mov [rbx], al
        ; call _, printChar [t.11]
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; const i, 32
        mov al, 32
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 27:2 for i < 128
@for_5:
        ; const t.13, 128
        mov al, 128
        lea rbx, [rsp+26]
        mov [rbx], al
        ; lt t.12, i, t.13
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+26]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+25]
        mov [rax], bl
        ; branch t.12, false, @main_ret
        lea rax, [rsp+25]
        mov bl, [rax]
        or bl, bl
        jz @main_ret
        ; 28:3 if i & 15 == 0
        ; const t.16, 15
        mov al, 15
        lea rbx, [rsp+29]
        mov [rbx], al
        ; and t.15, i, t.16
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+29]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+28]
        mov [rax], bl
        ; const t.17, 0
        mov al, 0
        lea rbx, [rsp+30]
        mov [rbx], al
        ; equals t.14, t.15, t.17
        lea rax, [rsp+28]
        mov bl, [rax]
        lea rax, [rsp+30]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+27]
        mov [rax], bl
        ; branch t.14, false, @if_6_end
        lea rax, [rsp+27]
        mov bl, [rax]
        or bl, bl
        jz @if_6_end
        ; call _, printHex2 [i]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printHex2
        add rsp, 8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const t.20, 7
        mov al, 7
        lea rbx, [rsp+33]
        mov [rbx], al
        ; and t.19, i, t.20
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; const t.21, 0
        mov al, 0
        lea rbx, [rsp+34]
        mov [rbx], al
        ; equals t.18, t.19, t.21
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+34]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+31]
        mov [rax], bl
        ; branch t.18, false, @if_7_end
        lea rax, [rsp+31]
        mov bl, [rax]
        or bl, bl
        jz @if_7_end
        ; const t.22, 32
        mov al, 32
        lea rbx, [rsp+35]
        mov [rbx], al
        ; call _, printChar [t.22]
        lea rax, [rsp+35]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@if_7_end:
        ; call _, printChar [i]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; 35:3 if i & 15 == 15
        ; const t.25, 15
        mov al, 15
        lea rbx, [rsp+38]
        mov [rbx], al
        ; and t.24, i, t.25
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+38]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+37]
        mov [rax], bl
        ; const t.26, 15
        mov al, 15
        lea rbx, [rsp+39]
        mov [rbx], al
        ; equals t.23, t.24, t.26
        lea rax, [rsp+37]
        mov bl, [rax]
        lea rax, [rsp+39]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+36]
        mov [rax], bl
        ; branch t.23, false, @for_5_continue
        lea rax, [rsp+36]
        mov bl, [rax]
        or bl, bl
        jz @for_5_continue
        ; const t.27, 10
        mov al, 10
        lea rbx, [rsp+40]
        mov [rbx], al
        ; call _, printChar [t.27]
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
@for_5_continue:
        ; const t.28, 1
        mov al, 1
        lea rbx, [rsp+41]
        mov [rbx], al
        ; add i, i, t.28
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+41]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        jmp @for_5
@main_ret:
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
