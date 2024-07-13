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
        ; 2:14 string literal string_0
        lea rcx, [string_0]
        ; 2:2 print u8*
        sub rsp, 8
          call __printStringZero
        add rsp, 8
        ; 3:8 int lit 0
        mov cl, 0
        ; 3:12 int lit 0
        mov al, 0
        ; 3:10 and
        and cl, al
        movzx cx, cl
        ; 3:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 4:8 int lit 0
        mov cl, 0
        ; 4:12 int lit 1
        mov al, 1
        ; 4:10 and
        and cl, al
        movzx cx, cl
        ; 4:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 5:8 int lit 1
        mov cl, 1
        ; 5:12 int lit 0
        mov al, 0
        ; 5:10 and
        and cl, al
        movzx cx, cl
        ; 5:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 6:8 int lit 1
        mov cl, 1
        ; 6:12 int lit 1
        mov al, 1
        ; 6:10 and
        and cl, al
        movzx cx, cl
        ; 6:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 7:14 string literal string_1
        lea rcx, [string_1]
        ; 7:2 print u8*
        sub rsp, 8
          call __printStringZero
        add rsp, 8
        ; 8:8 int lit 0
        mov cl, 0
        ; 8:12 int lit 0
        mov al, 0
        ; 8:10 or
        or cl, al
        movzx cx, cl
        ; 8:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 9:8 int lit 0
        mov cl, 0
        ; 9:12 int lit 1
        mov al, 1
        ; 9:10 or
        or cl, al
        movzx cx, cl
        ; 9:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 10:8 int lit 1
        mov cl, 1
        ; 10:12 int lit 0
        mov al, 0
        ; 10:10 or
        or cl, al
        movzx cx, cl
        ; 10:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 11:8 int lit 1
        mov cl, 1
        ; 11:12 int lit 1
        mov al, 1
        ; 11:10 or
        or cl, al
        movzx cx, cl
        ; 11:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 12:14 string literal string_2
        lea rcx, [string_2]
        ; 12:2 print u8*
        sub rsp, 8
          call __printStringZero
        add rsp, 8
        ; 13:8 int lit 0
        mov cl, 0
        ; 13:12 int lit 0
        mov al, 0
        ; 13:10 xor
        xor cl, al
        movzx cx, cl
        ; 13:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 14:8 int lit 0
        mov cl, 0
        ; 14:12 int lit 2
        mov al, 2
        ; 14:10 xor
        xor cl, al
        movzx cx, cl
        ; 14:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 15:8 int lit 1
        mov cl, 1
        ; 15:12 int lit 0
        mov al, 0
        ; 15:10 xor
        xor cl, al
        movzx cx, cl
        ; 15:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 16:8 int lit 1
        mov cl, 1
        ; 16:12 int lit 2
        mov al, 2
        ; 16:10 xor
        xor cl, al
        movzx cx, cl
        ; 16:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 17:14 string literal string_3
        lea rcx, [string_3]
        ; 17:2 print u8*
        sub rsp, 8
          call __printStringZero
        add rsp, 8
        ; 18:10 logic and
        ; 18:8 int lit 0
        mov cl, 0
        or cl, cl
        jz next_1
        ; 18:13 int lit 0
        mov al, 0
        mov cl, al
next_1:
        movzx cx, cl
        ; 18:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 19:10 logic and
        ; 19:8 int lit 0
        mov cl, 0
        or cl, cl
        jz next_2
        ; 19:13 int lit 2
        mov al, 2
        mov cl, al
next_2:
        movzx cx, cl
        ; 19:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 20:10 logic and
        ; 20:8 int lit 1
        mov cl, 1
        or cl, cl
        jz next_3
        ; 20:13 int lit 0
        mov al, 0
        mov cl, al
next_3:
        movzx cx, cl
        ; 20:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 21:10 logic and
        ; 21:8 int lit 1
        mov cl, 1
        or cl, cl
        jz next_4
        ; 21:13 int lit 2
        mov al, 2
        mov cl, al
next_4:
        movzx cx, cl
        ; 21:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 22:14 string literal string_4
        lea rcx, [string_4]
        ; 22:2 print u8*
        sub rsp, 8
          call __printStringZero
        add rsp, 8
        ; 23:10 logic or
        ; 23:8 int lit 0
        mov cl, 0
        or cl, cl
        jnz next_5
        ; 23:13 int lit 0
        mov al, 0
        mov cl, al
next_5:
        movzx cx, cl
        ; 23:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 24:10 logic or
        ; 24:8 int lit 0
        mov cl, 0
        or cl, cl
        jnz next_6
        ; 24:13 int lit 2
        mov al, 2
        mov cl, al
next_6:
        movzx cx, cl
        ; 24:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 25:10 logic or
        ; 25:8 int lit 1
        mov cl, 1
        or cl, cl
        jnz next_7
        ; 25:13 int lit 0
        mov al, 0
        mov cl, al
next_7:
        movzx cx, cl
        ; 25:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 26:10 logic or
        ; 26:8 int lit 1
        mov cl, 1
        or cl, cl
        jnz next_8
        ; 26:13 int lit 2
        mov al, 2
        mov cl, al
next_8:
        movzx cx, cl
        ; 26:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 27:14 string literal string_5
        lea rcx, [string_5]
        ; 27:2 print u8*
        sub rsp, 8
          call __printStringZero
        add rsp, 8
        ; 28:8 int lit 10
        mov cl, 10
        ; 28:17 int lit 6
        mov al, 6
        ; 28:15 and
        and cl, al
        ; 28:26 int lit 1
        mov al, 1
        ; 28:24 or
        or cl, al
        movzx cx, cl
        ; 28:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 29:15 logic or
        ; 29:8 int lit 1
        mov cl, 1
        ; 29:13 int lit 2
        mov al, 2
        ; 29:10 ==
        cmp cl, al
        sete cl
        and cl, 0xFF
        or cl, cl
        jnz next_9
        ; 29:18 int lit 2
        mov al, 2
        ; 29:22 int lit 3
        mov bl, 3
        ; 29:20 <
        cmp al, bl
        setl al
        and al, 0xFF
        mov cl, al
next_9:
        movzx cx, cl
        ; 29:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 30:15 logic and
        ; 30:8 int lit 1
        mov cl, 1
        ; 30:13 int lit 2
        mov al, 2
        ; 30:10 ==
        cmp cl, al
        sete cl
        and cl, 0xFF
        or cl, cl
        jz next_10
        ; 30:18 int lit 2
        mov al, 2
        ; 30:22 int lit 3
        mov bl, 3
        ; 30:20 <
        cmp al, bl
        setl al
        and al, 0xFF
        mov cl, al
next_10:
        movzx cx, cl
        ; 30:2 print i16
        sub rsp, 8
          movzx rcx, cx
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
main_ret:
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

section '.data' data readable
        string_0 db '&:', 0x0a, 0x00
        string_1 db 0x0a, '|:', 0x0a, 0x00
        string_2 db 0x0a, '^:', 0x0a, 0x00
        string_3 db 0x0a, '&&:', 0x0a, 0x00
        string_4 db 0x0a, '||:', 0x0a, 0x00
        string_5 db 0x0a, 'misc:', 0x0a, 0x00

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