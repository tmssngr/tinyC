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
@for_1:
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
        jz @for_1_break
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
@for_1_continue:
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
        jmp @for_1
@for_1_break:
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

        ; void printBoard
@printBoard:
        ; reserve space for local variables
        sub rsp, 16
        ; 10:12 int lit 124
        mov al, 124
        ; 10:12 var $.0(%0)
        lea rbx, [rsp+0]
        ; 10:12 assign
        mov [rbx], al
        ; 10:2 call printChar
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 11:14 int lit 0
        mov al, 0
        ; 11:7 var i(%1)
        lea rbx, [rsp+1]
        ; 11:7 assign
        mov [rbx], al
        ; 11:2 for i < 30
@for_2:
        ; 11:17 read var i(%1)
        lea rax, [rsp+1]
        mov bl, [rax]
        ; 11:21 int lit 30
        mov al, 30
        ; 11:19 <
        cmp bl, al
        setb cl
        and cl, 0xFF
        or cl, cl
        jz @for_2_break
        ; for body
        ; 12:3 if [...] == 0
        ; 12:13 array board($0)
        ; 12:13 read var i(%1)
        lea rax, [rsp+1]
        mov bl, [rax]
        movzx rax, bl
        imul rax, 1
        lea rbx, [var0]
        add rbx, rax
        mov al, [rbx]
        ; 12:19 int lit 0
        mov bl, 0
        ; 12:16 ==
        cmp al, bl
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_3
        ; then
        ; 13:14 int lit 32
        mov al, 32
        ; 13:14 var $.2(%2)
        lea rbx, [rsp+2]
        ; 13:14 assign
        mov [rbx], al
        ; 13:4 call printChar
        lea rax, [rsp+2]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        jmp @endif_3
        ; else
@else_3:
        ; 16:14 int lit 42
        mov al, 42
        ; 16:14 var $.3(%3)
        lea rbx, [rsp+3]
        ; 16:14 assign
        mov [rbx], al
        ; 16:4 call printChar
        lea rax, [rsp+3]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
@endif_3:
@for_2_continue:
        ; 11:36 read var i(%1)
        lea rax, [rsp+1]
        mov bl, [rax]
        ; 11:40 int lit 1
        mov al, 1
        ; 11:38 add
        add bl, al
        ; 11:32 var i(%1)
        lea rax, [rsp+1]
        ; 11:34 assign
        mov [rax], bl
        jmp @for_2
@for_2_break:
        ; 19:14 string literal string_0
        lea rax, [string_0]
        ; 19:14 var $.4(%4)
        lea rbx, [rsp+8]
        ; 19:14 assign
        mov [rbx], rax
        ; 19:2 call printString
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
@printBoard_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; 23:14 int lit 0
        mov al, 0
        ; 23:7 var i(%0)
        lea rbx, [rsp+0]
        ; 23:7 assign
        mov [rbx], al
        ; 23:2 for i < 30
@for_4:
        ; 23:17 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 23:21 int lit 30
        mov al, 30
        ; 23:19 <
        cmp bl, al
        setb cl
        and cl, 0xFF
        or cl, cl
        jz @for_4_break
        ; for body
        ; 24:14 int lit 0
        mov al, 0
        ; 24:9 array board($0)
        ; 24:9 read var i(%0)
        lea rbx, [rsp+0]
        mov cl, [rbx]
        movzx rbx, cl
        imul rbx, 1
        lea rcx, [var0]
        add rcx, rbx
        ; 24:12 assign
        mov [rcx], al
@for_4_continue:
        ; 23:36 read var i(%0)
        lea rax, [rsp+0]
        mov bl, [rax]
        ; 23:40 int lit 1
        mov al, 1
        ; 23:38 add
        add bl, al
        ; 23:32 var i(%0)
        lea rax, [rsp+0]
        ; 23:34 assign
        mov [rax], bl
        jmp @for_4
@for_4_break:
        ; 26:25 int lit 1
        mov al, 1
        ; 26:18 array board($0)
        ; 26:8 int lit 30
        mov bl, 30
        ; 26:20 int lit 1
        mov cl, 1
        ; 26:18 sub
        sub bl, cl
        movzx rcx, bl
        imul rcx, 1
        lea rbx, [var0]
        add rbx, rcx
        ; 26:23 assign
        mov [rbx], al
        ; 28:2 call printBoard
        sub rsp, 8
          call @printBoard
        add rsp, 8
        ; 30:14 int lit 0
        mov al, 0
        ; 30:7 var i(%1)
        lea rbx, [rsp+1]
        ; 30:7 assign
        mov [rbx], al
        ; 30:2 for i < 30 - 2
