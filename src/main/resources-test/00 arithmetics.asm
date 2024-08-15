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
        sub rsp, 64
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
        ; @while_1_body
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
        lea rax, [rsp+72]
        mov rbx, [rax]
        ; 15:28 int lit 10
        mov rax, 10
        ; 15:26 mod
        push rdx
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rdx
        pop rdx
        ; 15:3 var remainder(%3)
        lea rax, [rsp+24]
        ; 15:3 assign
        mov [rax], rbx
        ; 16:12 read var number(%0)
        lea rax, [rsp+72]
        mov rbx, [rax]
        ; 16:21 int lit 10
        mov rax, 10
        ; 16:19 divide
        push rdx
        mov rdx, rax
        mov rax, rbx
        mov rbx, rdx
        cqo
        idiv rbx
        mov rbx, rax
        pop rdx
        ; 16:3 var number(%0)
        lea rax, [rsp+72]
        ; 16:10 assign
        mov [rax], rbx
        ; 17:18 read var remainder(%3)
        lea rax, [rsp+24]
        mov rbx, [rax]
        ; 17:30 int lit 48
        mov al, 48
        ; 17:28 add
        add bl, al
        ; 17:3 var digit(%4)
        lea rax, [rsp+32]
        ; 17:3 assign
        mov [rax], bl
        ; 18:17 read var digit(%4)
        lea rax, [rsp+32]
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
        lea rax, [rsp+72]
        mov rbx, [rax]
        ; 19:17 int lit 0
        mov rax, 0
        ; 19:14 ==
        cmp rbx, rax
        sete cl
        and cl, 0xFF
        or cl, cl
        jz @if_2_end
        ; @if_2_then
        jmp @while_1_break
@if_2_end:
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
        lea rax, [rsp+40]
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
        lea rax, [rsp+48]
        ; 23:37 assign
        mov [rax], rbx
        ; 23:2 call printStringLength
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
        lea rax, [rsp+56]
        mov rax, [rax]
        push rax
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printUint_ret:
        ; release space for local variables
        add rsp, 64
        ret

        ; void printIntLf
