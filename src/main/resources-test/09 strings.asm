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
          call main_0
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void main
main_0:
        ; 4:14 read var text
        lea rcx, [var0]
        mov rax, [rcx]
        ; 4:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 5:2 call printLength
        sub rsp, 8
          call printLength_0
        add rsp, 8
        ; 6:15 address of array text[...]
        ; 6:21 int lit 1
        mov rcx, 1
        imul rcx, 1
        lea rbx, [var0]
        mov rax, [rbx]
        add rax, rcx
        ; 6:2 assign second
        lea rcx, [var1]
        mov [rcx], rax
        ; 7:14 read var second
        lea rcx, [var1]
        mov rax, [rcx]
        ; 7:2 print u8*
        sub rsp, 8
          mov rcx, rax
          call __printStringZero
        add rsp, 8
        ; 8:12 read var text
        lea rcx, [var0]
        mov rax, [rcx]
        ; 8:11 deref
        mov cl, [rax]
        ; 8:2 assign chr
        lea rax, [var2]
        mov [rax], cl
        ; 9:8 read var chr
        lea rcx, [var2]
        mov al, [rcx]
        movzx ax, al
        ; 9:2 print i16
        sub rsp, 8
          movzx rcx, ax
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
main_ret:
        ret
        ; void printLength
printLength_0:
        ; 13:15 int lit 0
        mov cx, 0
        ; 13:2 assign length
        lea rax, [var3]
        mov [rax], cx
        ; 14:2 for
        ; 14:17 read var text
        lea rcx, [var0]
        mov rax, [rcx]
        ; 14:7 assign ptr
        lea rcx, [var4]
        mov [rcx], rax
        ; for condition ExprDeref[expression=ptr, type=u8, location=14:23] != 0
for_1:
        ; 14:24 read var ptr
        lea rcx, [var4]
        mov rax, [rcx]
        ; 14:23 deref
        mov cl, [rax]
        ; 14:31 int lit 0
        mov al, 0
        ; 14:28 !=
        cmp cl, al
        setne cl
        and cl, 0xFF
        or cl, cl
        jz endFor_1
        ; 15:12 read var length
        lea rax, [var3]
        mov bx, [rax]
        ; 15:21 int lit 1
        mov al, 1
        movzx ax, al
        ; 15:19 add
        add bx, ax
        ; 15:3 var length
        lea rax, [var3]
        ; 15:10 assign
        mov [rax], bx
        ; for iteration
        ; 14:40 read var ptr
        lea rax, [var4]
        mov rbx, [rax]
        ; 14:46 int lit 1
        mov rax, 1
        ; 14:44 add
        add rbx, rax
        ; 14:34 var ptr
        lea rax, [var4]
        ; 14:38 assign
        mov [rax], rbx
        jmp for_1
endFor_1:
        ; 17:8 read var length
        lea rax, [var3]
        mov bx, [rax]
        ; 17:2 print i16
        sub rsp, 8
          movzx rcx, bx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
printLength_ret:
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
        lea rax, [string_0]
        ; 1:1 assign text
        lea rbx, [var0]
        mov [rbx], rax
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
        var1 rb 8
        var2 rb 1
        var3 rb 2
        var4 rb 8

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