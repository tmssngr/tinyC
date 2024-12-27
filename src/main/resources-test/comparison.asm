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

        ; void printString
        ;   rsp+16: arg str
@printString:
        ; save globbered non-volatile registers
        push rbx
        ; move r6, r1
        mov rbx, rcx
        ; move r1, r6
        mov rcx, rbx
        ; call r0, strlen, [r1]
        sub rsp, 20h; shadow space
        call @strlen
        add rsp, 20h
        ; move r1, r6
        mov rcx, rbx
        ; move r2, r0
        mov rdx, rax
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

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

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const r0, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; const r2, 1
        mov rdx, 1
        ; add r0, r0, r2
        add rax, rdx
        ; cast r2(i64), r1(u8*)
        mov rdx, rcx
        ; const r3, 1
        mov r8, 1
        ; add r2, r2, r3
        add rdx, r8
        ; cast r1(u8*), r2(i64)
        mov rcx, rdx
@for_4:
        ; load r2, [r1]
        mov dl, [rcx]
        ; const r3, 0
        mov r8b, 0
        ; notequals r2, r2, r3
        cmp dl, r8b
        setne dl
        ; branch r2, true, @for_4_body
        or dl, dl
        jnz @for_4_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void main
        ;   rsp+16: var c
        ;   rsp+17: var d
@main:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const r1, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const r6, 1
        mov bx, 1
        ; const r7, 2
        mov r12w, 2
        ; lt r0, r6, r7
        cmp bx, r12w
        setl al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; lt r0, r7, r6
        cmp r12w, bx
        setl al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-1]
        lea rcx, [string_1]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const r0, 0
        mov al, 0
        ; const r2, 128
        mov dl, 128
        ; lt r3, r0, r2
        cmp al, dl
        setb r8b
        ; cast r1(i64), r3(bool)
        movzx rcx, r8b
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move d, r2
        lea r11, [rsp+17]
        mov [r11], dl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, c
        lea r11, [rsp+16]
        mov al, [r11]
        ; move r2, d
        lea r11, [rsp+17]
        mov dl, [r11]
        ; lt r3, r2, r0
        cmp dl, al
        setb r8b
        ; cast r1(i64), r3(bool)
        movzx rcx, r8b
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move d, r2
        lea r11, [rsp+17]
        mov [r11], dl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-2]
        lea rcx, [string_2]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; lteq r0, r6, r7
        cmp bx, r12w
        setle al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; lteq r0, r7, r6
        cmp r12w, bx
        setle al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-3]
        lea rcx, [string_3]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move r0, c
        lea r11, [rsp+16]
        mov al, [r11]
        ; move r2, d
        lea r11, [rsp+17]
        mov dl, [r11]
        ; lteq r3, r0, r2
        cmp al, dl
        setbe r8b
        ; cast r1(i64), r3(bool)
        movzx rcx, r8b
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move d, r2
        lea r11, [rsp+17]
        mov [r11], dl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, c
        lea r11, [rsp+16]
        mov al, [r11]
        ; move r2, d
        lea r11, [rsp+17]
        mov dl, [r11]
        ; lteq r3, r2, r0
        cmp dl, al
        setbe r8b
        ; cast r1(i64), r3(bool)
        movzx rcx, r8b
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move d, r2
        lea r11, [rsp+17]
        mov [r11], dl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-4]
        lea rcx, [string_4]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; equals r0, r6, r7
        cmp bx, r12w
        sete al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; equals r0, r7, r6
        cmp r12w, bx
        sete al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-5]
        lea rcx, [string_5]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; notequals r0, r6, r7
        cmp bx, r12w
        setne al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; notequals r0, r7, r6
        cmp r12w, bx
        setne al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-6]
        lea rcx, [string_6]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; gteq r0, r6, r7
        cmp bx, r12w
        setge al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; gteq r0, r7, r6
        cmp r12w, bx
        setge al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-7]
        lea rcx, [string_7]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move r0, c
        lea r11, [rsp+16]
        mov al, [r11]
        ; move r2, d
        lea r11, [rsp+17]
        mov dl, [r11]
        ; gteq r3, r0, r2
        cmp al, dl
        setae r8b
        ; cast r1(i64), r3(bool)
        movzx rcx, r8b
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move d, r2
        lea r11, [rsp+17]
        mov [r11], dl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, c
        lea r11, [rsp+16]
        mov al, [r11]
        ; move r2, d
        lea r11, [rsp+17]
        mov dl, [r11]
        ; gteq r3, r2, r0
        cmp dl, al
        setae r8b
        ; cast r1(i64), r3(bool)
        movzx rcx, r8b
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move d, r2
        lea r11, [rsp+17]
        mov [r11], dl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-8]
        lea rcx, [string_8]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; gt r0, r6, r7
        cmp bx, r12w
        setg al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; gt r6, r7, r6
        cmp r12w, bx
        setg bl
        ; cast r1(i64), r6(bool)
        movzx rcx, bl
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r1, [string-9]
        lea rcx, [string_9]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move r6, c
        lea r11, [rsp+16]
        mov bl, [r11]
        ; move r7, d
        lea r11, [rsp+17]
        mov r12b, [r11]
        ; gt r0, r6, r7
        cmp bl, r12b
        seta al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; gt r6, r7, r6
        cmp r12b, bl
        seta bl
        ; cast r1(i64), r6(bool)
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

section '.data' data readable
        string_0 db '< (signed)', 0x0a, 0x00
        string_1 db '< (unsigned)', 0x0a, 0x00
        string_2 db '<= (signed)', 0x0a, 0x00
        string_3 db '<= (unsigned)', 0x0a, 0x00
        string_4 db '==', 0x0a, 0x00
        string_5 db '!=', 0x0a, 0x00
        string_6 db '>= (signed)', 0x0a, 0x00
        string_7 db '>= (unsigned)', 0x0a, 0x00
        string_8 db '> (signed)', 0x0a, 0x00
        string_9 db '> (unsigned)', 0x0a, 0x00

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
