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
        ;   rsp+8: arg chr
@printChar:
        ; addrof r.0(0@register,u8*), chr(0@argument,u8)
        lea rax, [rsp+8]
        mov rcx, rax
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; call _, printStringLength [r.0(0@register,u8*), r.1(1@register,i64)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
        ret

        ; void printUint
        ;   rsp+40: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 32
        ; const r.0(0@register,u8), 20
        mov cl, 20
        ; 13:2 while true
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+20]
        mov [rbx], cl
@while_1:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), pos(2@function,u8)
        lea rbx, [rsp+20]
        mov dl, [rbx]
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r.1(1@register,i64), 10
        mov rdx, 10
        ; copy r.2(2@register,i64), number(0@argument,i64)
        lea rbx, [rsp+40]
        mov r9, [rbx]
        ; mod r.1(1@register,i64), r.2(2@register,i64), r.1(1@register,i64)
        mov rax, r9
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r.3(3@register,i64), 10
        mov r10, 10
        ; div r.2(2@register,i64), r.2(2@register,i64), r.3(3@register,i64)
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r.1(1@register,u8), r.1(1@register,i64)
        ; const r.3(3@register,u8), 48
        mov r10b, 48
        ; add r.1(1@register,u8), r.1(1@register,u8), r.3(3@register,u8)
        add dl, r10b
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+20]
        mov [rbx], cl
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; array r.0(0@register,u8*), buffer(1@function,u8*) + r.0(0@register,i64)
        lea rax, [rsp+0]
        add rcx, rax
        ; store [r.0(0@register,u8*)], r.1(1@register,u8)
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; copy number(0@argument,i64), r.2(2@register,i64)
        lea rbx, [rsp+40]
        mov [rbx], r9
        ; equals r.0(0@register,bool), r.2(2@register,i64), r.0(0@register,i64)
        cmp r9, rcx
        sete cl
        ; branch r.0(0@register,bool), false, @if_2_end
        or cl, cl
        jz @if_2_end
        ; @if_2_then
@if_2_then:
        ; jump @while_1_break
        jmp @while_1_break
@if_2_end:
        ; jump @while_1
        jmp @while_1
@while_1_break:
        ; copy r.0(0@register,u8), pos(2@function,u8)
        lea rbx, [rsp+20]
        mov cl, [rbx]
        ; cast r.1(1@register,i64), r.0(0@register,u8)
        movzx rdx, cl
        ; addrof r.1(1@register,u8*), [buffer(1@function,u8*) + r.1(1@register,i64)]
        lea rax, [rsp+0]
        add rdx, rax
        ; const r.2(2@register,u8), 20
        mov r9b, 20
        ; sub r.0(0@register,u8), r.2(2@register,u8), r.0(0@register,u8)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printStringLength [r.1(1@register,u8*), r.0(0@register,i64)]
        push rdx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printUint_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void printIntLf
        ;   rsp+8: arg number
@printIntLf:
        ; 27:2 if number < 0
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; copy r.1(1@register,i64), number(0@argument,i64)
        lea rbx, [rsp+8]
        mov rdx, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,i64), r.0(0@register,i64)
        cmp rdx, rcx
        setl cl
        ; branch r.0(0@register,bool), false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; @if_3_then
@if_3_then:
        ; const r.0(0@register,u8), 45
        mov cl, 45
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; copy r.0(0@register,i64), number(0@argument,i64)
        lea rbx, [rsp+8]
        mov rcx, [rbx]
        ; neg r.0(0@register,i64), r.0(0@register,i64)
        neg rcx
        ; copy number(0@argument,i64), r.0(0@register,i64)
        lea rbx, [rsp+8]
        mov [rbx], rcx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r.0(0@register,u8), 10
        mov cl, 10
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
@printIntLf_ret:
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
        ;   rsp+0: var t.0
        ;   rsp+1: var t.1
        ;   rsp+2: var t.2
        ;   rsp+3: var t.3
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; begin initialize global variables
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; end initialize global variables
        ; copy i(0@global,u8), r.0(0@register,u8)
        lea rbx, [var_0]
        mov [rbx], cl
        ; call r.0(0@register,u8), next, []
        sub rsp, 8
          call @next
        add rsp, 8
        mov cl, al
        ; copy t.0(0@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+0]
        mov [rbx], cl
        ; call r.0(0@register,u8), next, []
        sub rsp, 8
          call @next
        add rsp, 8
        mov cl, al
        ; copy t.1(1@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+1]
        mov [rbx], cl
        ; call r.0(0@register,u8), next, []
        sub rsp, 8
          call @next
        add rsp, 8
        mov cl, al
        ; copy t.2(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+2]
        mov [rbx], cl
        ; call r.0(0@register,u8), next, []
        sub rsp, 8
          call @next
        add rsp, 8
        mov cl, al
        ; copy t.3(3@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+3]
        mov [rbx], cl
        ; call r.0(0@register,u8), next, []
        sub rsp, 8
          call @next
        add rsp, 8
        mov cl, al
        ; call _, doPrint [t.0(0@function,u8), t.1(1@function,u8), t.2(2@function,u8), t.3(3@function,u8), r.0(0@register,u8)]
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
        push rcx
          call @doPrint
        add rsp, 40
@main_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 next
@next:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), i(0@global,u8)
        lea rbx, [var_0]
        mov dl, [rbx]
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        add al, cl
        mov cl, al
        ; 11:9 return i
        ; copy i(0@global,u8), r.0(0@register,u8)
        lea rbx, [var_0]
        mov [rbx], cl
        ; ret r.0(0@register,u8)
        mov rax, rcx
@next_ret:
        ret

        ; void doPrint
        ;   rsp+40: arg a
        ;   rsp+32: arg b
        ;   rsp+24: arg c
        ;   rsp+16: arg d
        ;   rsp+8: arg e
@doPrint:
        ; copy r.0(0@register,u8), a(0@argument,u8)
        lea rbx, [rsp+40]
        mov cl, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), b(1@argument,u8)
        lea rbx, [rsp+32]
        mov cl, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), c(2@argument,u8)
        lea rbx, [rsp+24]
        mov cl, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), d(3@argument,u8)
        lea rbx, [rsp+16]
        mov cl, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), e(4@argument,u8)
        lea rbx, [rsp+8]
        mov cl, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
@doPrint_ret:
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
        ; variable 0: i (1)
        var_0 rb 1

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
