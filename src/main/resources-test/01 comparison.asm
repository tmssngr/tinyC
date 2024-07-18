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
        ; 2:11 int lit 1
        mov cl, 1
        ; 2:15 int lit 2
        mov al, 2
        ; 2:13 <
        cmp cl, al
        setl cl
        and cl, 0xFF
        movzx rcx, cl
        ; 2:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 3:11 int lit 2
        mov cl, 2
        ; 3:15 int lit 1
        mov al, 1
        ; 3:13 <
        cmp cl, al
        setl cl
        and cl, 0xFF
        movzx rcx, cl
        ; 3:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 5:11 int lit 1
        mov cl, 1
        ; 5:16 int lit 2
        mov al, 2
        ; 5:13 <=
        cmp cl, al
        setle cl
        and cl, 0xFF
        movzx rcx, cl
        ; 5:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 6:11 int lit 2
        mov cl, 2
        ; 6:16 int lit 1
        mov al, 1
        ; 6:13 <=
        cmp cl, al
        setle cl
        and cl, 0xFF
        movzx rcx, cl
        ; 6:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 8:11 int lit 1
        mov cl, 1
        ; 8:16 int lit 2
        mov al, 2
        ; 8:13 ==
        cmp cl, al
        sete cl
        and cl, 0xFF
        movzx rcx, cl
        ; 8:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 10:11 int lit 1
        mov cl, 1
        ; 10:16 int lit 2
        mov al, 2
        ; 10:13 !=
        cmp cl, al
        setne cl
        and cl, 0xFF
        movzx rcx, cl
        ; 10:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 12:11 int lit 1
        mov cl, 1
        ; 12:16 int lit 2
        mov al, 2
        ; 12:13 >=
        cmp cl, al
        setge cl
        and cl, 0xFF
        movzx rcx, cl
        ; 12:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 13:11 int lit 2
        mov cl, 2
        ; 13:16 int lit 1
        mov al, 1
        ; 13:13 >=
        cmp cl, al
        setge cl
        and cl, 0xFF
        movzx rcx, cl
        ; 13:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 15:11 int lit 1
        mov cl, 1
        ; 15:15 int lit 2
        mov al, 2
        ; 15:13 >
        cmp cl, al
        setg cl
        and cl, 0xFF
        movzx rcx, cl
        ; 15:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 16:11 int lit 2
        mov cl, 2
        ; 16:15 int lit 1
        mov al, 1
        ; 16:13 >
        cmp cl, al
        setg cl
        and cl, 0xFF
        movzx rcx, cl
        ; 16:5 print i64
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@main_ret:
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
