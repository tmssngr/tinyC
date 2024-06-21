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

main:
        ; int lit 1
        mov rcx, 1
        ; int lit 2
        mov rax, 2
        ; Lt
        cmp rcx, rax
        setl cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 2
        mov rcx, 2
        ; int lit 1
        mov rax, 1
        ; Lt
        cmp rcx, rax
        setl cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 1
        mov rcx, 1
        ; int lit 2
        mov rax, 2
        ; LtEq
        cmp rcx, rax
        setle cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 2
        mov rcx, 2
        ; int lit 1
        mov rax, 1
        ; LtEq
        cmp rcx, rax
        setle cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 1
        mov rcx, 1
        ; int lit 2
        mov rax, 2
        ; Equals
        cmp rcx, rax
        sete cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 1
        mov rcx, 1
        ; int lit 2
        mov rax, 2
        ; NotEquals
        cmp rcx, rax
        setne cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 1
        mov rcx, 1
        ; int lit 2
        mov rax, 2
        ; GtEq
        cmp rcx, rax
        setge cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 2
        mov rcx, 2
        ; int lit 1
        mov rax, 1
        ; GtEq
        cmp rcx, rax
        setge cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 1
        mov rcx, 1
        ; int lit 2
        mov rax, 2
        ; Gt
        cmp rcx, rax
        setg cl
        and rcx, 0xFF
        ; print
        sub rsp, 8
          call __printUint
        mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; int lit 2
        mov rcx, 2
        ; int lit 1
        mov rax, 1
        ; Gt
        cmp rcx, rax
        setg cl
        and rcx, 0xFF
        ; print
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