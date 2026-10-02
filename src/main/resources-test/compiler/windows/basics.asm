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

        ; void printUint@u8
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
_printUint@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printUint@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printUint@i64
        add rsp, 8
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

        ; i64 unusedArgs@u8@bool@u8@u8
        ;   rsp+56: arg a
        ;   rsp+48: arg b
        ;   rsp+40: arg c
        ;   rsp+32: arg d
        ;   rsp+0: var t.4
_unusedArgs@u8@bool@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 9:10 return (i64)
        ; cast t.4(i64), c(u8)
        lea rax, [rsp+40]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; ret t.4
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var c
        ;   rsp+8: var onePtr
        ;   rsp+16: var twoPtr
        ;   rsp+24: var t.3
        ;   rsp+32: var a.4
        ;   rsp+40: var t.5
        ;   rsp+48: var a.6
        ;   rsp+56: var t.7
        ;   rsp+64: var a.8
        ;   rsp+72: var t.9
        ;   rsp+80: var a.10
        ;   rsp+88: var t.11
        ;   rsp+96: var a.12
        ;   rsp+104: var t.13
        ;   rsp+105: var t.14
        ;   rsp+106: var t.15
        ;   rsp+112: var t.16
        ;   rsp+120: var t.17
        ;   rsp+128: var a.18
        ;   rsp+136: var t.19
_main:
        ; reserve space for local variables
        sub rsp, 144
        ; begin initialize global variables
        ; const t.3, 48
        mov al, 48
        lea rbx, [rsp+24]
        mov [rbx], al
        ; addrof a.4, zero
        lea rax, [var_0]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; store [a.4], t.3
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.5, 49
        mov al, 49
        lea rbx, [rsp+40]
        mov [rbx], al
        ; addrof a.6, one
        lea rax, [var_1]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; store [a.6], t.5
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.7, 50
        mov al, 50
        lea rbx, [rsp+56]
        mov [rbx], al
        ; addrof a.8, two
        lea rax, [var_2]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; store [a.8], t.7
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov cl, [rax]
        mov [rbx], cl
        ; const t.9, 34
        mov al, 34
        lea rbx, [rsp+72]
        mov [rbx], al
        ; addrof a.10, threeFour
        lea rax, [var_3]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; store [a.10], t.9
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov cl, [rax]
        mov [rbx], cl
        ; end initialize global variables
        ; const t.11, 1
        mov al, 1
        lea rbx, [rsp+88]
        mov [rbx], al
        ; call _ = unusedArgs@u8@bool@u8@u8[1, t.11, 2, 3] -> i64
        mov  rax, 1
        push rax
        lea rax, [rsp+96]
        mov bl, [rax]
        push rbx
        mov  rax, 2
        push rax
        mov  rax, 3
        push rax
        sub rsp, 8
          call _unusedArgs@u8@bool@u8@u8
        add rsp, 40
        ; addrof a.12, zero
        lea rax, [var_0]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; load t.13, [a.12]
        lea rax, [rsp+96]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+104]
        mov [rbx], al
        ; call printChar@u8[t.13]
        lea rax, [rsp+104]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; addrof onePtr, one
        lea rax, [var_1]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; load t.14, [onePtr]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+105]
        mov [rbx], al
        ; call printChar@u8[t.14]
        lea rax, [rsp+105]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; addrof twoPtr, two
        lea rax, [var_2]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; const t.17, 0
        mov rax, 0
        lea rbx, [rsp+120]
        mov [rbx], rax
        ; move t.16, twoPtr
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov [rax], rbx
        ; add t.16, t.17
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+112]
        mov [rax], rbx
        ; load t.15, [t.16]
        lea rax, [rsp+112]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+106]
        mov [rbx], al
        ; call printChar@u8[t.15]
        lea rax, [rsp+106]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; addrof a.18, threeFour
        lea rax, [var_3]
        lea rbx, [rsp+128]
        mov [rbx], rax
        ; load t.19, [a.18]
        lea rax, [rsp+128]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+136]
        mov [rbx], al
        ; call printUint@u8[t.19]
        lea rax, [rsp+136]
        mov bl, [rax]
        push rbx
          call _printUint@u8
        add rsp, 8
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
          call _printChar@u8
        add rsp, 8
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
