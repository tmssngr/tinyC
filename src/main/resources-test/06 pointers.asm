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
        sub rsp, 48
        ; 2:10 int lit 10
        mov ax, 10
        ; 2:2 var a(%0)
        lea rbx, [rsp+0]
        ; 2:2 assign
        mov [rbx], ax
        ; 3:8 read var a(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        movzx rax, bx
        ; 3:8 var $.1(%1)
        lea rbx, [rsp+2]
        ; 3:8 assign
        mov [rbx], rax
        ; 3:2 call print
        lea rax, [rsp+2]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 4:12 var a(%0)
        lea rax, [rsp+0]
        ; 4:2 var b(%2)
        lea rbx, [rsp+10]
        ; 4:2 assign
        mov [rbx], rax
        ; 5:11 read var b(%2)
        lea rax, [rsp+10]
        mov rbx, [rax]
        ; 5:10 deref
        mov ax, [rbx]
        ; 5:15 int lit 1
        mov bx, 1
        ; 5:13 sub
        sub ax, bx
        ; 5:2 var c(%3)
        lea rbx, [rsp+18]
        ; 5:2 assign
        mov [rbx], ax
        ; 6:8 read var c(%3)
        lea rax, [rsp+18]
        mov bx, [rax]
        movzx rax, bx
        ; 6:8 var $.4(%4)
        lea rbx, [rsp+20]
        ; 6:8 assign
        mov [rbx], rax
        ; 6:2 call print
        lea rax, [rsp+20]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 7:12 var c(%3)
        lea rax, [rsp+18]
        ; 7:2 var d(%5)
        lea rbx, [rsp+28]
        ; 7:2 assign
        mov [rbx], rax
        ; 8:8 read var d(%5)
        lea rax, [rsp+28]
        mov rbx, [rax]
        ; 8:7 deref
        mov ax, [rbx]
        ; 8:12 int lit 1
        mov bx, 1
        ; 8:10 sub
        sub ax, bx
        ; 8:3 read var d(%5)
        lea rbx, [rsp+28]
        mov rcx, [rbx]
        ; 8:5 assign
        mov [rcx], ax
        ; 9:8 read var c(%3)
        lea rax, [rsp+18]
        mov bx, [rax]
        movzx rax, bx
        ; 9:8 var $.6(%6)
        lea rbx, [rsp+36]
        ; 9:8 assign
        mov [rbx], rax
        ; 9:2 call print
        lea rax, [rsp+36]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 48
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
