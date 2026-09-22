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

        ; void printString@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length.1
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length.1 = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length.1]
        lea rax, [rsp+24]
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

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length.1
        ;   rsp+8: var str.1
        ;   rsp+16: var length.2
        ;   rsp+24: var t.2.1
        ;   rsp+32: var length.3
        ;   rsp+40: var str.2
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length.1, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        ; move str.1, str
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.1
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        jmp _for_1
_for_1_body:
        ; move length.3, length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; add length.3, length.3, 1
        lea rax, [rsp+32]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+32]
        mov [rax], rbx
        ; move str.2, str.1
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov [rax], rbx
        ; add str.2, str.2, 1
        lea rax, [rsp+40]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+40]
        mov [rax], rbx
        ; move str.1, str.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.3
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
_for_1:
        ; load t.2.1, [str.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+24]
        mov [rbx], al
        ; branch t.2.1 notequals 0: for_1_body, for_1_break
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 0
        jne _for_1_body
        ; 67:9 return length
        ; ret length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; u8 next
        ;   rsp+0: var copy.1
        ;   rsp+8: var a.global
        ;   rsp+16: var t.global
        ;   rsp+24: var a.global1
        ;   rsp+32: var t.global1
        ;   rsp+40: var a.global2
        ;   rsp+48: var t.global2
_next:
        ; reserve space for local variables
        sub rsp, 64
        ; addrof a.global, global
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; load t.global, [a.global]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+16]
        mov [rbx], al
        ; move copy.1, t.global
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; addrof a.global1, global
        lea rax, [var_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; load t.global1, [a.global1]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+32]
        mov [rbx], al
        ; move t.global2, t.global1
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+48]
        mov [rax], bl
        ; add t.global2, t.global2, 1
        lea rax, [rsp+48]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+48]
        mov [rax], bl
        ; addrof a.global2, global
        lea rax, [var_0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; store [a.global2], t.global2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov cl, [rax]
        mov [rbx], cl
        ; 8:9 return copy
        ; ret copy.1
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 64
        ret

        ; void main
        ;   rsp+0: var t.1.1
        ;   rsp+8: var n.1
        ;   rsp+16: var t.2.1
        ;   rsp+24: var a.global
        ;   rsp+32: var t.global
_main:
        ; reserve space for local variables
        sub rsp, 48
        ; begin initialize global variables
        ; const t.global, 0
        mov al, 0
        lea rbx, [rsp+32]
        mov [rbx], al
        ; addrof a.global, global
        lea rax, [var_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; store [a.global], t.global
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; end initialize global variables
        ; 12:2 while true
        jmp _while_2
_if_3_end:
        ; branch n.1 gteq 2: while_2, if_4_then
        lea rax, [rsp+8]
        mov bl, [rax]
        cmp bl, 2
        jae _while_2
        ; const t.2.1, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call printString@@u8[t.2.1]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
_while_2:
        ; const t.1.1, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.1.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; call n.1 = next[] -> u8
        sub rsp, 8
          call _next
        add rsp, 8
        lea rbx, [rsp+8]
        mov [rbx], al
        ; 15:3 if n == 3
        ; branch n.1 notequals 3: if_3_end, main_ret
        lea rax, [rsp+8]
        mov bl, [rax]
        cmp bl, 3
        jne _if_3_end
        ; release space for local variables
        add rsp, 48
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
        ; variable 0: global (u8/1)
        var_0 rb 1

section '.data' data readable
        string_0 db 'loop', 0x0a, 0x00
        string_1 db '<2', 0x0a, 0x00

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
