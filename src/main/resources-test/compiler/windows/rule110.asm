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
        ;   rsp+0: var length
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length]
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

        ; i64 strlen@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        jmp _for_1
_for_1_body:
        ; add length, length, 1
        lea rax, [rsp+0]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+0]
        mov [rax], rbx
        ; add str, str, 1
        lea rax, [rsp+24]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+24]
        mov [rax], rbx
_for_1:
        ; load t.2, [str]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+8]
        mov [rbx], al
        ; branch t.2 notequals 0: for_1_body, for_1_break
        lea rax, [rsp+8]
        mov bl, [rax]
        cmp bl, 0
        jne _for_1_body
        ; 67:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
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

        ; void printBoard
        ;   rsp+0: var i
        ;   rsp+1: var t.1
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+24: var t.4
_printBoard:
        ; reserve space for local variables
        sub rsp, 32
        ; call printChar@u8[124]
        mov  rax, 124
        push rax
          call _printChar@u8
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 11:2 for i < 30
        jmp _for_2
_for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.3(i64), i(u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; addrof t.2, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.2, t.2, t.3
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; load t.1, [t.2]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+1]
        mov [rbx], al
        ; branch t.1 equals 0: if_3_then, if_3_else
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
        je _if_3_then
        ; call printChar@u8[42]
        mov  rax, 42
        push rax
          call _printChar@u8
        add rsp, 8
        jmp _for_2_continue
_if_3_then:
        ; call printChar@u8[32]
        mov  rax, 32
        push rax
          call _printChar@u8
        add rsp, 8
_for_2_continue:
        ; add i, i, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
_for_2:
        ; branch i lt 30: for_2_body, for_2_break
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 30
        jb _for_2_body
        ; const t.4, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.4]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+2: var pattern
        ;   rsp+3: var j
        ;   rsp+4: var t.4
        ;   rsp+8: var t.5
        ;   rsp+16: var t.6
        ;   rsp+24: var t.7
        ;   rsp+32: var t.8
        ;   rsp+40: var t.9
        ;   rsp+48: var t.10
        ;   rsp+49: var t.11
        ;   rsp+56: var t.12
        ;   rsp+64: var t.13
        ;   rsp+72: var t.14
        ;   rsp+80: var t.15
        ;   rsp+88: var t.16
        ;   rsp+96: var t.17
        ;   rsp+97: var t.18
        ;   rsp+98: var t.19
        ;   rsp+104: var t.20
        ;   rsp+112: var t.21
        ;   rsp+120: var t.22
        ;   rsp+121: var t.23
        ;   rsp+122: var t.24
        ;   rsp+123: var t.25
        ;   rsp+128: var t.26
        ;   rsp+136: var t.27
_main:
        ; reserve space for local variables
        sub rsp, 144
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 23:2 for i < 30
        jmp _for_4
_for_4_body:
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+4]
        mov [rbx], al
        ; cast t.6(i64), i(u8)
        lea rax, [rsp+0]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; addrof t.5, [board]
        lea rax, [var_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.5, t.5, t.6
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; store [t.5], t.4
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+4]
        mov cl, [rax]
        mov [rbx], cl
        ; add i, i, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
_for_4:
        ; branch i lt 30: for_4_body, for_4_break
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 30
        jb _for_4_body
        ; const t.7, 1
        mov al, 1
        lea rbx, [rsp+24]
        mov [rbx], al
        ; const t.9, 29
        mov rax, 29
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; addrof t.8, [board]
        lea rax, [var_0]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; add t.8, t.8, t.9
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+32]
        mov [rax], rbx
        ; store [t.8], t.7
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        mov [rbx], cl
        ; call printBoard[]
        sub rsp, 8
          call _printBoard
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 30:2 for i < 28
        jmp _for_5
