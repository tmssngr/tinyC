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
        ; 4:14 read var text
        lea rcx, [var0]
        mov rax, [rcx]
        ; 4:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 5:12 read var text
        lea rcx, [var0]
        mov rax, [rcx]
        ; 5:11 deref
        mov cl, [rax]
        ; 5:2 assign chr
        lea rax, [var1]
        mov [rax], cl
        ; 6:8 read var chr
        lea rcx, [var1]
        mov al, [rcx]
        movzx ax, al
        ; 6:2 print i16
        sub rsp, 8
          movzx rcx, ax
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
        ; 1:12 string literal string_0
        lea rcx, [string_0]
        ; 1:1 assign text
        lea rax, [var0]
        mov [rax], rcx
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
        var0 rb 8
        var1 rb 1

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
