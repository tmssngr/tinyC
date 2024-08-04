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
        sub rsp, 80
        ; 2:11 int lit 1
        mov al, 1
        ; 2:15 int lit 2
        mov bl, 2
        ; 2:13 <
        cmp al, bl
        setl cl
        and cl, 0xFF
        movzx rax, cl
        ; 2:13 var $.0(%0)
        lea rbx, [rsp+0]
        ; 2:13 assign
        mov [rbx], rax
        ; 2:5 call print
        lea rax, [rsp+0]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 3:11 int lit 2
        mov al, 2
        ; 3:15 int lit 1
        mov bl, 1
        ; 3:13 <
        cmp al, bl
        setl cl
        and cl, 0xFF
        movzx rax, cl
        ; 3:13 var $.1(%1)
        lea rbx, [rsp+8]
        ; 3:13 assign
        mov [rbx], rax
        ; 3:5 call print
        lea rax, [rsp+8]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 5:11 int lit 1
        mov al, 1
        ; 5:16 int lit 2
        mov bl, 2
        ; 5:13 <=
        cmp al, bl
        setle cl
        and cl, 0xFF
        movzx rax, cl
        ; 5:13 var $.2(%2)
        lea rbx, [rsp+16]
        ; 5:13 assign
        mov [rbx], rax
        ; 5:5 call print
        lea rax, [rsp+16]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 6:11 int lit 2
        mov al, 2
        ; 6:16 int lit 1
        mov bl, 1
        ; 6:13 <=
        cmp al, bl
        setle cl
        and cl, 0xFF
        movzx rax, cl
        ; 6:13 var $.3(%3)
        lea rbx, [rsp+24]
        ; 6:13 assign
        mov [rbx], rax
        ; 6:5 call print
        lea rax, [rsp+24]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 8:11 int lit 1
        mov al, 1
        ; 8:16 int lit 2
        mov bl, 2
        ; 8:13 ==
        cmp al, bl
        sete cl
        and cl, 0xFF
        movzx rax, cl
        ; 8:13 var $.4(%4)
        lea rbx, [rsp+32]
        ; 8:13 assign
        mov [rbx], rax
        ; 8:5 call print
        lea rax, [rsp+32]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 10:11 int lit 1
        mov al, 1
        ; 10:16 int lit 2
        mov bl, 2
        ; 10:13 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        movzx rax, cl
        ; 10:13 var $.5(%5)
        lea rbx, [rsp+40]
        ; 10:13 assign
        mov [rbx], rax
        ; 10:5 call print
        lea rax, [rsp+40]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 12:11 int lit 1
        mov al, 1
        ; 12:16 int lit 2
        mov bl, 2
        ; 12:13 >=
        cmp al, bl
        setge cl
        and cl, 0xFF
        movzx rax, cl
        ; 12:13 var $.6(%6)
        lea rbx, [rsp+48]
        ; 12:13 assign
        mov [rbx], rax
        ; 12:5 call print
        lea rax, [rsp+48]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 13:11 int lit 2
        mov al, 2
        ; 13:16 int lit 1
        mov bl, 1
        ; 13:13 >=
        cmp al, bl
        setge cl
        and cl, 0xFF
        movzx rax, cl
        ; 13:13 var $.7(%7)
        lea rbx, [rsp+56]
        ; 13:13 assign
        mov [rbx], rax
        ; 13:5 call print
        lea rax, [rsp+56]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 15:11 int lit 1
        mov al, 1
        ; 15:15 int lit 2
        mov bl, 2
        ; 15:13 >
        cmp al, bl
        setg cl
        and cl, 0xFF
        movzx rax, cl
        ; 15:13 var $.8(%8)
        lea rbx, [rsp+64]
        ; 15:13 assign
        mov [rbx], rax
        ; 15:5 call print
        lea rax, [rsp+64]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 16:11 int lit 2
        mov al, 2
        ; 16:15 int lit 1
        mov bl, 1
        ; 16:13 >
        cmp al, bl
        setg cl
        and cl, 0xFF
        movzx rax, cl
        ; 16:13 var $.9(%9)
        lea rbx, [rsp+72]
        ; 16:13 assign
        mov [rbx], rax
        ; 16:5 call print
        lea rax, [rsp+72]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 80
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
