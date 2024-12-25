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

        ; void main
@main:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const r6, 32
        mov bl, 32
        ; const r7, 0
        mov r12, 0
        ; cast r7(u8*), r7(i64)
        ; addrof r0, [chars]
        lea rax, [var_0]
        ; add r0, r0, r7
        add rax, r12
        ; store [r0], r6
        mov [rax], bl
        ; const r6, 0
        mov rbx, 0
        ; cast r6(u8*), r6(i64)
        ; addrof r7, [chars]
        lea r12, [var_0]
        ; add r7, r7, r6
        add r12, rbx
        ; load r6, [r7]
        mov bl, [r12]
        ; const r7, 1
        mov r12b, 1
        ; add r6, r6, r7
        add bl, r12b
        ; const r7, 1
        mov r12, 1
        ; cast r7(u8*), r7(i64)
        ; addrof r0, [chars]
        lea rax, [var_0]
        ; add r0, r0, r7
        add rax, r12
        ; store [r0], r6
        mov [rax], bl
        ; const r6, 1
        mov rbx, 1
        ; cast r6(u8*), r6(i64)
        ; addrof r7, [chars]
        lea r12, [var_0]
        ; add r7, r7, r6
        add r12, rbx
        ; load r6, [r7]
        mov bl, [r12]
        ; const r7, 2
        mov r12b, 2
        ; add r6, r6, r7
        add bl, r12b
        ; const r7, 2
        mov r12b, 2
        ; cast r7(i64), r7(u8)
        movzx r12, r12b
        ; cast r7(u8*), r7(i64)
        ; addrof r0, [chars]
        lea rax, [var_0]
        ; add r0, r0, r7
        add rax, r12
        ; store [r0], r6
        mov [rax], bl
        ; const r6, 2
        mov rbx, 2
        ; cast r6(u8*), r6(i64)
        ; addrof r7, [chars]
        lea r12, [var_0]
        ; add r7, r7, r6
        add r12, rbx
        ; load r6, [r7]
        mov bl, [r12]
        ; cast r1(i64), r6(u8)
        movzx rcx, bl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
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
        ; variable 0: chars[] (u8*/2048)
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
