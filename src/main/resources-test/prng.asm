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
        ; call _, printStringLength [t.1, t.2]
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
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; const t.5, 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; sub pos, pos, t.5
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.6, 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; move remainder, number
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, t.6
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
        ; const t.7, 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number, number, t.7
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
        ; cast t.8(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; move digit, t.8
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, t.9
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.11(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.12(u8*), t.11(i64)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.10, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.10, t.10, t.12
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.10], digit
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; const t.14, 0
        mov rax, 0
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; equals t.13, number, t.14
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.13, false, @while_1
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.16(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; cast t.17(u8*), t.16(i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.15, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.15, t.15, t.17
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.20, 20
        mov al, 20
        lea rbx, [rsp+137]
        mov [rbx], al
        ; move t.19, t.20
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+136]
        mov [rax], bl
        ; sub t.19, t.19, pos
        lea rax, [rsp+136]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.18(i64), t.19(u8)
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printStringLength [t.15, t.18]
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
        ; const t.2, 0
        mov rax, 0
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; lt t.1, number, t.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        cmp rbx, rcx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.3, 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call _, printChar [t.3]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.4, 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call _, printChar [t.4]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; void initRandom
        ;   rsp+8: arg salt
@initRandom:
        ; move __random__, salt
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ret

        ; i32 random
        ;   rsp+0: var r
        ;   rsp+4: var b
        ;   rsp+8: var c
        ;   rsp+12: var d
        ;   rsp+16: var e
        ;   rsp+20: var t.5
        ;   rsp+24: var t.6
        ;   rsp+28: var t.7
        ;   rsp+32: var t.8
        ;   rsp+36: var t.9
        ;   rsp+40: var t.10
        ;   rsp+44: var t.11
        ;   rsp+48: var t.12
        ;   rsp+52: var t.13
        ;   rsp+56: var t.14
        ;   rsp+60: var t.15
        ;   rsp+64: var t.16
        ;   rsp+68: var t.17
        ;   rsp+72: var t.18
        ;   rsp+76: var t.19
        ;   rsp+80: var t.20
@random:
        ; reserve space for local variables
        sub rsp, 96
        ; move r, __random__
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+0]
        mov [rax], ebx
        ; const t.6, 524287
        mov eax, 524287
        lea rbx, [rsp+24]
        mov [rbx], eax
        ; move t.5, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov [rax], ebx
        ; and t.5, t.5, t.6
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov ecx, [rax]
        and ebx, ecx
        lea rax, [rsp+20]
        mov [rax], ebx
        ; const t.7, 48271
        mov eax, 48271
        lea rbx, [rsp+28]
        mov [rbx], eax
        ; move b, t.5
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], ebx
        ; mul b, b, t.7
        lea rax, [rsp+4]
        mov ebx, [rax]
        lea rax, [rsp+28]
        mov ecx, [rax]
        movsxd rbx, ebx
        movsxd rcx, ecx
        imul  rbx, rcx
        lea rax, [rsp+4]
        mov [rax], ebx
        ; const t.9, 15
        mov eax, 15
        lea rbx, [rsp+36]
        mov [rbx], eax
        ; move t.8, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+32]
        mov [rax], ebx
        ; shiftright t.8, t.8, t.9
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+36]
        mov ecx, [rax]
        sar ebx, cl
        lea rax, [rsp+32]
        mov [rax], ebx
        ; const t.10, 48271
        mov eax, 48271
        lea rbx, [rsp+40]
        mov [rbx], eax
        ; move c, t.8
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mul c, c, t.10
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+40]
        mov ecx, [rax]
        movsxd rbx, ebx
        movsxd rcx, ecx
        imul  rbx, rcx
        lea rax, [rsp+8]
        mov [rax], ebx
        ; const t.12, 65535
        mov eax, 65535
        lea rbx, [rsp+48]
        mov [rbx], eax
        ; move t.11, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov [rax], ebx
        ; and t.11, t.11, t.12
        lea rax, [rsp+44]
        mov ebx, [rax]
        lea rax, [rsp+48]
        mov ecx, [rax]
        and ebx, ecx
        lea rax, [rsp+44]
        mov [rax], ebx
        ; const t.13, 15
        mov eax, 15
        lea rbx, [rsp+52]
        mov [rbx], eax
        ; move d, t.11
        lea rax, [rsp+44]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], ebx
        ; shiftleft d, d, t.13
        lea rax, [rsp+12]
        mov ebx, [rax]
        lea rax, [rsp+52]
        mov ecx, [rax]
        sal ebx, cl
        lea rax, [rsp+12]
        mov [rax], ebx
        ; const t.16, 16
        mov eax, 16
        lea rbx, [rsp+64]
        mov [rbx], eax
        ; move t.15, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+60]
        mov [rax], ebx
        ; shiftright t.15, t.15, t.16
        lea rax, [rsp+60]
        mov ebx, [rax]
        lea rax, [rsp+64]
        mov ecx, [rax]
        sar ebx, cl
        lea rax, [rsp+60]
        mov [rax], ebx
        ; move t.14, t.15
        lea rax, [rsp+60]
        mov ebx, [rax]
        lea rax, [rsp+56]
        mov [rax], ebx
        ; add t.14, t.14, b
        lea rax, [rsp+56]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+56]
        mov [rax], ebx
        ; move e, t.14
        lea rax, [rsp+56]
        mov ebx, [rax]
        lea rax, [rsp+16]
        mov [rax], ebx
        ; add e, e, d
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+16]
        mov [rax], ebx
        ; const t.18, 2147483647
        mov eax, 2147483647
        lea rbx, [rsp+72]
        mov [rbx], eax
        ; move t.17, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+68]
        mov [rax], ebx
        ; and t.17, t.17, t.18
        lea rax, [rsp+68]
        mov ebx, [rax]
        lea rax, [rsp+72]
        mov ecx, [rax]
        and ebx, ecx
        lea rax, [rsp+68]
        mov [rax], ebx
        ; const t.20, 31
        mov eax, 31
        lea rbx, [rsp+80]
        mov [rbx], eax
        ; move t.19, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+76]
        mov [rax], ebx
        ; shiftright t.19, t.19, t.20
        lea rax, [rsp+76]
        mov ebx, [rax]
        lea rax, [rsp+80]
        mov ecx, [rax]
        sar ebx, cl
        lea rax, [rsp+76]
        mov [rax], ebx
        ; move __random__, t.17
        lea rax, [rsp+68]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ; add __random__, __random__, t.19
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+76]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [var_0]
        mov [rax], ebx
        ; 127:9 return __random__
        ; ret __random__
        lea rax, [var_0]
        mov ebx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 96
        ret

        ; u8 randomU8
        ;   rsp+0: var t.0
        ;   rsp+4: var t.1
