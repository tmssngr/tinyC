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

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; call printStringLength@@u8@u8[t.1, t.2]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+136: arg number
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
        ;   rsp+121: var t.17
@printUint@i64:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 25:2 while true
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
        lea rax, [rsp+136]
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
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+136]
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
        ; 31:3 if number == 0
        ; equals t.12, number, 0
        lea rax, [rsp+136]
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
        ; const t.17, 20
        mov al, 20
        lea rbx, [rsp+121]
        mov [rbx], al
        ; move t.16, t.17
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+120]
        mov [rax], bl
        ; sub t.16, t.16, pos
        lea rax, [rsp+120]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.13, t.16]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+128]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf@u8
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
@printIntLf@u8:
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
          call @printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
@printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; 51:2 if number < 0
        ; lt t.1, number, 0
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.2, 45
        mov al, 45
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call printChar@u8[t.2]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+24]
        mov [rax], rbx
@if_3_end:
        ; call printUint@i64[number]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printUint@i64
        add rsp, 8
        ; const t.3, 10
        mov al, 10
        lea rbx, [rsp+2]
        mov [rbx], al
        ; call printChar@u8[t.3]
        lea rax, [rsp+2]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2
@printStringLength@@u8@u8:
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
          call @printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void initRandom@i32
        ;   rsp+8: arg salt
@initRandom@i32:
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
        ; 155:9 return __random__
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
        ; 159:10 return (u8)
        ; call t.1 = random[] -> i32
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
@main:
        ; reserve space for local variables
        sub rsp, 16
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
        ; call initRandom@i32[t.2]
        lea rax, [rsp+4]
        mov ebx, [rax]
        push rbx
          call @initRandom@i32
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 5:2 for i < 50
        jmp @for_4
@for_4_body:
        ; call r = randomU8[] -> u8
        sub rsp, 8
          call @randomU8
        add rsp, 8
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call printIntLf@u8[r]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printIntLf@u8
        add rsp, 8
        ; inc i
        lea rax, [rsp+0]
        mov bl, [rax]
        inc bl
        lea rax, [rsp+0]
        mov [rax], bl
@for_4:
        ; lt t.3, i, 50
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 50
        setb bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.3, true, @for_4_body
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz @for_4_body
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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
