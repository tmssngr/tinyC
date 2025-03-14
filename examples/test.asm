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

        ; void printString
@printString:
        ; reserve space for local variables
        sub rsp, 32
        ; 2:22 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 2:22 var $.2(%2)
        lea rax, [rsp+8]
        ; 2:22 assign
        mov [rax], rbx
        ; 2:15 call strlen
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        ; 2:2 var length(%1)
        lea rbx, [rsp+0]
        ; 2:2 assign
        mov [rbx], rax
        ; 3:20 read var str(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 3:20 var $.3(%3)
        lea rax, [rsp+16]
        ; 3:20 assign
        mov [rax], rbx
        ; 3:2 call printStringLength
        lea rax, [rsp+16]
        mov rax, [rax]
        push rax
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printString_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void printChar
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; 7:21 var chr(%0)
        lea rax, [rsp+24]
        ; 7:20 var $.1(%1)
        lea rbx, [rsp+0]
        ; 7:20 assign
        mov [rbx], rax
        ; 7:26 int lit 1
        mov rax, 1
        ; 7:26 var $.2(%2)
        lea rbx, [rsp+8]
        ; 7:26 assign
        mov [rbx], rax
        ; 7:2 call printStringLength
        lea rax, [rsp+0]
        mov rax, [rax]
        push rax
        lea rax, [rsp+16]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
@printUint:
        ; reserve space for local variables
        sub rsp, 48
        ; 12:11 int lit 20
        mov al, 20
        ; 12:2 var pos(%2)
        lea rbx, [rsp+20]
        ; 12:2 assign
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; 13:9 bool lit true
        mov al, 1
        or al, al
        jz @while_1_break
        ; while body
        ; 14:9 read var pos(%2)
        lea rax, [rsp+20]
        mov bl, [rax]
        ; 14:15 int lit 1
        mov al, 1
        ; 14:13 sub
        sub bl, al
        ; 14:3 var pos(%2)
        lea rax, [rsp+20]
        ; 14:7 assign
        mov [rax], bl
        ; 15:19 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 15:28 int lit 10
        mov rax, 10
        ; 15:26 mod
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rdx
        ; 15:3 var remainder(%3)
        lea rax, [rsp+21]
        ; 15:3 assign
        mov [rax], rbx
        ; 16:12 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 16:21 int lit 10
        mov rax, 10
        ; 16:19 divide
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rax
        ; 16:3 var number(%0)
        lea rax, [rsp+56]
        ; 16:10 assign
        mov [rax], rbx
        ; 17:18 read var remainder(%3)
        lea rax, [rsp+21]
        mov rbx, [rax]
        ; 17:30 int lit 48
        mov al, 48
        ; 17:28 add
        add bl, al
        ; 17:3 var digit(%4)
        lea rax, [rsp+29]
        ; 17:3 assign
        mov [rax], bl
        ; 18:17 read var digit(%4)
        lea rax, [rsp+29]
        mov bl, [rax]
        ; 18:10 array buffer(%1)
        ; 18:10 read var pos(%2)
        lea rax, [rsp+20]
        mov cl, [rax]
        movzx rax, cl
        imul rax, 1
        lea rcx, [rsp+0]
        add rcx, rax
        ; 18:15 assign
        mov [rcx], bl
        ; 19:3 if number == 0
        ; 19:7 read var number(%0)
        lea rax, [rsp+56]
        mov rbx, [rax]
        ; 19:17 int lit 0
        mov rax, 0
        ; 19:14 ==
        cmp rbx, rax
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_2
        ; then
        jmp @while_1_break
        jmp @endif_2
        ; else
@else_2:
@endif_2:
        jmp @while_1
@while_1_break:
        ; 23:28 array buffer(%1)
        ; 23:28 read var pos(%2)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rax, bl
        imul rax, 1
        lea rbx, [rsp+0]
        add rbx, rax
        ; 23:20 var $.5(%5)
        lea rax, [rsp+30]
        ; 23:20 assign
        mov [rax], rbx
        ; 23:34 int lit 20
        mov al, 20
        ; 23:39 read var pos(%2)
        lea rbx, [rsp+20]
        mov cl, [rbx]
        ; 23:37 sub
        sub al, cl
        movzx rbx, al
        ; 23:37 var $.6(%6)
        lea rax, [rsp+38]
        ; 23:37 assign
        mov [rax], rbx
        ; 23:2 call printStringLength
        lea rax, [rsp+30]
        mov rax, [rax]
        push rax
        lea rax, [rsp+46]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printUint_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void printIntLf
@printIntLf:
        ; reserve space for local variables
        sub rsp, 16
        ; 27:2 if number < 0
        ; 27:6 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 27:15 int lit 0
        mov rax, 0
        ; 27:13 <
        cmp rbx, rax
        setl cl
        and cl, 0xFF
        or cl, cl
        jz @else_3
        ; then
        ; 28:13 int lit 45
        mov al, 45
        ; 28:13 var $.1(%1)
        lea rbx, [rsp+0]
        ; 28:13 assign
        mov [rbx], al
        ; 28:3 call printChar
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 29:13 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 29:12 neg
        neg rbx
        ; 29:3 var number(%0)
        lea rax, [rsp+24]
        ; 29:10 assign
        mov [rax], rbx
        jmp @endif_3
        ; else
@else_3:
@endif_3:
        ; 31:12 read var number(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 31:12 var $.2(%2)
        lea rax, [rsp+1]
        ; 31:12 assign
        mov [rax], rbx
        ; 31:2 call printUint
        lea rax, [rsp+1]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; 32:12 int lit 10
        mov al, 10
        ; 32:12 var $.3(%3)
        lea rbx, [rsp+9]
        ; 32:12 assign
        mov [rbx], al
        ; 32:2 call printChar
        lea rax, [rsp+9]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
@printIntLf_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; 36:15 int lit 0
        mov rax, 0
        ; 36:2 var length(%1)
        lea rbx, [rsp+0]
        ; 36:2 assign
        mov [rbx], rax
        ; 37:2 for *str != 0
@for_4:
        ; 37:10 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 37:9 deref
        mov al, [rbx]
        ; 37:17 int lit 0
        mov bl, 0
        ; 37:14 !=
        cmp al, bl
        setne cl
        and cl, 0xFF
        or cl, cl
        jz @for_4_break
        ; for body
        ; 38:12 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        ; 38:21 int lit 1
        mov rax, 1
        ; 38:19 add
        add rbx, rax
        ; 38:3 var length(%1)
        lea rax, [rsp+0]
        ; 38:10 assign
        mov [rax], rbx
@for_4_continue:
        ; 37:26 read var str(%0)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 37:32 int lit 1
        mov rax, 1
        ; 37:30 add
        add rbx, rax
        ; 37:20 var str(%0)
        lea rax, [rsp+24]
        ; 37:24 assign
        mov [rax], rbx
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; 40:9 read var length(%1)
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        jmp @strlen_ret
@strlen_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength
@printStringLength:
        mov     rdi, rsp

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     rdx, [rdi+18h]
        mov     r8, [rdi+10h]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

        ; u8 getChar
@getChar:
        sub    rsp, 28h
          call [_getch]
        add    rsp, 28h
        ret

        ; void setCursor
@setCursor:
        mov     rdi, rsp
        and     spl, 0xf0

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     dx, [rdi+10h]
        shl     rdx, 16
        mov     dx, [rdi+18h]
        sub     rsp, 20h
          call   [SetConsoleCursorPosition]
        mov     rsp, rdi
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; 4:11 call getChar
        sub rsp, 8
          call @getChar
        add rsp, 8
        ; 4:2 var chr(%0)
        lea rbx, [rsp+0]
        ; 4:2 assign
        mov [rbx], al
        ; 5:12 int lit 0
        mov ax, 0
        ; 5:12 var $.1(%1)
        lea rbx, [rsp+1]
        ; 5:12 assign
        mov [rbx], ax
        ; 5:15 int lit 0
        mov ax, 0
        ; 5:15 var $.2(%2)
        lea rbx, [rsp+3]
        ; 5:15 assign
        mov [rbx], ax
        ; 5:2 call setCursor
        lea rax, [rsp+1]
        mov ax, [rax]
        push rax
        lea rax, [rsp+11]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @setCursor
        add rsp, 24
        ; 6:13 read var chr(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rax, bl
        ; 6:13 var $.3(%3)
        lea rbx, [rsp+5]
        ; 6:13 assign
        mov [rbx], rax
        ; 6:2 call printIntLf
        lea rax, [rsp+5]
        mov rax, [rax]
        push rax
          call @printIntLf
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
