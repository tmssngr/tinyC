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
        call init
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printChar
        ;   rsp+16: arg chr
@printChar:
        ; save globbered non-volatile registers
        push rbx
        ; addrof r6, chr
        lea rbx, [rsp+16]
        ; const r2, 1
        mov rdx, 1
        ; move chr, r1
        lea r11, [rsp+16]
        mov [r11], cl
        ; move r1, r6
        mov rcx, rbx
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; void printUint
        ;   rsp+48: arg number
        ;   rsp+20: var buffer
@printUint:
        sub rsp, 24
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov rbx, rcx
        ; const r7, 20
        mov r12b, 20
        ; 13:2 while true
@while_1:
        ; const r3, 1
        mov r8b, 1
        ; sub r7, r7, r3
        sub r12b, r8b
        ; const r3, 10
        mov r8, 10
        ; move r4, r6
        mov r9, rbx
        ; move r0, r4
        mov rax, r9
        ; mod r2, r0, r3
        cqo
        idiv r8
        ; move r4, r2
        mov r9, rdx
        ; const r3, 10
        mov r8, 10
        ; move r0, r6
        mov rax, rbx
        ; div r0, r0, r3
        cqo
        idiv r8
        ; move r6, r0
        mov rbx, rax
        ; cast r0(u8), r4(i64)
        mov al, r9b
        ; const r3, 48
        mov r8b, 48
        ; add r0, r0, r3
        add al, r8b
        ; cast r3(i64), r7(u8)
        movzx r8, r12b
        ; cast r3(u8*), r3(i64)
        ; addrof r4, [buffer]
        lea r9, [rsp+20]
        ; add r4, r4, r3
        add r9, r8
        ; store [r4], r0
        mov [r9], al
        ; 19:3 if number == 0
        ; const r0, 0
        mov rax, 0
        ; equals r0, r6, r0
        cmp rbx, rax
        sete al
        ; branch r0, false, @while_1
        or al, al
        jz @while_1
        ; cast r6(i64), r7(u8)
        movzx rbx, r12b
        ; cast r6(u8*), r6(i64)
        ; addrof r1, [buffer]
        lea rcx, [rsp+20]
        ; add r1, r1, r6
        add rcx, rbx
        ; const r6, 20
        mov bl, 20
        ; sub r6, r6, r7
        sub bl, r12b
        ; cast r2(i64), r6(u8)
        movzx rdx, bl
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void printIntLf
        ;   rsp+32: arg number
@printIntLf:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov rbx, rcx
        ; 27:2 if number < 0
        ; const r7, 0
        mov r12, 0
        ; lt r7, r6, r7
        cmp rbx, r12
        setl r12b
        ; branch r7, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const r1, 45
        mov cl, 45
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; neg r6, r6
        neg rbx
@if_3_end:
        ; move r1, r6
        mov rcx, rbx
        ; call _, printUint [r1]
        sub rsp, 20h; shadow space
        call @printUint
        add rsp, 20h
        ; const r1, 10
        mov cl, 10
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void initRandom
        ;   rsp+16: arg salt
@initRandom:
        sub rsp, 8
        ; move r0, r1
        mov eax, ecx
        ; move __random__, r0
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; move r0, __random__
        lea r11, [var_0]
        mov eax, [r11]
        ; move r2, r0
        mov edx, eax
        ; const r3, 524287
        mov r8d, 524287
        ; move r4, r2
        mov r9d, edx
        ; and r4, r4, r3
        and r9d, r8d
        ; const r3, 48271
        mov r8d, 48271
        ; mul r4, r4, r3
        movsxd r9, r9d
        movsxd r8, r8d
        imul  r9, r8
        ; const r1, 15
        mov ecx, 15
        ; shiftright r2, r2, r1
        sar edx, cl
        ; const r3, 48271
        mov r8d, 48271
        ; mul r2, r2, r3
        movsxd rdx, edx
        movsxd r8, r8d
        imul  rdx, r8
        ; const r3, 65535
        mov r8d, 65535
        ; move r5, r2
        mov r10d, edx
        ; and r5, r5, r3
        and r10d, r8d
        ; const r1, 15
        mov ecx, 15
        ; move r3, r5
        mov r8d, r10d
        ; shiftleft r3, r3, r1
        sal r8d, cl
        ; const r1, 16
        mov ecx, 16
        ; shiftright r2, r2, r1
        sar edx, cl
        ; add r2, r2, r4
        add edx, r9d
        ; add r2, r2, r3
        add edx, r8d
        ; const r3, 2147483647
        mov r8d, 2147483647
        ; move r4, r2
        mov r9d, edx
        ; and r4, r4, r3
        and r9d, r8d
        ; const r1, 31
        mov ecx, 31
        ; shiftright r2, r2, r1
        sar edx, cl
        ; move r0, r4
        mov eax, r9d
        ; add r0, r0, r2
        add eax, edx
        ; 123:9 return __random__
        ; move __random__, r0
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; u8 randomU8
@randomU8:
        sub rsp, 8
        ; 127:10 return (u8)
        ; call r0, random, []
        sub rsp, 20h; shadow space
        call @random
        add rsp, 20h
        ; cast r0(u8), r0(i32)
        add rsp, 8
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push rbx
        ; begin initialize global variables
        ; const r6, 0
        mov ebx, 0
        ; end initialize global variables
        ; const r1, 7439742
        mov ecx, 7439742
        ; move __random__, r6
        lea r11, [var_0]
        mov [r11], ebx
        ; call _, initRandom [r1]
        sub rsp, 20h; shadow space
        call @initRandom
        add rsp, 20h
        ; const r6, 0
        mov bl, 0
        ; 5:2 for i < 50
        jmp @for_4
@for_4_body:
        ; call r0, randomU8, []
        sub rsp, 20h; shadow space
        call @randomU8
        add rsp, 20h
        ; cast r1(i64), r0(u8)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r0, 1
        mov al, 1
        ; add r6, r6, r0
        add bl, al
@for_4:
        ; const r0, 50
        mov al, 50
        ; lt r0, r6, r0
        cmp bl, al
        setb al
        ; branch r0, true, @for_4_body
        or al, al
        jnz @for_4_body
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; void printStringLength
@printStringLength:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret
init:
        sub rsp, 28h
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
        add rsp, 28h
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
