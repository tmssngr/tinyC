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
        ; begin initialize global variables
        ; 5:8 int lit 0
        mov al, 0
        ; 5:1 var i($0)
        lea rbx, [var0]
        ; 5:1 assign
        mov [rbx], al
        ; end initialize global variables
        ; 2:10 call next
        sub rsp, 8
          call @next
        add rsp, 8
        ; 2:10 var $.0(%0)
        lea rbx, [rsp+0]
        ; 2:10 assign
        mov [rbx], al
        ; 2:18 call next
        sub rsp, 8
          call @next
        add rsp, 8
        ; 2:18 var $.1(%1)
        lea rbx, [rsp+1]
        ; 2:18 assign
        mov [rbx], al
        ; 2:26 call next
        sub rsp, 8
          call @next
        add rsp, 8
        ; 2:26 var $.2(%2)
        lea rbx, [rsp+2]
        ; 2:26 assign
        mov [rbx], al
        ; 2:34 call next
        sub rsp, 8
          call @next
        add rsp, 8
        ; 2:34 var $.3(%3)
        lea rbx, [rsp+3]
        ; 2:34 assign
        mov [rbx], al
        ; 2:42 call next
        sub rsp, 8
          call @next
        add rsp, 8
        ; 2:42 var $.4(%4)
        lea rbx, [rsp+4]
        ; 2:42 assign
        mov [rbx], al
        ; 2:2 call doPrint
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
        lea rax, [rsp+9]
        mov al, [rax]
        push rax
        lea rax, [rsp+18]
        mov al, [rax]
        push rax
        lea rax, [rsp+27]
        mov al, [rax]
        push rax
        lea rax, [rsp+36]
        mov al, [rax]
        push rax
          call @doPrint
        add rsp, 40
@main_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 next
@next:
        ; 8:6 read var i($0)
        lea rax, [var0]
        mov bl, [rax]
        ; 8:10 int lit 1
        mov al, 1
        ; 8:8 add
        add bl, al
        ; 8:2 var i($0)
        lea rax, [var0]
        ; 8:4 assign
        mov [rax], bl
        ; 9:9 return i
        ; 9:9 read var i($0)
        lea rax, [var0]
        mov bl, [rax]
        mov rax, rbx
        jmp @next_ret
@next_ret:
        ret

        ; void doPrint
@doPrint:
        ; reserve space for local variables
        sub rsp, 48
        ; 13:8 read var a(%0)
        lea rax, [rsp+88]
        mov bl, [rax]
        movzx rax, bl
        ; 13:8 var $.5(%5)
        lea rbx, [rsp+0]
        ; 13:8 assign
        mov [rbx], rax
        ; 13:2 call print
        lea rax, [rsp+0]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 14:8 read var b(%1)
        lea rax, [rsp+80]
        mov bl, [rax]
        movzx rax, bl
        ; 14:8 var $.6(%6)
        lea rbx, [rsp+8]
        ; 14:8 assign
        mov [rbx], rax
        ; 14:2 call print
        lea rax, [rsp+8]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 15:8 read var c(%2)
        lea rax, [rsp+72]
        mov bl, [rax]
        movzx rax, bl
        ; 15:8 var $.7(%7)
        lea rbx, [rsp+16]
        ; 15:8 assign
        mov [rbx], rax
        ; 15:2 call print
        lea rax, [rsp+16]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 16:8 read var d(%3)
        lea rax, [rsp+64]
        mov bl, [rax]
        movzx rax, bl
        ; 16:8 var $.8(%8)
        lea rbx, [rsp+24]
        ; 16:8 assign
        mov [rbx], rax
        ; 16:2 call print
        lea rax, [rsp+24]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
        ; 17:8 read var e(%4)
        lea rax, [rsp+56]
        mov bl, [rax]
        movzx rax, bl
        ; 17:8 var $.9(%9)
        lea rbx, [rsp+32]
        ; 17:8 assign
        mov [rbx], rax
        ; 17:2 call print
        lea rax, [rsp+32]
        mov rcx, [rax]
        sub rsp, 8
          call __printUint
          mov rcx, 0x0a
          call __emit
        add rsp, 8
@doPrint_ret:
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
        ; variable 0: i (1)
        var0 rb 1

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
