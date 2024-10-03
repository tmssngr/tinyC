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
        ; addrof r0(u8* t.1), chr(0@argument,u8)
        lea rcx, [rsp+24]
        ; const r1(i64 t.2), 1
        mov rdx, 1
        ; call _, printStringLength [r0(u8* t.1), r1(i64 t.2)]
        push rcx
        push rdx
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
        ; const r0(u8 pos), 20
        mov cl, 20
        ; 13:2 while true
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r0(u8 t.5), 1
        mov cl, 1
        ; copy r1(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r0(u8 pos), r1(u8 pos), r0(u8 t.5)
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r1(i64 t.6), 10
        mov rdx, 10
        ; copy r2(i64 number), number(0@argument,i64)
        lea rax, [rsp+152]
        mov r9, [rax]
        ; mod r1(i64 remainder), r2(i64 number), r1(i64 t.6)
        mov rax, r9
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r3(i64 t.7), 10
        mov r10, 10
        ; div r2(i64 number), r2(i64 number), r3(i64 t.7)
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r1(u8 t.8), r1(i64 remainder)
        ; const r3(u8 t.9), 48
        mov r10b, 48
        ; add r1(u8 digit), r1(u8 t.8), r3(u8 t.9)
        add dl, r10b
        ; cast r3(i64 t.11), r0(u8 pos)
        movzx r10, cl
        ; cast r3(u8* t.12), r3(i64 t.11)
        ; Spill pos
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
        ; addrof r0(u8* t.10), [buffer(1@function,u8*)]
        lea rcx, [rsp+0]
        ; add r0(u8* t.10), r0(u8* t.10), r3(u8* t.12)
        add rcx, r10
        ; store [r0(u8* t.10)], r1(u8 digit)
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r0(i64 t.14), 0
        mov rcx, 0
        ; equals r0(bool t.13), r2(i64 number), r0(i64 t.14)
        cmp r9, rcx
        sete cl
        ; copy number(0@argument,i64), r2(i64 number)
        lea rax, [rsp+152]
        mov [rax], r9
        ; branch r0(bool t.13), false, @while_1
        or cl, cl
        jz @while_1
        ; copy r0(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64 t.16), r0(u8 pos)
        movzx rdx, cl
        ; cast r1(u8* t.17), r1(i64 t.16)
        ; addrof r2(u8* t.15), [buffer(1@function,u8*)]
        lea r9, [rsp+0]
        ; add r1(u8* t.15), r2(u8* t.15), r1(u8* t.17)
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; const r2(u8 t.20), 20
        mov r9b, 20
        ; sub r0(u8 t.19), r2(u8 t.20), r0(u8 pos)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64 t.18), r0(u8 t.19)
        movzx rcx, cl
        ; call _, printStringLength [r1(u8* t.15), r0(i64 t.18)]
        push rdx
        push rcx
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
        ; const r0(i64 t.2), 0
        mov rcx, 0
        ; copy r1(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rdx, [rax]
        ; lt r0(bool t.1), r1(i64 number), r0(i64 t.2)
        cmp rdx, rcx
        setl cl
        ; branch r0(bool t.1), false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; const r0(u8 t.3), 45
        mov cl, 45
        ; call _, printChar [r0(u8 t.3)]
        push rcx
          call @printChar
        add rsp, 8
        ; copy r0(i64 number), number(0@argument,i64)
        lea rax, [rsp+40]
        mov rcx, [rax]
        ; neg r0(i64 number), r0(i64 number)
        neg rcx
        ; copy number(0@argument,i64), r0(i64 number)
        lea rax, [rsp+40]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r0(u8 t.4), 10
        mov cl, 10
        ; call _, printChar [r0(u8 t.4)]
        push rcx
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

        ; void initRandom
        ;   rsp+8: arg salt
@initRandom:
        ; copy r0(i32 salt), salt(0@argument,i32)
        lea rax, [rsp+8]
        mov ecx, [rax]
        ; copy r0(i32 __random__), r0(i32 salt)
        mov ecx, ecx
        ; copy __random__(0@global,i32), r0(i32 __random__)
        lea rax, [var_0]
        mov [rax], ecx
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
        ; copy r0(i32 __random__), __random__(0@global,i32)
        lea rax, [var_0]
        mov ecx, [rax]
        ; copy r0(i32 r), r0(i32 __random__)
        mov ecx, ecx
        ; const r1(i32 t.6), 524287
        mov edx, 524287
        ; and r1(i32 t.5), r0(i32 r), r1(i32 t.6)
        mov eax, ecx
        and eax, edx
        mov edx, eax
        ; const r2(i32 t.7), 48271
        mov r9d, 48271
        ; mul r1(i32 b), r1(i32 t.5), r2(i32 t.7)
        movsxd rdx, edx
        movsxd r9, r9d
        imul  rdx, r9
        ; const r2(i32 t.9), 15
        mov r9d, 15
        ; shiftright r0(i32 t.8), r0(i32 r), r2(i32 t.9)
        mov eax, ecx
        mov ecx, r9d
        sar eax, cl
        mov ecx, eax
        ; const r2(i32 t.10), 48271
        mov r9d, 48271
        ; mul r0(i32 c), r0(i32 t.8), r2(i32 t.10)
        movsxd rcx, ecx
        movsxd r9, r9d
        imul  rcx, r9
        ; const r2(i32 t.12), 65535
        mov r9d, 65535
        ; and r2(i32 t.11), r0(i32 c), r2(i32 t.12)
        mov eax, ecx
        and eax, r9d
        mov r9d, eax
        ; const r3(i32 t.13), 15
        mov r10d, 15
        ; shiftleft r2(i32 d), r2(i32 t.11), r3(i32 t.13)
        mov rbx, rcx
        mov eax, r9d
        mov cl, r10b
        sal eax, cl
        mov r9d, eax
        mov rcx, rbx
        ; const r3(i32 t.16), 16
        mov r10d, 16
        ; shiftright r0(i32 t.15), r0(i32 c), r3(i32 t.16)
        mov eax, ecx
        mov ecx, r10d
        sar eax, cl
        mov ecx, eax
        ; add r0(i32 t.14), r0(i32 t.15), r1(i32 b)
        add ecx, edx
        ; add r0(i32 e), r0(i32 t.14), r2(i32 d)
        add ecx, r9d
        ; const r1(i32 t.18), 2147483647
        mov edx, 2147483647
        ; and r1(i32 t.17), r0(i32 e), r1(i32 t.18)
        mov eax, ecx
        and eax, edx
        mov edx, eax
        ; const r2(i32 t.20), 31
        mov r9d, 31
        ; shiftright r0(i32 t.19), r0(i32 e), r2(i32 t.20)
        mov eax, ecx
        mov ecx, r9d
        sar eax, cl
        mov ecx, eax
        ; add r0(i32 __random__), r1(i32 t.17), r0(i32 t.19)
        mov eax, edx
        add eax, ecx
        mov ecx, eax
        ; 127:9 return __random__
        ; copy __random__(0@global,i32), r0(i32 __random__)
        lea rax, [var_0]
        mov [rax], ecx
        ; ret r0(i32 __random__)
        mov rax, rcx
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
        ; call r0(i32 t.1), random, []
        sub rsp, 8
          call @random
        add rsp, 8
        mov ecx, eax
        ; cast r0(u8 t.0), r0(i32 t.1)
        ; ret r0(u8 t.0)
        mov rax, rcx
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
        ; const r0(i32 __random__), 0
        mov ecx, 0
        ; end initialize global variables
        ; const r1(i32 t.2), 7439742
        mov edx, 7439742
        ; copy __random__(0@global,i32), r0(i32 __random__)
        lea rax, [var_0]
        mov [rax], ecx
        ; call _, initRandom [r1(i32 t.2)]
        push rdx
          call @initRandom
        add rsp, 8
        ; const r0(u8 i), 0
        mov cl, 0
        ; 5:2 for i < 50
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
@for_4:
        ; const r0(u8 t.4), 50
        mov cl, 50
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; lt r0(bool t.3), r1(u8 i), r0(u8 t.4)
        cmp dl, cl
        setb cl
        ; branch r0(bool t.3), false, @main_ret
        or cl, cl
        jz @main_ret
        ; call r0(u8 r), randomU8, []
        sub rsp, 8
          call @randomU8
        add rsp, 8
        mov cl, al
        ; cast r0(i64 t.5), r0(u8 r)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.5)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0(u8 t.6), 1
        mov cl, 1
        ; copy r1(u8 i), i(0@function,u8)
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0(u8 i), r1(u8 i), r0(u8 t.6)
        mov al, dl
        add al, cl
        mov cl, al
        ; copy i(0@function,u8), r0(u8 i)
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @for_4
@main_ret:
        ; release space for local variables
        add rsp, 32
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
        ; variable 0: __random__ (4)
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