@randomU8:
        ; reserve space for local variables
        sub rsp, 16
        ; 131:10 return (u8)
        ; call t.1, random, []
        sub rsp, 8
          call @random
        add rsp, 8
        lea rbx, [rsp+4]
        mov [rbx], eax
        ; cast t.0(u8), t.1(i32)
        lea rax, [rsp+4]
        mov ebx, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; ret t.0
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var r
        ;   rsp+4: var t.2
        ;   rsp+8: var t.3
        ;   rsp+9: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; const __random__, 0
        mov eax, 0
        lea rbx, [var_0]
        mov [rbx], eax
        ; end initialize global variables
        ; const t.2, 7439742
        mov eax, 7439742
        lea rbx, [rsp+4]
        mov [rbx], eax
        ; call _, initRandom [t.2]
        lea rax, [rsp+4]
        mov ebx, [rax]
        push rbx
          call @initRandom
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 5:2 for i < 50
@for_4:
        ; const t.4, 50
        mov al, 50
        lea rbx, [rsp+9]
        mov [rbx], al
        ; lt t.3, i, t.4
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+9]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.3, false, @main_ret
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @main_ret
        ; call r, randomU8, []
        sub rsp, 8
          call @randomU8
        add rsp, 8
        lea rbx, [rsp+1]
        mov [rbx], al
        ; cast t.5(i64), r(u8)
        lea rax, [rsp+1]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+16]
        mov [rax], rbx
        ; call _, printIntLf [t.5]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.6, 1
        mov al, 1
        lea rbx, [rsp+24]
        mov [rbx], al
        ; add i, i, t.6
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        jmp @for_4
@main_ret:
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
        ; variable 0: __random__ (i32/4)
        var_0 rb 4

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
