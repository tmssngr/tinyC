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
          call _main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
_printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@u8[t.1, 1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        mov  rax, 1
        push rax
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+88: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+64: var t.9
        ;   rsp+72: var t.10
        ;   rsp+73: var t.11
_printUint@i64:
        ; reserve space for local variables
        sub rsp, 80
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 28:2 while true
_while_1:
        ; sub pos, 1
        lea rax, [rsp+20]
        mov bl, [rax]
        sub bl, 1
        lea rax, [rsp+20]
        mov [rax], bl
        ; move remainder, number
        lea rax, [rsp+88]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, 10
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+24]
        mov [rcx], rbx
        ; div number, 10
        lea rax, [rsp+88]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+88]
        mov [rcx], rbx
        ; cast t.5(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        ; move digit, t.5
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, 48
        lea rax, [rsp+32]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.7(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+48]
        mov [rax], rbx
        ; addrof t.6, buffer
        lea rax, [rsp+0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6, t.7
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; store [t.6], digit
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 34:3 if number == 0
        ; branch number notequals 0: while_1, while_1_break
        lea rax, [rsp+88]
        mov rbx, [rax]
        cmp rbx, 0
        jne _while_1
        ; cast t.9(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+64]
        mov [rax], rbx
        ; addrof t.8, buffer
        lea rax, [rsp+0]
        lea rbx, [rsp+56]
        mov [rbx], rax
        ; add t.8, t.9
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+56]
        mov [rax], rbx
        ; const t.11, 20
        mov al, 20
        lea rbx, [rsp+73]
        mov [rbx], al
        ; move t.10, t.11
        lea rax, [rsp+73]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov [rax], bl
        ; sub t.10, pos
        lea rax, [rsp+72]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+72]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.8, t.10]
        lea rax, [rsp+56]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+80]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 80
        ret

        ; void printIntLf@u8
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
_printIntLf@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
_printIntLf@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i64
        ;   rsp+8: arg number
_printIntLf@i64:
        ; branch number gteq 0: if_3_end, if_3_then
        lea rax, [rsp+8]
        mov rbx, [rax]
        cmp rbx, 0
        jge _if_3_end
        ; call printChar@u8[45]
        mov  rax, 45
        push rax
          call _printChar@u8
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+8]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+8]
        mov [rax], rbx
_if_3_end:
        ; call printUint@i64[number]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call _printUint@i64
        add rsp, 8
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
          call _printChar@u8
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2
_printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void testIf@u8
        ;   rsp+72: arg a
        ;   rsp+0: var b
        ;   rsp+8: var b_ref
        ;   rsp+16: var t.3
        ;   rsp+24: var a.4
        ;   rsp+32: var t.5
        ;   rsp+40: var a.6
        ;   rsp+48: var t.7
_testIf@u8:
        ; reserve space for local variables
        sub rsp, 64
        ; const t.3, 1
        mov al, 1
        lea rbx, [rsp+16]
        mov [rbx], al
        ; addrof a.4, b
        lea rax, [rsp+0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; store [a.4], t.3
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov cl, [rax]
        mov [rbx], cl
        ; addrof b_ref, b
        lea rax, [rsp+0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; 6:2 if a == 0
        ; branch a notequals 0: if_4_end, if_4_then
        lea rax, [rsp+72]
        mov bl, [rax]
        cmp bl, 0
        jne _if_4_end
        ; load t.5, [b_ref]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+32]
        mov [rbx], al
        ; call printIntLf@u8[t.5]
        lea rax, [rsp+32]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
_if_4_end:
        ; addrof a.6, b
        lea rax, [rsp+0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; load t.7, [a.6]
        lea rax, [rsp+40]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+48]
        mov [rbx], al
        ; call printIntLf@u8[t.7]
        lea rax, [rsp+48]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 64
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+8: var b
        ;   rsp+16: var c
        ;   rsp+24: var d
        ;   rsp+32: var t.4
        ;   rsp+40: var a.5
        ;   rsp+48: var a.6
        ;   rsp+56: var t.7
        ;   rsp+58: var t.8
        ;   rsp+60: var t.9
        ;   rsp+64: var a.10
        ;   rsp+72: var a.11
        ;   rsp+80: var t.12
        ;   rsp+82: var t.13
        ;   rsp+84: var t.14
        ;   rsp+88: var a.15
        ;   rsp+96: var t.16
_main:
        ; reserve space for local variables
        sub rsp, 112
        ; const t.4, 10
        mov ax, 10
        lea rbx, [rsp+32]
        mov [rbx], ax
        ; addrof a.5, a
        lea rax, [rsp+0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; store [a.5], t.4
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cx, [rax]
        mov [rbx], cx
        ; addrof a.6, a
        lea rax, [rsp+0]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; load t.7, [a.6]
        lea rax, [rsp+48]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+56]
        mov [rbx], ax
        ; call printIntLf@i16[t.7]
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; addrof b, a
        lea rax, [rsp+0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; load t.9, [b]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+60]
        mov [rbx], ax
        ; move t.8, t.9
        lea rax, [rsp+60]
        mov bx, [rax]
        lea rax, [rsp+58]
        mov [rax], bx
        ; sub t.8, 1
        lea rax, [rsp+58]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+58]
        mov [rax], bx
        ; addrof a.10, c
        lea rax, [rsp+16]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; store [a.10], t.8
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+58]
        mov cx, [rax]
        mov [rbx], cx
        ; addrof a.11, c
        lea rax, [rsp+16]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; load t.12, [a.11]
        lea rax, [rsp+72]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+80]
        mov [rbx], ax
        ; call printIntLf@i16[t.12]
        lea rax, [rsp+80]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; addrof d, c
        lea rax, [rsp+16]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; load t.14, [d]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+84]
        mov [rbx], ax
        ; move t.13, t.14
        lea rax, [rsp+84]
        mov bx, [rax]
        lea rax, [rsp+82]
        mov [rax], bx
        ; sub t.13, 1
        lea rax, [rsp+82]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+82]
        mov [rax], bx
        ; store [d], t.13
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+82]
        mov cx, [rax]
        mov [rbx], cx
        ; addrof a.15, c
        lea rax, [rsp+16]
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; load t.16, [a.15]
        lea rax, [rsp+88]
        mov rbx, [rax]
        mov ax, [rbx]
        lea rbx, [rsp+96]
        mov [rbx], ax
        ; call printIntLf@i16[t.16]
        lea rax, [rsp+96]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; call testIf@u8[1]
        mov  rax, 1
        push rax
          call _testIf@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 112
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
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