@for_5:
        ; 30:17 read var i(%1)
        lea rax, [rsp+1]
        mov bl, [rax]
        ; 30:21 int lit 30
        mov al, 30
        ; 30:33 int lit 2
        mov cl, 2
        ; 30:31 sub
        sub al, cl
        ; 30:19 <
        cmp bl, al
        setb cl
        and cl, 0xFF
        or cl, cl
        jz @for_5_break
        ; for body
        ; 31:23 array board($0)
        ; 31:23 int lit 0
        mov rax, 0
        imul rax, 1
        lea rbx, [var0]
        add rbx, rax
        mov al, [rbx]
        ; 31:29 int lit 1
        mov bl, 1
        ; 31:26 shiftleft
        push rcx
        mov rcx, rbx
        shl al, cl
        pop rcx
        ; 31:40 array board($0)
        ; 31:40 int lit 1
        mov rbx, 1
        imul rbx, 1
        lea rcx, [var0]
        add rcx, rbx
        mov bl, [rcx]
        ; 31:32 or
        or al, bl
        ; 31:3 var pattern(%2)
        lea rbx, [rsp+2]
        ; 31:3 assign
        mov [rbx], al
        ; 32:15 int lit 1
        mov al, 1
        ; 32:8 var j(%3)
        lea rbx, [rsp+3]
        ; 32:8 assign
        mov [rbx], al
        ; 32:3 for j < 30 - 1
@for_6:
        ; 32:18 read var j(%3)
        lea rax, [rsp+3]
        mov bl, [rax]
        ; 32:22 int lit 30
        mov al, 30
        ; 32:34 int lit 1
        mov cl, 1
        ; 32:32 sub
        sub al, cl
        ; 32:20 <
        cmp bl, al
        setb cl
        and cl, 0xFF
        or cl, cl
        jz @for_6_break
        ; for body
        ; 33:16 read var pattern(%2)
        lea rax, [rsp+2]
        mov bl, [rax]
        ; 33:27 int lit 1
        mov al, 1
        ; 33:24 shiftleft
        push rcx
        mov rcx, rax
        shl bl, cl
        pop rcx
        ; 33:32 int lit 7
        mov al, 7
        ; 33:30 and
        and bl, al
        ; 33:45 array board($0)
        ; 33:43 read var j(%3)
        lea rax, [rsp+3]
        mov cl, [rax]
        ; 33:47 int lit 1
        mov al, 1
        ; 33:45 add
        add cl, al
        movzx rax, cl
        imul rax, 1
        lea rcx, [var0]
        add rcx, rax
        mov al, [rcx]
        ; 33:35 or
        or bl, al
        ; 33:4 var pattern(%2)
        lea rax, [rsp+2]
        ; 33:12 assign
        mov [rax], bl
        ; 34:16 int lit 110
        mov al, 110
        ; 34:23 read var pattern(%2)
        lea rbx, [rsp+2]
        mov cl, [rbx]
        ; 34:20 shiftright
        shr al, cl
        ; 34:34 int lit 1
        mov bl, 1
        ; 34:32 and
        and al, bl
        ; 34:10 array board($0)
        ; 34:10 read var j(%3)
        lea rbx, [rsp+3]
        mov cl, [rbx]
        movzx rbx, cl
        imul rbx, 1
        lea rcx, [var0]
        add rcx, rbx
        ; 34:13 assign
        mov [rcx], al
@for_6_continue:
        ; 32:41 read var j(%3)
        lea rax, [rsp+3]
        mov bl, [rax]
        ; 32:45 int lit 1
        mov al, 1
        ; 32:43 add
        add bl, al
        ; 32:37 var j(%3)
        lea rax, [rsp+3]
        ; 32:39 assign
        mov [rax], bl
        jmp @for_6
@for_6_break:
        ; 36:3 call printBoard
        sub rsp, 8
          call @printBoard
        add rsp, 8
@for_5_continue:
        ; 30:40 read var i(%1)
        lea rax, [rsp+1]
        mov bl, [rax]
        ; 30:44 int lit 1
        mov al, 1
        ; 30:42 add
        add bl, al
        ; 30:36 var i(%1)
        lea rax, [rsp+1]
        ; 30:38 assign
        mov [rax], bl
        jmp @for_5
@for_5_break:
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
        ; variable 0: board (240)
        var0 rb 240

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

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