_for_5_body:
        ; const t.13, 0
        mov rax, 0
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; addrof t.12, [board]
        lea rax, [var_0]
        lea rbx, [rsp+56]
        mov [rbx], rax
        ; add t.12, t.12, t.13
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+56]
        mov [rax], rbx
        ; load t.11, [t.12]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+49]
        mov [rbx], al
        ; move t.10, t.11
        lea rax, [rsp+49]
        mov bl, [rax]
        lea rax, [rsp+48]
        mov [rax], bl
        ; shiftleft t.10, t.10, 1
        lea rax, [rsp+48]
        mov bl, [rax]
        shl bl, 1
        lea rax, [rsp+48]
        mov [rax], bl
        ; const t.16, 1
        mov rax, 1
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; addrof t.15, [board]
        lea rax, [var_0]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; add t.15, t.15, t.16
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+80]
        mov [rax], rbx
        ; load t.14, [t.15]
        lea rax, [rsp+80]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+72]
        mov [rbx], al
        ; move pattern, t.10
        lea rax, [rsp+48]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; or pattern, pattern, t.14
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const j, 1
        mov al, 1
        lea rbx, [rsp+3]
        mov [rbx], al
        ; 32:3 for j < 29
        jmp _for_6
_for_6_body:
        ; move t.18, pattern
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+97]
        mov [rax], bl
        ; shiftleft t.18, t.18, 1
        lea rax, [rsp+97]
        mov bl, [rax]
        shl bl, 1
        lea rax, [rsp+97]
        mov [rax], bl
        ; move t.17, t.18
        lea rax, [rsp+97]
        mov bl, [rax]
        lea rax, [rsp+96]
        mov [rax], bl
        ; and t.17, t.17, 7
        lea rax, [rsp+96]
        mov bl, [rax]
        and bl, 7
        lea rax, [rsp+96]
        mov [rax], bl
        ; move t.22, j
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+120]
        mov [rax], bl
        ; add t.22, t.22, 1
        lea rax, [rsp+120]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+120]
        mov [rax], bl
        ; cast t.21(i64), t.22(u8)
        lea rax, [rsp+120]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; addrof t.20, [board]
        lea rax, [var_0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.20, t.20, t.21
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; load t.19, [t.20]
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+98]
        mov [rbx], al
        ; move pattern, t.17
        lea rax, [rsp+96]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov [rax], bl
        ; or pattern, pattern, t.19
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+98]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+2]
        mov [rax], bl
        ; const t.25, 110
        mov al, 110
        lea rbx, [rsp+123]
        mov [rbx], al
        ; move t.24, t.25
        lea rax, [rsp+123]
        mov bl, [rax]
        lea rax, [rsp+122]
        mov [rax], bl
        ; shiftright t.24, t.24, pattern
        lea rax, [rsp+122]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        shr bl, cl
        lea rax, [rsp+122]
        mov [rax], bl
        ; move t.23, t.24
        lea rax, [rsp+122]
        mov bl, [rax]
        lea rax, [rsp+121]
        mov [rax], bl
        ; and t.23, t.23, 1
        lea rax, [rsp+121]
        mov bl, [rax]
        and bl, 1
        lea rax, [rsp+121]
        mov [rax], bl
        ; cast t.27(i64), j(u8)
        lea rax, [rsp+3]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+136]
        mov [rax], rbx
        ; addrof t.26, [board]
        lea rax, [var_0]
        lea rbx, [rsp+128]
        mov [rbx], rax
        ; add t.26, t.26, t.27
        lea rax, [rsp+128]
        mov rbx, [rax]
        lea rax, [rsp+136]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+128]
        mov [rax], rbx
        ; store [t.26], t.23
        lea rax, [rsp+128]
        mov rbx, [rax]
        lea rax, [rsp+121]
        mov cl, [rax]
        mov [rbx], cl
        ; add j, j, 1
        lea rax, [rsp+3]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+3]
        mov [rax], bl
_for_6:
        ; branch j lt 29: for_6_body, for_6_break
        lea rax, [rsp+3]
        mov bl, [rax]
        cmp bl, 29
        jb _for_6_body
        ; call printBoard[]
        sub rsp, 8
          call _printBoard
        add rsp, 8
        ; add i, i, 1
        lea rax, [rsp+1]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+1]
        mov [rax], bl
_for_5:
        ; branch i lt 28: for_5_body, main_ret
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 28
        jb _for_5_body
        ; release space for local variables
        add rsp, 144
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
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

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
