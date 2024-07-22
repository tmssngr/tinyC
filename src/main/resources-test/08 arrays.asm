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
        sub rsp, 16
        ; 4:12 int lit 32
        mov al, 32
        ; 4:3 var chr(%0)
        lea rbx, [rsp+0]
        ; 4:3 assign
        mov [rbx], al
        ; 5:14 read var chr(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 5:3 array chars($0)
        ; 5:9 int lit 0
        mov rax, 0
        imul rax, 1
        lea rcx, [var0]
        add rcx, rax
        ; 5:12 assign
        mov [rcx], bl
        ; 6:14 array chars($0)
        ; 6:20 int lit 0
        mov rax, 0
        imul rax, 1
        lea rbx, [var0]
        add rbx, rax
        mov al, [rbx]
        ; 6:25 int lit 1
        mov bl, 1
        ; 6:23 add
        add al, bl
        ; 6:3 array chars($0)
        ; 6:9 int lit 1
        mov rbx, 1
        imul rbx, 1
        lea rcx, [var0]
        add rcx, rbx
        ; 6:12 assign
        mov [rcx], al
        ; 7:16 array chars($0)
        ; 7:22 int lit 1
        mov rax, 1
        imul rax, 1
        lea rbx, [var0]
        add rbx, rax
        mov al, [rbx]
        ; 7:27 int lit 2
        mov bl, 2
        ; 7:25 add
        add al, bl
        ; 7:3 array chars($0)
        ; 7:9 int lit 1
        mov bl, 1
        ; 7:11 int lit 1
        mov cl, 1
        ; 7:10 add
        add bl, cl
        movzx rcx, bl
        imul rcx, 1
        lea rbx, [var0]
        add rbx, rcx
        ; 7:14 assign
        mov [rbx], al
        ; 8:15 array chars($0)
        ; 8:21 int lit 2
        mov rax, 2
        imul rax, 1
        lea rbx, [var0]
        add rbx, rax
        mov al, [rbx]
        ; 8:3 var result(%1)
        lea rbx, [rsp+1]
        ; 8:3 assign
        mov [rbx], al
        ; 9:9 read var result(%1)
        lea rax, [rsp+1]
        mov bl, [rax]
        movzx rax, bl
        ; 9:9 var $.2(%2)
        lea rbx, [rsp+2]
        ; 9:9 assign
        mov [rbx], rax
        ; 9:9 read var $.2(%2)
        lea rax, [rsp+2]
        mov rbx, [rax]
        ; 9:3 print i64
        sub rsp, 8
          mov rcx, rbx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 16
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
        ; variable 0: chars (2048)
        var0 rb 2048

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
