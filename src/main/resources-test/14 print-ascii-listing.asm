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

        ; void printNibble
@printNibble:
        ; reserve space for local variables
        sub rsp, 16
        ; 4:6 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 4:10 int lit 15
        mov al, 15
        ; 4:8 and
        and bl, al
        ; 4:2 var x(%0)
        lea rax, [rsp+24]
        ; 4:4 assign
        mov [rax], bl
        ; 5:2 if x > 9
        ; 5:6 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 5:10 int lit 9
        mov al, 9
        ; 5:8 >
        cmp bl, al
        seta cl
        and cl, 0xFF
        or cl, cl
        jz @else_2
        ; then
        ; 6:7 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 6:12 int lit 65
        mov al, 65
        ; 6:18 int lit 57
        mov cl, 57
        ; 6:16 sub
        sub al, cl
        ; 6:24 int lit 1
        mov cl, 1
        ; 6:22 sub
        sub al, cl
        ; 6:9 add
        add bl, al
        ; 6:3 var x(%0)
        lea rax, [rsp+24]
        ; 6:5 assign
        mov [rax], bl
        jmp @endif_2
        ; else
@else_2:
@endif_2:
        ; 8:6 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 8:10 int lit 48
        mov al, 48
        ; 8:8 add
        add bl, al
        ; 8:2 var x(%0)
        lea rax, [rsp+24]
        ; 8:4 assign
        mov [rax], bl
        ; 9:12 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 9:12 var $.1(%1)
        lea rax, [rsp+0]
        ; 9:12 assign
        mov [rax], bl
        ; 9:2 call printChar
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
@printNibble_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printHex2
@printHex2:
        ; reserve space for local variables
        sub rsp, 16
        ; 13:14 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 13:18 int lit 16
        mov al, 16
        ; 13:16 divide
        movsx rax, al
        movsx rbx, bl
        push rdx
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rax
        pop rdx
        ; 13:16 var $.1(%1)
        lea rax, [rsp+0]
        ; 13:16 assign
        mov [rax], bl
        ; 13:2 call printNibble
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
        ; 14:14 read var x(%0)
        lea rax, [rsp+24]
        mov bl, [rax]
        ; 14:14 var $.2(%2)
        lea rax, [rsp+1]
        ; 14:14 assign
        mov [rax], bl
        ; 14:2 call printNibble
        lea rax, [rsp+1]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
@printHex2_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; 18:14 string literal string_0
        lea rax, [string_0]
        ; 18:14 var $.0(%0)
        lea rbx, [rsp+0]
        ; 18:14 assign
        mov [rbx], rax
        ; 18:2 call printString
        lea rax, [rsp+0]
        mov rax, [rax]
        push rax
          call @printString
        add rsp, 8
        ; 19:14 int lit 0
        mov al, 0
        ; 19:7 var i(%1)
        lea rbx, [rsp+8]
        ; 19:7 assign
        mov [rbx], al
        ; 19:2 for i < 16
@for_3:
        ; 19:17 read var i(%1)
        lea rax, [rsp+8]
        mov bl, [rax]
        ; 19:21 int lit 16
        mov al, 16
        ; 19:19 <
        cmp bl, al
        setb cl
        and cl, 0xFF
        or cl, cl
        jz @for_3_break
        ; for body
        ; 20:3 if i & 7 == 0
        ; 20:8 read var i(%1)
        lea rax, [rsp+8]
        mov bl, [rax]
        ; 20:12 int lit 7
        mov al, 7
        ; 20:10 and
        and bl, al
        ; 20:18 int lit 0
        mov al, 0
        ; 20:15 ==
        cmp bl, al
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_4
        ; then
        ; 21:14 int lit 32
        mov al, 32
        ; 21:14 var $.2(%2)
        lea rbx, [rsp+9]
        ; 21:14 assign
        mov [rbx], al
        ; 21:4 call printChar
        lea rax, [rsp+9]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        jmp @endif_4
        ; else
