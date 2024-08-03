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
        ; 2:9 int lit 5
        mov al, 5
        ; 2:2 var i(%0)
        lea rbx, [rsp+0]
        ; 2:2 assign
        mov [rbx], al
        ; 3:2 while i > 0
@while_1:
        ; 3:9 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 3:13 int lit 0
        mov al, 0
        ; 3:11 >
        cmp bl, al
        setg cl
        and cl, 0xFF
        or cl, cl
        jz @while_1_break
        ; while body
        ; 4:9 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rax, bl
        ; 4:9 var $.1(%1)
        lea rbx, [rsp+1]
        ; 4:9 assign
        mov [rbx], rax
        ; 4:3 call print
        lea rax, [rsp+1]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 5:7 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 5:11 int lit 1
        mov al, 1
        ; 5:9 sub
        sub bl, al
        ; 5:3 var i(%0)
        lea rax, [rsp+0]
        ; 5:5 assign
        mov [rax], bl
        jmp @while_1
@while_1_break:
        ; 8:2 while true
@while_2:
        ; 8:9 bool lit true
        mov al, 1
        or al, al
        jz @while_2_break
        ; while body
        ; 9:9 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rax, bl
        ; 9:9 var $.2(%2)
        lea rbx, [rsp+9]
        ; 9:9 assign
        mov [rbx], rax
        ; 9:3 call print
        lea rax, [rsp+9]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 10:7 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 10:11 int lit 1
        mov al, 1
        ; 10:9 add
        add bl, al
        ; 10:3 var i(%0)
        lea rax, [rsp+0]
        ; 10:5 assign
        mov [rax], bl
        ; 11:3 if i < 5
        ; 11:7 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 11:11 int lit 5
        mov al, 5
        ; 11:9 <
        cmp bl, al
        setl cl
        and cl, 0xFF
        or cl, cl
        jz @else_3
        ; then
        jmp @while_2
        jmp @endif_3
        ; else
@else_3:
@endif_3:
        jmp @while_2_break
        jmp @while_2
@while_2_break:
        ; 17:2 while true
@while_4:
        ; 17:9 bool lit true
        mov al, 1
        or al, al
        jz @while_4_break
        ; while body
        ; return
        jmp @main_ret
        jmp @while_4
@while_4_break:
@main_ret:
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
