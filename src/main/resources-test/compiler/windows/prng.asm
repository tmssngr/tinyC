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
@printChar@u8:
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
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+104: arg number
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
        ;   rsp+80: var t.11
        ;   rsp+81: var t.12
@printUint@i64:
        ; reserve space for local variables
        sub rsp, 96
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 28:2 while true
@while_1:
        ; sub pos, pos, 1
        lea rax, [rsp+20]
        mov bl, [rax]
        sub bl, 1
        lea rax, [rsp+20]
        mov [rax], bl
        ; move remainder, number
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, 10
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+24]
        mov [rcx], rbx
        ; div number, number, 10
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+104]
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
        ; add digit, digit, 48
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
        ; addrof t.6, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6, t.6, t.7
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
        ; equals t.8, number, 0
        lea rax, [rsp+104]
        mov rbx, [rax]
        cmp rbx, 0
        sete bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; branch t.8, false, @while_1, @while_1_break
        lea rax, [rsp+56]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.10(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; addrof t.9, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.9, t.9, t.10
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; const t.12, 20
        mov al, 20
        lea rbx, [rsp+81]
        mov [rbx], al
        ; move t.11, t.12
        lea rax, [rsp+81]
        mov bl, [rax]
        lea rax, [rsp+80]
        mov [rax], bl
        ; sub t.11, t.11, pos
        lea rax, [rsp+80]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+80]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.9, t.11]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+88]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 96
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
@printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; 54:2 if number < 0
        ; lt t.1, number, 0
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end, @if_3_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; call printChar@u8[45]
        mov  rax, 45
        push rax
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
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
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
@random:
        ; reserve space for local variables
        sub rsp, 48
        ; move r, __random__
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+0]
        mov [rax], ebx
        ; move t.5, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov [rax], ebx
        ; and t.5, t.5, 524287
        lea rax, [rsp+20]
        mov ebx, [rax]
        and ebx, 524287
        lea rax, [rsp+20]
        mov [rax], ebx
        ; move b, t.5
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], ebx
        ; mul b, b, 48271
        lea rax, [rsp+4]
        mov ebx, [rax]
        movsxd rbx, ebx
        imul  rbx, 48271
        lea rax, [rsp+4]
        mov [rax], ebx
        ; move t.6, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov [rax], ebx
        ; shiftright t.6, t.6, 15
        lea rax, [rsp+24]
        mov ebx, [rax]
        sar ebx, 15
        lea rax, [rsp+24]
        mov [rax], ebx
        ; move c, t.6
        lea rax, [rsp+24]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mul c, c, 48271
        lea rax, [rsp+8]
        mov ebx, [rax]
        movsxd rbx, ebx
        imul  rbx, 48271
        lea rax, [rsp+8]
        mov [rax], ebx
        ; move t.7, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+28]
        mov [rax], ebx
        ; and t.7, t.7, 65535
        lea rax, [rsp+28]
        mov ebx, [rax]
        and ebx, 65535
        lea rax, [rsp+28]
        mov [rax], ebx
        ; move d, t.7
        lea rax, [rsp+28]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], ebx
        ; shiftleft d, d, 15
        lea rax, [rsp+12]
        mov ebx, [rax]
        sal ebx, 15
        lea rax, [rsp+12]
        mov [rax], ebx
        ; move t.9, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+36]
        mov [rax], ebx
        ; shiftright t.9, t.9, 16
        lea rax, [rsp+36]
        mov ebx, [rax]
        sar ebx, 16
        lea rax, [rsp+36]
        mov [rax], ebx
        ; move t.8, t.9
        lea rax, [rsp+36]
        mov ebx, [rax]
        lea rax, [rsp+32]
        mov [rax], ebx
        ; add t.8, t.8, b
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+32]
        mov [rax], ebx
        ; move e, t.8
        lea rax, [rsp+32]
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
        ; move t.10, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+40]
        mov [rax], ebx
        ; and t.10, t.10, 2147483647
        lea rax, [rsp+40]
        mov ebx, [rax]
        and ebx, 2147483647
        lea rax, [rsp+40]
        mov [rax], ebx
        ; move t.11, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov [rax], ebx
        ; shiftright t.11, t.11, 31
        lea rax, [rsp+44]
        mov ebx, [rax]
        sar ebx, 31
        lea rax, [rsp+44]
        mov [rax], ebx
        ; move __random__, t.10
        lea rax, [rsp+40]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ; add __random__, __random__, t.11
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [var_0]
        mov [rax], ebx
        ; 15:9 return __random__
        ; ret __random__
        lea rax, [var_0]
        mov ebx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; u8 randomU8
        ;   rsp+0: var t.0
        ;   rsp+4: var t.1
@randomU8:
        ; reserve space for local variables
        sub rsp, 16
        ; 19:10 return (u8)
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
        ;   rsp+2: var t.2
@main:
        ; reserve space for local variables
        sub rsp, 16
        ; begin initialize global variables
        ; const __random__, 0
        mov eax, 0
        lea rbx, [var_0]
        mov [rbx], eax
        ; end initialize global variables
        ; call initRandom@i32[7439742]
        mov  rax, 7439742
        push rax
          call @initRandom@i32
        add rsp, 8
        ; const i, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 6:2 for i < 50
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
        ; add i, i, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
@for_4:
        ; lt t.2, i, 50
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 50
        setb bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.2, true, @for_4_body, @main_ret
        lea rax, [rsp+2]
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
