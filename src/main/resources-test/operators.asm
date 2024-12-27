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
        ;   rsp+18: var d
        ;   rsp+20: var t
        ;   rsp+21: var f
        ;   rsp+22: var b1
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
        ; const r6, 0
        mov bx, 0
        ; const r7, 1
        mov r12w, 1
        ; const r0, 2
        mov ax, 2
        ; const r2, 3
        mov dx, 3
        ; const r3, 1
        mov r8b, 1
        ; const r4, 0
        mov r9b, 0
        ; move r5, r6
        mov r10w, bx
        ; and r5, r5, r6
        and r10w, bx
        ; cast r1(i64), r5(i16)
        movzx rcx, r10w
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move d, r2
        lea r11, [rsp+18]
        mov [r11], dx
        ; move t, r3
        lea r11, [rsp+20]
        mov [r11], r8b
        ; move f, r4
        lea r11, [rsp+21]
        mov [r11], r9b
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r6
        mov ax, bx
        ; and r0, r0, r7
        and ax, r12w
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r7
        mov ax, r12w
        ; and r0, r0, r6
        and ax, bx
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r7
        mov ax, r12w
        ; and r0, r0, r7
        and ax, r12w
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
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
        ; move r0, r6
        mov ax, bx
        ; or r0, r0, r6
        or ax, bx
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r6
        mov ax, bx
        ; or r0, r0, r7
        or ax, r12w
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r7
        mov ax, r12w
        ; or r0, r0, r6
        or ax, bx
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r7
        mov ax, r12w
        ; or r0, r0, r7
        or ax, r12w
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
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
        ; move r0, r6
        mov ax, bx
        ; xor r0, r0, r6
        xor ax, bx
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r6
        mov ax, bx
        ; move r2, c
        lea r11, [rsp+16]
        mov dx, [r11]
        ; xor r0, r0, r2
        xor ax, dx
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; move c, r2
        lea r11, [rsp+16]
        mov [r11], dx
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, r7
        mov ax, r12w
        ; xor r0, r0, r6
        xor ax, bx
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r6, r7
        mov bx, r12w
        ; move r0, c
        lea r11, [rsp+16]
        mov ax, [r11]
        ; xor r6, r6, r0
        xor bx, ax
        ; cast r1(i64), r6(i16)
        movzx rcx, bx
        ; move r6, r0
        mov bx, ax
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
        ; 26:15 logic and
        ; move r0, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, false, @and_next_5
        or dl, dl
        jz @and_next_5
        ; move r2, r0
        mov dl, al
@and_next_5:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move f, r0
        lea r11, [rsp+21]
        mov [r11], al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 27:15 logic and
        ; move r0, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, true, @and_2nd_6
        or dl, dl
        jnz @and_2nd_6
        ; move r3, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        jmp @and_next_6
@and_2nd_6:
        ; move r3, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        ; move r2, r3
        mov dl, r8b
@and_next_6:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move t, r3
        lea r11, [rsp+20]
        mov [r11], r8b
        ; move f, r0
        lea r11, [rsp+21]
        mov [r11], al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 28:15 logic and
        ; move r0, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, true, @and_2nd_7
        or dl, dl
        jnz @and_2nd_7
        ; move r3, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        jmp @and_next_7
@and_2nd_7:
        ; move r3, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        ; move r2, r3
        mov dl, r8b
@and_next_7:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move t, r0
        lea r11, [rsp+20]
        mov [r11], al
        ; move f, r3
        lea r11, [rsp+21]
        mov [r11], r8b
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 29:15 logic and
        ; move r0, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, false, @and_next_8
        or dl, dl
        jz @and_next_8
        ; move r2, r0
        mov dl, al
@and_next_8:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move t, r0
        lea r11, [rsp+20]
        mov [r11], al
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
        ; 31:15 logic or
        ; move r0, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, true, @or_next_9
        or dl, dl
        jnz @or_next_9
        ; move r2, r0
        mov dl, al
@or_next_9:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move f, r0
        lea r11, [rsp+21]
        mov [r11], al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 32:15 logic or
        ; move r0, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, false, @or_2nd_10
        or dl, dl
        jz @or_2nd_10
        ; move r3, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        jmp @or_next_10
@or_2nd_10:
        ; move r3, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        ; move r2, r3
        mov dl, r8b
@or_next_10:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move t, r3
        lea r11, [rsp+20]
        mov [r11], r8b
        ; move f, r0
        lea r11, [rsp+21]
        mov [r11], al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 33:15 logic or
        ; move r0, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, false, @or_2nd_11
        or dl, dl
        jz @or_2nd_11
        ; move r3, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        jmp @or_next_11
@or_2nd_11:
        ; move r3, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        ; move r2, r3
        mov dl, r8b
@or_next_11:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move t, r0
        lea r11, [rsp+20]
        mov [r11], al
        ; move f, r3
        lea r11, [rsp+21]
        mov [r11], r8b
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 34:15 logic or
        ; move r0, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move r2, r0
        mov dl, al
        ; branch r2, true, @or_next_12
        or dl, dl
        jnz @or_next_12
        ; move r2, r0
        mov dl, al
@or_next_12:
        ; cast r1(i64), r2(bool)
        movzx rcx, dl
        ; move t, r0
        lea r11, [rsp+20]
        mov [r11], al
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
        ; move r0, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; notlog r0, r0
        or al, al
        sete al
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r0, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; notlog r0, r0
        or al, al
        sete al
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
        ; const r0, 10
        mov al, 10
        ; const r2, 6
        mov dl, 6
        ; const r3, 1
        mov r8b, 1
        ; and r0, r0, r2
        and al, dl
        ; or r0, r0, r3
        or al, r8b
        ; cast r1(i64), r0(u8)
        movzx rcx, al
        ; move b1, r3
        lea r11, [rsp+22]
        mov [r11], r8b
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 43:20 logic or
        ; equals r0, r7, r6
        cmp r12w, bx
        sete al
        ; branch r0, false, @or_2nd_13
        or al, al
        jz @or_2nd_13
        ; move r2, d
        lea r11, [rsp+18]
        mov dx, [r11]
        jmp @or_next_13
@or_2nd_13:
        ; move r2, d
        lea r11, [rsp+18]
        mov dx, [r11]
        ; lt r0, r6, r2
        cmp bx, dx
        setl al
@or_next_13:
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; move d, r2
        lea r11, [rsp+18]
        mov [r11], dx
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 44:20 logic and
        ; equals r0, r7, r6
        cmp r12w, bx
        sete al
        ; branch r0, false, @and_next_14
        or al, al
        jz @and_next_14
        ; move r2, d
        lea r11, [rsp+18]
        mov dx, [r11]
        ; lt r0, r6, r2
        cmp bx, dx
        setl al
@and_next_14:
        ; cast r1(i64), r0(bool)
        movzx rcx, al
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const r6, -1
        mov bx, -1
        ; cast r1(i64), r6(i16)
        movzx rcx, bx
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; neg r6, r7
        mov rbx, r12
        neg rbx
        ; cast r1(i64), r6(i16)
        movzx rcx, bx
        ; call _, printIntLf [r1]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move r6, b1
        lea r11, [rsp+22]
        mov bl, [r11]
        ; not r6, r6
        not rbx
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

section '.data' data readable
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

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