@printIntLf:
        ; reserve space for local variables
        sub rsp, 32
        ; 27:2 if number < 0
        ; 27:6 read var number(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 27:15 int lit 0
        mov rax, 0
        ; 27:13 <
        cmp rbx, rax
        setl cl
        and cl, 0xFF
        or cl, cl
        jz @if_3_end
        ; @if_3_then
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
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 29:12 neg
        neg rbx
        ; 29:3 var number(%0)
        lea rax, [rsp+40]
        ; 29:10 assign
        mov [rax], rbx
@if_3_end:
        ; 31:12 read var number(%0)
        lea rax, [rsp+40]
        mov rbx, [rax]
        ; 31:12 var $.2(%2)
        lea rax, [rsp+8]
        ; 31:12 assign
        mov [rax], rbx
        ; 31:2 call printUint
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; 32:12 int lit 10
        mov al, 10
        ; 32:12 var $.3(%3)
        lea rbx, [rsp+16]
        ; 32:12 assign
        mov [rbx], al
        ; 32:2 call printChar
        lea rax, [rsp+16]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
@printIntLf_ret:
        ; release space for local variables
        add rsp, 32
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

        ; void main
@main:
        ; reserve space for local variables
        sub rsp, 80
        ; 4:15 int lit 4
        mov al, 4
        ; 4:19 int lit 3
        mov bl, 3
        ; 4:17 multiply
        movsx rax, al
        movsx rbx, bl
        imul rax, rbx
        ; 4:23 int lit 2
        mov bl, 2
        ; 4:25 int lit 5
        mov cl, 5
        ; 4:24 multiply
        movsx rbx, bl
        movsx rcx, cl
        imul rbx, rcx
        ; 4:21 add
        add al, bl
        movzx bx, al
        ; 4:5 var foo(%0)
        lea rax, [rsp+0]
        ; 4:5 assign
        mov [rax], bx
        ; 5:15 read var foo(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        ; 5:21 read var foo(%0)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; 5:19 multiply
        movsx rbx, bx
        movsx rcx, cx
        imul rbx, rcx
        ; 5:5 var bar(%1)
        lea rax, [rsp+2]
        ; 5:5 assign
        mov [rax], bx
        ; 6:11 int lit 1
        mov ax, 1
        ; 6:5 var foo(%0)
        lea rbx, [rsp+0]
        ; 6:9 assign
        mov [rbx], ax
        ; 7:16 read var bar(%1)
        lea rax, [rsp+2]
        mov bx, [rax]
        ; 7:22 read var foo(%0)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; 7:20 add
        add bx, cx
        movzx rax, bx
        ; 7:20 var $.2(%2)
        lea rbx, [rsp+8]
        ; 7:20 assign
        mov [rbx], rax
        ; 7:5 call printIntLf
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 8:12 int lit 1
        mov al, 1
        ; 8:16 int lit 2
        mov bl, 2
        ; 8:14 add
        add al, bl
        ; 8:22 int lit 3
        mov bl, 3
        ; 8:26 int lit 4
        mov cl, 4
        ; 8:24 add
        add bl, cl
        ; 8:19 multiply
        movsx rax, al
        movsx rbx, bl
        imul rax, rbx
        movzx bx, al
        ; 8:5 var foo(%0)
        lea rax, [rsp+0]
        ; 8:9 assign
        mov [rax], bx
        ; 9:16 read var foo(%0)
        lea rax, [rsp+0]
        mov bx, [rax]
        movzx rax, bx
        ; 9:16 var $.3(%3)
        lea rbx, [rsp+16]
        ; 9:16 assign
        mov [rbx], rax
        ; 9:5 call printIntLf
        lea rax, [rsp+16]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 11:16 read var bazz(%4)
        lea rax, [rsp+24]
        mov bx, [rax]
        movzx rax, bx
        ; 11:16 var $.5(%5)
        lea rbx, [rsp+32]
        ; 11:16 assign
        mov [rbx], rax
        ; 11:5 call printIntLf
        lea rax, [rsp+32]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 13:16 int lit 1000
        mov ax, 1000
        ; 13:21 int lit 10
        mov bx, 10
        ; 13:20 divide
        movsx rax, ax
        movsx rbx, bx
        cqo
        push rdx
        idiv rbx
        pop rdx
        movzx rbx, ax
        ; 13:20 var $.6(%6)
        lea rax, [rsp+40]
        ; 13:20 assign
        mov [rax], rbx
        ; 13:5 call printIntLf
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 14:16 int lit 1000
        mov ax, 1000
        ; 14:23 int lit 256
        mov bx, 256
        ; 14:21 mod
        movsx rax, ax
        movsx rbx, bx
        cqo
        push rdx
        idiv rbx
        mov rax, rdx
        pop rdx
        movzx rbx, ax
        ; 14:21 var $.7(%7)
        lea rax, [rsp+48]
        ; 14:21 assign
        mov [rax], rbx
        ; 14:5 call printIntLf
        lea rax, [rsp+48]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 16:16 int lit 10
        mov al, 10
        ; 16:22 int lit 1
        mov bl, 1
        ; 16:19 shiftright
        push rcx
        mov rcx, rbx
        shr al, cl
        pop rcx
        movzx rbx, al
        ; 16:19 var $.8(%8)
        lea rax, [rsp+56]
        ; 16:19 assign
        mov [rax], rbx
        ; 16:5 call printIntLf
        lea rax, [rsp+56]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 17:16 int lit 9
        mov al, 9
        ; 17:21 int lit 2
        mov bl, 2
        ; 17:18 shiftright
        push rcx
        mov rcx, rbx
        shr al, cl
        pop rcx
        movzx rbx, al
        ; 17:18 var $.9(%9)
        lea rax, [rsp+64]
        ; 17:18 assign
        mov [rax], rbx
        ; 17:5 call printIntLf
        lea rax, [rsp+64]
        mov rax, [rax]
        push rax
          call @printIntLf
        add rsp, 8
        ; 18:16 int lit 1
        mov al, 1
        ; 18:21 int lit 2
        mov bl, 2
        ; 18:18 shiftleft
        push rcx
        mov rcx, rbx
        shl al, cl
        pop rcx
        movzx rbx, al
        ; 18:18 var $.10(%10)
        lea rax, [rsp+72]
        ; 18:18 assign
        mov [rax], rbx
        ; 18:5 call printIntLf
        lea rax, [rsp+72]
        mov rax, [rax]
        push rax
          call @printIntLf
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
