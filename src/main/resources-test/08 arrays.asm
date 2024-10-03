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
        ; addrof t.1(1@function,u8*), chr(0@argument,u8)
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2(2@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printStringLength [t.1(1@function,u8*), t.2(2@function,i64)]
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
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+57: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+80: var t.12
        ;   rsp+88: var t.13
        ;   rsp+96: var t.14
        ;   rsp+104: var t.15
        ;   rsp+112: var t.16
        ;   rsp+120: var t.17
        ;   rsp+128: var t.18
        ;   rsp+136: var t.19
        ;   rsp+137: var t.20
@printUint:
        ; reserve space for local variables
        sub rsp, 144
        ; const pos(2@function,u8), 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; const t.5(5@function,u8), 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; sub pos(2@function,u8), pos(2@function,u8), t.5(5@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.6(6@function,i64), 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; mod remainder(3@function,i64), number(0@argument,i64), t.6(6@function,i64)
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.7(7@function,i64), 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number(0@argument,i64), number(0@argument,i64), t.7(7@function,i64)
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
        ; cast t.8(8@function,u8), remainder(3@function,i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9(9@function,u8), 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; add digit(4@function,u8), t.8(8@function,u8), t.9(9@function,u8)
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.11(11@function,i64), pos(2@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.12(12@function,u8*), t.11(11@function,i64)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.10(10@function,u8*), [buffer(1@function,u8*)]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.10(10@function,u8*), t.10(10@function,u8*), t.12(12@function,u8*)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.10(10@function,u8*)], digit(4@function,u8)
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; const t.14(14@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; equals t.13(13@function,bool), number(0@argument,i64), t.14(14@function,i64)
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.13(13@function,bool), false, @while_1
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.16(16@function,i64), pos(2@function,u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; cast t.17(17@function,u8*), t.16(16@function,i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.15(15@function,u8*), [buffer(1@function,u8*)]
        lea rax, [rsp+0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.15(15@function,u8*), t.15(15@function,u8*), t.17(17@function,u8*)
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.20(20@function,u8), 20
        mov al, 20
        lea rbx, [rsp+137]
        mov [rbx], al
        ; sub t.19(19@function,u8), t.20(20@function,u8), pos(2@function,u8)
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.18(18@function,i64), t.19(19@function,u8)
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printStringLength [t.15(15@function,u8*), t.18(18@function,i64)]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+136]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 144
        ret

        ; void printIntLf
        ;   rsp+40: arg number
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
@printIntLf:
        ; reserve space for local variables
        sub rsp, 32
        ; 27:2 if number < 0
        ; const t.2(2@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; lt t.1(1@function,bool), number(0@argument,i64), t.2(2@function,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        cmp rbx, rcx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1(1@function,bool), false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.3(3@function,u8), 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call _, printChar [t.3(3@function,u8)]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; neg number(0@argument,i64), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.4(4@function,u8), 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call _, printChar [t.4(4@function,u8)]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
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
        ;   rsp+0: var chr
        ;   rsp+1: var result
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+24: var t.4
        ;   rsp+32: var t.5
        ;   rsp+33: var t.6
        ;   rsp+40: var t.7
        ;   rsp+48: var t.8
        ;   rsp+56: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+80: var t.12
        ;   rsp+88: var t.13
        ;   rsp+96: var t.14
        ;   rsp+97: var t.15
        ;   rsp+104: var t.16
        ;   rsp+112: var t.17
        ;   rsp+120: var t.18
        ;   rsp+128: var t.19
        ;   rsp+136: var t.20
        ;   rsp+144: var t.21
        ;   rsp+152: var t.22
        ;   rsp+160: var t.23
        ;   rsp+168: var t.24
        ;   rsp+176: var t.25
        ;   rsp+184: var t.26
        ;   rsp+192: var t.27
@main:
        ; reserve space for local variables
        sub rsp, 208
        ; const chr(0@function,u8), 32
        mov al, 32
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const t.3(3@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; cast t.4(4@function,u8*), t.3(3@function,i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; addrof t.2(2@function,u8*), [chars(0@global,u8*)]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.2(2@function,u8*), t.2(2@function,u8*), t.4(4@function,u8*)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; store [t.2(2@function,u8*)], chr(0@function,u8)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+0]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.8(8@function,i64), 0
        mov rax, 0
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; cast t.9(9@function,u8*), t.8(8@function,i64)
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        ; addrof t.7(7@function,u8*), [chars(0@global,u8*)]
        lea rax, [var_0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.7(7@function,u8*), t.7(7@function,u8*), t.9(9@function,u8*)
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; load t.6(6@function,u8), [t.7(7@function,u8*)]
        lea rax, [rsp+40]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+33]
        mov [rbx], al
        ; const t.10(10@function,u8), 1
        mov al, 1
        lea rbx, [rsp+64]
        mov [rbx], al
        ; add t.5(5@function,u8), t.6(6@function,u8), t.10(10@function,u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+64]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; const t.12(12@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; cast t.13(13@function,u8*), t.12(12@function,i64)
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov [rax], rbx
        ; addrof t.11(11@function,u8*), [chars(0@global,u8*)]
        lea rax, [var_0]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; add t.11(11@function,u8*), t.11(11@function,u8*), t.13(13@function,u8*)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+72]
        mov [rax], rbx
        ; store [t.11(11@function,u8*)], t.5(5@function,u8)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.17(17@function,i64), 1
        mov rax, 1
        lea rbx, [rsp+112]
        mov [rbx], rax
        ; cast t.18(18@function,u8*), t.17(17@function,i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.16(16@function,u8*), [chars(0@global,u8*)]
        lea rax, [var_0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.16(16@function,u8*), t.16(16@function,u8*), t.18(18@function,u8*)
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; load t.15(15@function,u8), [t.16(16@function,u8*)]
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+97]
        mov [rbx], al
        ; const t.19(19@function,u8), 2
        mov al, 2
        lea rbx, [rsp+128]
        mov [rbx], al
        ; add t.14(14@function,u8), t.15(15@function,u8), t.19(19@function,u8)
        lea rax, [rsp+97]
        mov bl, [rax]
        lea rax, [rsp+128]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+96]
        mov [rax], bl
        ; const t.22(22@function,u8), 2
        mov al, 2
        lea rbx, [rsp+152]
        mov [rbx], al
        ; cast t.21(21@function,i64), t.22(22@function,u8)
        lea rax, [rsp+152]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+144]
        mov [rax], rbx
        ; cast t.23(23@function,u8*), t.21(21@function,i64)
        lea rax, [rsp+144]
        mov rbx, [rax]
        lea rax, [rsp+160]
        mov [rax], rbx
        ; addrof t.20(20@function,u8*), [chars(0@global,u8*)]
        lea rax, [var_0]
        lea rbx, [rsp+136]
        mov [rbx], rax
        ; add t.20(20@function,u8*), t.20(20@function,u8*), t.23(23@function,u8*)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+160]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+136]
        mov [rax], rbx
        ; store [t.20(20@function,u8*)], t.14(14@function,u8)
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.25(25@function,i64), 2
        mov rax, 2
        lea rbx, [rsp+176]
        mov [rbx], rax
        ; cast t.26(26@function,u8*), t.25(25@function,i64)
        lea rax, [rsp+176]
        mov rbx, [rax]
        lea rax, [rsp+184]
        mov [rax], rbx
        ; addrof t.24(24@function,u8*), [chars(0@global,u8*)]
        lea rax, [var_0]
        lea rbx, [rsp+168]
        mov [rbx], rax
        ; add t.24(24@function,u8*), t.24(24@function,u8*), t.26(26@function,u8*)
        lea rax, [rsp+168]
        mov rbx, [rax]
        lea rax, [rsp+184]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+168]
        mov [rax], rbx
        ; load result(1@function,u8), [t.24(24@function,u8*)]
        lea rax, [rsp+168]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+1]
        mov [rbx], al
        ; cast t.27(27@function,i64), result(1@function,u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+192]
        mov [rax], rbx
        ; call _, printIntLf [t.27(27@function,i64)]
        lea rax, [rsp+192]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 208
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
        ; variable 0: chars (2048)
        var_0 rb 2048

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
