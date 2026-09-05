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

        ; i64 strlen@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
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

        ; u8 next
        ;   rsp+0: var copy
@next:
        ; reserve space for local variables
        sub rsp, 16
        ; move copy, global
        lea rax, [var_0]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; add global, global, 1
        lea rax, [var_0]
        mov bl, [rax]
        add bl, 1
        lea rax, [var_0]
        mov [rax], bl
        ; 8:9 return copy
        ; ret copy
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var n
        ;   rsp+8: var t.1
        ;   rsp+16: var t.2
        ;   rsp+17: var t.3
        ;   rsp+18: var t.4
        ;   rsp+19: var t.5
        ;   rsp+24: var t.6
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; const global, 0
        mov al, 0
        lea rbx, [var_0]
        mov [rbx], al
        ; end initialize global variables
        ; 12:2 while true
        jmp @while_2
@if_3_end:
        ; 19:3 if n < 2
        ; const t.5, 2
        mov al, 2
        lea rbx, [rsp+19]
        mov [rbx], al
        ; lt t.4, n, t.5
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+19]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+18]
        mov [rax], bl
        ; branch t.4, false, @while_2, @if_4_then
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jz @while_2
        ; const t.6, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.6]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
@while_2:
        ; const t.1, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; call n = next[] -> u8
        sub rsp, 8
          call @next
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 15:3 if n == 3
        ; const t.3, 3
        mov al, 3
        lea rbx, [rsp+17]
        mov [rbx], al
        ; equals t.2, n, t.3
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.2, false, @if_3_end, @main_ret
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
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
        ; variable 0: global (u8/1)
        var_0 rb 1

section '.data' data readable
        string_0 db 'loop', 0x0a, 0x00
        string_1 db '<2', 0x0a, 0x00

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
