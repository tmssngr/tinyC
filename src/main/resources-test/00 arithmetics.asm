format pe64 console
include 'win64ax.inc'

STD_IN_HANDLE = -10
STD_OUT_HANDLE = -11
STD_ERR_HANDLE = -12

entry start

section '.text' code readable executable

start:
        sub rsp, 8
          call init
        add rsp, 8
          call main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void main
main:
        ; 2:15 int lit 4
        mov cl, 4
        ; 2:19 int lit 3
        mov al, 3
        ; 2:17 multiply
        movsx rcx, cl
        movsx rax, al
        imul rcx, rax
        ; 2:23 int lit 2
        mov al, 2
        ; 2:25 int lit 5
        mov bl, 5
        ; 2:24 multiply
        movsx rax, al
        movsx rbx, bl
        imul rax, rbx
        ; 2:21 add
        add cl, al
        movzx cx, cl
        ; 2:5 assign foo
        lea rax, [var0]
        mov [rax], cx
        ; 3:15 read var foo
        lea rcx, [var0]
        mov ax, [rcx]
        ; 3:21 read var foo
        lea rcx, [var0]
        mov bx, [rcx]
        ; 3:19 multiply
        movsx rax, ax
        movsx rbx, bx
        imul rax, rbx
        ; 3:5 assign bar
        lea rcx, [var1]
        mov [rcx], ax
        ; 4:11 int lit 1
        mov cx, 1
        ; 4:5 var foo
        lea rax, [var0]
        ; 4:9 assign
        mov [rax], cx
        ; 5:11 read var bar
        lea rcx, [var1]
        mov ax, [rcx]
        ; 5:17 read var foo
        lea rcx, [var0]
        mov bx, [rcx]
        ; 5:15 add
        add ax, bx
        movzx rcx, ax
        ; 5:5 call print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
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
        var0 rb 2
        var1 rb 2

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
