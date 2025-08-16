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
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2, 1
        mov rax, 1
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printStringLength[t.1, t.2]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
        ;   rsp+152: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+40: var t.5
        ;   rsp+48: var t.6
        ;   rsp+56: var t.7
        ;   rsp+57: var t.8
        ;   rsp+64: var t.9
        ;   rsp+72: var t.10
        ;   rsp+80: var t.11
        ;   rsp+88: var t.12
        ;   rsp+96: var t.13
        ;   rsp+104: var t.14
        ;   rsp+112: var t.15
        ;   rsp+120: var t.16
        ;   rsp+128: var t.17
        ;   rsp+129: var t.18
@printUint:
        ; reserve space for local variables
        sub rsp, 144
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; dec pos
        lea rax, [rsp+20]
        mov bl, [rax]
        dec bl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.5, 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; move remainder, number
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, t.5
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.6, 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number, number, t.6
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+152]
        mov [rdx], rbx
        ; cast t.7(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.8, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; move digit, t.7
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, t.8
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.10(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.11(u8*), t.10(i64)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.9, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.9, t.9, t.11
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.9], digit
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; equals t.12, number, 0
        lea rax, [rsp+152]
        mov rbx, [rax]
        cmp rbx, 0
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.12, false, @while_1
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.14(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+104]
        mov [rax], rbx
        ; cast t.15(u8*), t.14(i64)
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov [rax], rbx
        ; addrof t.13, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; add t.13, t.13, t.15
        lea rax, [rsp+96]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+96]
        mov [rax], rbx
        ; const t.18, 20
        mov al, 20
        lea rbx, [rsp+129]
        mov [rbx], al
        ; move t.17, t.18
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+128]
        mov [rax], bl
        ; sub t.17, t.17, pos
        lea rax, [rsp+128]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+128]
        mov [rax], bl
        ; cast t.16(i64), t.17(u8)
        lea rax, [rsp+128]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+120]
        mov [rax], rbx
        ; call printStringLength[t.13, t.16]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+128]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 144
        ret

        ; i64 unusedArgs
        ;   rsp+40: arg a
        ;   rsp+32: arg b
        ;   rsp+24: arg c
        ;   rsp+16: arg d
@unusedArgs:
        ; 9:9 return c
        ; ret c
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov rax, rbx
        ret

        ; void main
        ;   rsp+0: var c
        ;   rsp+8: var onePtr
        ;   rsp+16: var twoPtr
        ;   rsp+24: var t.3
        ;   rsp+26: var t.4
        ;   rsp+32: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+49: var t.8
        ;   rsp+56: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+80: var t.12
        ;   rsp+88: var t.13
@main:
        ; reserve space for local variables
        sub rsp, 96
        ; begin initialize global variables
        ; const zero, 48
        mov al, 48
        lea rbx, [var_0]
        mov [rbx], al
        ; const one, 49
        mov al, 49
        lea rbx, [var_1]
        mov [rbx], al
        ; const two, 50
        mov al, 50
        lea rbx, [var_2]
        mov [rbx], al
        ; const threeFour, 34
        mov al, 34
        lea rbx, [var_3]
        mov [rbx], al
        ; end initialize global variables
        ; const t.3, 1
        mov ax, 1
        lea rbx, [rsp+24]
        mov [rbx], ax
        ; const t.4, 1
        mov al, 1
        lea rbx, [rsp+26]
        mov [rbx], al
        ; const t.5, 2
        mov rax, 2
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; const t.6, 3
        mov rax, 3
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; call _ = unusedArgs[t.3, t.4, t.5, t.6] -> i64
        lea rax, [rsp+24]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+34]
        mov bl, [rax]
        push rbx
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @unusedArgs
        add rsp, 40
        ; call printChar[zero]
        lea rax, [var_0]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; addrof onePtr, one
        lea rax, [var_1]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; load t.7, [onePtr]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+48]
        mov [rbx], al
        ; call printChar[t.7]
        lea rax, [rsp+48]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; addrof twoPtr, two
        lea rax, [var_2]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; const t.10, 0
        mov rax, 0
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; cast t.11(u8*), t.10(i64)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov [rax], rbx
        ; move t.9, twoPtr
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; add t.9, t.9, t.11
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+56]
        mov [rax], rbx
        ; load t.8, [t.9]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+49]
        mov [rbx], al
        ; call printChar[t.8]
        lea rax, [rsp+49]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; cast t.12(i64), threeFour(u8)
        lea rax, [var_3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+80]
        mov [rax], rbx
        ; call printUint[t.12]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.13, 10
        mov al, 10
        lea rbx, [rsp+88]
        mov [rbx], al
        ; call printChar[t.13]
        lea rax, [rsp+88]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 96
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
        ; variable 0: zero (u8/1)
        var_0 rb 1
        ; variable 1: one (u8/1)
        var_1 rb 1
        ; variable 2: two (u8/1)
        var_2 rb 1
        ; variable 3: threeFour (u8/1)
        var_3 rb 1

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