@else_4:
@endif_4:
        ; 23:3 call printNibble
        lea rax, [rsp+8]
        mov al, [rax]
        push rax
          call @printNibble
        add rsp, 8
@for_3_continue:
        ; 19:31 read var i(%1)
        lea rax, [rsp+8]
        mov bl, [rax]
        ; 19:35 int lit 1
        mov al, 1
        ; 19:33 add
        add bl, al
        ; 19:27 var i(%1)
        lea rax, [rsp+8]
        ; 19:29 assign
        mov [rax], bl
        jmp @for_3
@for_3_break:
        ; 25:12 int lit 10
        mov al, 10
        ; 25:12 var $.3(%3)
        lea rbx, [rsp+10]
        ; 25:12 assign
        mov [rbx], al
        ; 25:2 call printChar
        lea rax, [rsp+10]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 27:14 int lit 32
        mov al, 32
        ; 27:7 var i(%4)
        lea rbx, [rsp+11]
        ; 27:7 assign
        mov [rbx], al
        ; 27:2 for i < 128
@for_5:
        ; 27:20 read var i(%4)
        lea rax, [rsp+11]
        mov bl, [rax]
        ; 27:24 int lit 128
        mov al, 128
        ; 27:22 <
        cmp bl, al
        setb cl
        and cl, 0xFF
        or cl, cl
        jz @for_5_break
        ; for body
        ; 28:3 if i & 15 == 0
        ; 28:8 read var i(%4)
        lea rax, [rsp+11]
        mov bl, [rax]
        ; 28:12 int lit 15
        mov al, 15
        ; 28:10 and
        and bl, al
        ; 28:20 int lit 0
        mov al, 0
        ; 28:17 ==
        cmp bl, al
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_6
        ; then
        ; 29:4 call printHex2
        lea rax, [rsp+11]
        mov al, [rax]
        push rax
          call @printHex2
        add rsp, 8
        jmp @endif_6
        ; else
@else_6:
@endif_6:
        ; 31:3 if i & 7 == 0
        ; 31:8 read var i(%4)
        lea rax, [rsp+11]
        mov bl, [rax]
        ; 31:12 int lit 7
        mov al, 7
        ; 31:10 and
        and bl, al
        ; 31:18 int lit 0
        mov al, 0
        ; 31:15 ==
        cmp bl, al
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_7
        ; then
        ; 32:14 int lit 32
        mov al, 32
        ; 32:14 var $.5(%5)
        lea rbx, [rsp+12]
        ; 32:14 assign
        mov [rbx], al
        ; 32:4 call printChar
        lea rax, [rsp+12]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        jmp @endif_7
        ; else
@else_7:
@endif_7:
        ; 34:3 call printChar
        lea rax, [rsp+11]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; 35:3 if i & 15 == 15
        ; 35:8 read var i(%4)
        lea rax, [rsp+11]
        mov bl, [rax]
        ; 35:12 int lit 15
        mov al, 15
        ; 35:10 and
        and bl, al
        ; 35:20 int lit 15
        mov al, 15
        ; 35:17 ==
        cmp bl, al
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @else_8
        ; then
        ; 36:14 int lit 10
        mov al, 10
        ; 36:14 var $.6(%6)
        lea rbx, [rsp+13]
        ; 36:14 assign
        mov [rbx], al
        ; 36:4 call printChar
        lea rax, [rsp+13]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        jmp @endif_8
        ; else
@else_8:
@endif_8:
@for_5_continue:
        ; 27:34 read var i(%4)
        lea rax, [rsp+11]
        mov bl, [rax]
        ; 27:38 int lit 1
        mov al, 1
        ; 27:36 add
        add bl, al
        ; 27:30 var i(%4)
        lea rax, [rsp+11]
        ; 27:32 assign
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

section '.data' data readable
        string_0 db ' x', 0x00

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
