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
        sub rsp, 32
        ; 31:22 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 31:22 var $.2(%2)
        lea rax, [rsp+8]
        ; 31:22 assign
        mov [rax], rbx
        ; 31:15 call strlen
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        ; 31:2 var length(%1)
        lea rbx, [rsp+0]
        ; 31:2 assign
        mov [rbx], rax
        ; 32:20 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 32:20 var $.3(%3)
        lea rax, [rsp+16]
        ; 32:20 assign
        mov [rax], rbx
        ; 32:2 call printStringLength
        lea rax, [rsp+16]
        mov rcx, [rax]
        lea rax, [rsp+0]
        mov rdx, [rax]
        sub rsp, 8
          call __printStringLength
        add rsp, 8
@printString_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; i64 strlen
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; 36:15 int lit 0
        mov rax, 0
        ; 36:2 var length(%1)
        lea rbx, [rsp+0]
        ; 36:2 assign
        mov [rbx], rax
        ; 37:2 for *str != 0
@for_1:
        ; 37:10 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 37:9 deref
        mov al, [rbx]
        ; 37:17 int lit 0
        mov bl, 0
        ; 37:14 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        or cl, cl
        jz @for_1_break
        ; for body
        ; 38:12 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        ; 38:21 int lit 1
        mov rax, 1
        ; 38:19 add
        add rbx, rax
        ; 38:3 var length(%1)
        lea rax, [rsp+0]
        ; 38:10 assign
        mov [rax], rbx
@for_1_continue:
        ; 37:26 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 37:32 int lit 1
        mov rax, 1
        ; 37:30 add
        add rbx, rax
        ; 37:20 var str(%0)
        lea rax, [rsp+24]
        ; 37:24 assign
        mov [rax], rbx
        jmp @for_1
@for_1_break:
        ; 40:9 return length
        ; 40:9 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        jmp @strlen_ret
@strlen_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; 3:12 string literal string_0
        lea rax, [string_0]
        ; 3:1 var text($0)
        lea rbx, [var0]
        ; 3:1 assign
        mov [rbx], rax
        ; end initialize global variables
        ; 6:14 read var text($0)
        lea rax, [var0]
        mov rbx, [rax]
        ; 6:14 var $.0(%0)
        lea rax, [rsp+0]
        ; 6:14 assign
        mov [rax], rbx
        ; 6:2 call printString
        lea rax, [rsp+0]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 7:2 call printLength
        sub rsp, 8
          call @printLength
        add rsp, 8
        ; 8:21 array text($0)
        ; 8:21 int lit 1
        mov rax, 1
        imul rax, 1
        lea rcx, [var0]
        mov rbx, [rcx]
        add rbx, rax
        ; 8:2 var second(%1)
        lea rax, [rsp+8]
        ; 8:2 assign
        mov [rax], rbx
        ; 9:2 call printString
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 10:12 read var text($0)
        lea rax, [var0]
        mov rbx, [rax]
        ; 10:11 deref
        mov al, [rbx]
        ; 10:2 var chr(%2)
        lea rbx, [rsp+16]
        ; 10:2 assign
        mov [rbx], al
        ; 11:8 read var chr(%2)
        lea rax, [rsp+16]
        mov bl, [rax]
        movzx rax, bl
        ; 11:8 var $.3(%3)
        lea rbx, [rsp+17]
        ; 11:8 assign
        mov [rbx], rax
        ; 11:2 call print
        lea rax, [rsp+17]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void printLength
@printLength:
        ; reserve space for local variables
        sub rsp, 32
        ; 15:15 int lit 0
        mov ax, 0
        ; 15:2 var length(%0)
        lea rbx, [rsp+0]
        ; 15:2 assign
        mov [rbx], ax
        ; 16:17 read var text($0)
        lea rax, [var0]
        mov rbx, [rax]
        ; 16:7 var ptr(%1)
        lea rax, [rsp+2]
        ; 16:7 assign
        mov [rax], rbx
        ; 16:2 for *ptr != 0
@for_2:
        ; 16:24 read var ptr(%1)
        lea rax, [rsp+2]
        mov rbx, [rax]
        ; 16:23 deref
        mov al, [rbx]
        ; 16:31 int lit 0
        mov bl, 0
        ; 16:28 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        or cl, cl
        jz @for_2_break
        ; for body
        ; 17:12 read var length(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        ; 17:21 int lit 1
        mov ax, 1
        ; 17:19 add
        add bx, ax
        ; 17:3 var length(%0)
        lea rax, [rsp+0]
        ; 17:10 assign
        mov [rax], bx
@for_2_continue:
        ; 16:40 read var ptr(%1)
        lea rax, [rsp+2]
        mov rbx, [rax]
        ; 16:46 int lit 1
        mov rax, 1
        ; 16:44 add
        add rbx, rax
        ; 16:34 var ptr(%1)
        lea rax, [rsp+2]
        ; 16:38 assign
        mov [rax], rbx
        jmp @for_2
@for_2_break:
        ; 19:8 read var length(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        movzx rax, bx
        ; 19:8 var $.2(%2)
        lea rbx, [rsp+10]
        ; 19:8 assign
        mov [rbx], rax
        ; 19:2 call print
        lea rax, [rsp+10]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@printLength_ret:
        ; release space for local variables
        add rsp, 32
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
__emit:
        push rcx ; = sub rsp, 8
          mov rcx, rsp
          mov rdx, 1
          call __printStringLength
        pop rcx
        ret
__printStringLength:
        mov     rdi, rsp
        and     spl, 0xf0

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, qword [rcx]
        xor     r9, r9
        push    0
          sub     rsp, 20h
            call    [WriteFile]
          add     rsp, 20h
        ; add     rsp, 8
        mov     rsp, rdi
        ret
__printUint:
        push   rbp
        mov    rbp,rsp
        sub    rsp, 50h
        mov    qword [rsp+24h], rcx

        ; int pos = sizeof(buf);
        mov    ax, 20h
        mov    word [rsp+20h], ax

        ; do {
.print:
        ; pos--;
        mov    ax, word [rsp+20h]
        dec    ax
        mov    word [rsp+20h], ax

        ; int remainder = x mod 10;
        ; x = x / 10;
        mov    rax, qword [rsp+24h]
        mov    ecx, 10
        xor    edx, edx
        div    ecx
        mov    qword [rsp+24h], rax

        ; int digit = remainder + '0';
        add    dl, '0'

        ; buf[pos] = digit;
        mov    ax, word [rsp+20h]
        movzx  rax, ax
        lea    rcx, qword [rsp]
        add    rcx, rax
        mov    byte [rcx], dl

        ; } while (x > 0);
        mov    rax, qword [rsp+24h]
        cmp    rax, 0
        ja     .print

        ; rcx = &buf[pos]

        ; rdx = sizeof(buf) - pos
        mov    ax, word [rsp+20h]
        movzx  rax, ax
        mov    rdx, 20h
        sub    rdx, rax

        ;sub    rsp, 8  not necessary because initial push rbp
          call   __printStringLength
        ;add    rsp, 8
        leave ; Set SP to BP, then pop BP
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: text (8)
        var0 rb 8

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
