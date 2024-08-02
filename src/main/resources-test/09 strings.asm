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

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; 1:12 string literal string_0
        lea rax, [string_0]
        ; 1:1 var text($0)
        lea rbx, [var0]
        ; 1:1 assign
        mov [rbx], rax
        ; end initialize global variables
        ; 4:14 read var text($0)
        lea rax, [var0]
        mov rbx, [rax]
        ; 4:14 var $.0(%0)
        lea rax, [rsp+0]
        ; 4:14 assign
        mov [rax], rbx
        ; 4:14 read var $.0(%0)
        lea rax, [rsp+0]
        mov rbx, [rax]
        ; 4:2 print u8*
        sub rsp, 8
          mov rcx, rbx
          call __printStringZero
        add rsp, 8
        ; 5:2 call printLength
        sub rsp, 8
          call @printLength
        add rsp, 8
        ; 6:21 array text($0)
        ; 6:21 int lit 1
        mov rax, 1
        imul rax, 1
        lea rcx, [var0]
        mov rbx, [rcx]
        add rbx, rax
        ; 6:2 var second(%1)
        lea rax, [rsp+8]
        ; 6:2 assign
        mov [rax], rbx
        ; 7:14 read var second(%1)
        lea rax, [rsp+8]
        mov rbx, [rax]
        ; 7:2 print u8*
        sub rsp, 8
          mov rcx, rbx
          call __printStringZero
        add rsp, 8
        ; 8:12 read var text($0)
        lea rax, [var0]
        mov rbx, [rax]
        ; 8:11 deref
        mov al, [rbx]
        ; 8:2 var chr(%2)
        lea rbx, [rsp+16]
        ; 8:2 assign
        mov [rbx], al
        ; 9:8 read var chr(%2)
        lea rax, [rsp+16]
        mov bl, [rax]
        movzx rax, bl
        ; 9:8 var $.3(%3)
        lea rbx, [rsp+17]
        ; 9:8 assign
        mov [rbx], rax
        ; 9:8 read var $.3(%3)
        lea rax, [rsp+17]
        mov rbx, [rax]
        ; 9:2 print i64
        sub rsp, 8
          mov rcx, rbx
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
        ; 13:15 int lit 0
        mov ax, 0
        ; 13:2 var length(%0)
        lea rbx, [rsp+0]
        ; 13:2 assign
        mov [rbx], ax
        ; 14:17 read var text($0)
        lea rax, [var0]
        mov rbx, [rax]
        ; 14:7 var ptr(%1)
        lea rax, [rsp+2]
        ; 14:7 assign
        mov [rax], rbx
        ; 14:2 for *ptr != 0
@for_1:
        ; 14:24 read var ptr(%1)
        lea rax, [rsp+2]
        mov rbx, [rax]
        ; 14:23 deref
        mov al, [rbx]
        ; 14:31 int lit 0
        mov bl, 0
        ; 14:28 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        or cl, cl
        jz @for_1_break
        ; for body
        ; 15:12 read var length(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        ; 15:21 int lit 1
        mov ax, 1
        ; 15:19 add
        add bx, ax
        ; 15:3 var length(%0)
        lea rax, [rsp+0]
        ; 15:10 assign
        mov [rax], bx
@for_1_continue:
        ; 14:40 read var ptr(%1)
        lea rax, [rsp+2]
        mov rbx, [rax]
        ; 14:46 int lit 1
        mov rax, 1
        ; 14:44 add
        add rbx, rax
        ; 14:34 var ptr(%1)
        lea rax, [rsp+2]
        ; 14:38 assign
        mov [rax], rbx
        jmp @for_1
@for_1_break:
        ; 17:8 read var length(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        movzx rax, bx
        ; 17:8 var $.2(%2)
        lea rbx, [rsp+10]
        ; 17:8 assign
        mov [rbx], rax
        ; 17:8 read var $.2(%2)
        lea rax, [rsp+10]
        mov rbx, [rax]
        ; 17:2 print i64
        sub rsp, 8
          mov rcx, rbx
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
          call __printString
        pop rcx
        ret
__printStringZero:
        mov rdx, rcx
__printStringZero_1:
        mov r9l, [rdx]
        or  r9l, r9l
        jz __printStringZero_2
        add rdx, 1
        jmp __printStringZero_1
__printStringZero_2:
        sub rdx, rcx
__printString:
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
          call   __printString
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
