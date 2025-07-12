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
        ; call r0 = strlen[r1] -> i64
        sub rsp, 20h; shadow space
        call @strlen
        add rsp, 20h
        ; move r1, r6
        mov rcx, rbx
        ; move r2, r0
        mov rdx, rax
        ; call printStringLength[r1, r2]
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
        ; call printStringLength[r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const r0, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; inc r0
        inc rax
        ; cast r2(i64), r1(u8*)
        mov rdx, rcx
        ; const r3, 1
        mov r8, 1
        ; add r2, r2, r3
        add rdx, r8
        ; cast r1(u8*), r2(i64)
        mov rcx, rdx
@for_1:
        ; load r2, [r1]
        mov dl, [rcx]
        ; notequals r2, r2, 0
        cmp dl, 0
        setne dl
        ; branch r2, true, @for_1_body
        or dl, dl
        jnz @for_1_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void printNibble
        ;   rsp+16: arg x
@printNibble:
        ; save globbered non-volatile registers
        push rbx
        ; const r6, 15
        mov bl, 15
        ; and r1, r1, r6
        and cl, bl
        ; 5:2 if x > 9
        ; gt r6, r1, 9
        cmp cl, 9
        seta bl
        ; branch r6, false, @if_2_end
        or bl, bl
        jz @if_2_end
        ; add r1, 7
        add cl, 7
@if_2_end:
        ; add r1, 48
        add cl, 48
        ; call printChar[r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; void printHex2
        ;   rsp+32: arg x
@printHex2:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov bl, cl
        ; const r1, 4
        mov cl, 4
        ; move r7, r6
        mov r12b, bl
        ; shiftright r7, r7, r1
        shr r12b, cl
        ; move r1, r7
        mov cl, r12b
        ; call printNibble[r1]
        sub rsp, 20h; shadow space
        call @printNibble
        add rsp, 20h
        ; move r1, r6
        mov cl, bl
        ; call printNibble[r1]
        sub rsp, 20h; shadow space
        call @printNibble
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
        ; const r1, [string-0]
        lea rcx, [string_0]
        ; call printString[r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const r6, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; const r7, 7
        mov r12b, 7
        ; move r0, r6
        mov al, bl
        ; and r0, r0, r7
        and al, r12b
        ; equals r7, r0, 0
        cmp al, 0
        sete r12b
        ; branch r7, false, @if_4_end
        or r12b, r12b
        jz @if_4_end
        ; const r1, 32
        mov cl, 32
        ; call printChar[r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@if_4_end:
        ; move r1, r6
        mov cl, bl
        ; call printNibble[r1]
        sub rsp, 20h; shadow space
        call @printNibble
        add rsp, 20h
        ; inc r6
        inc bl
@for_3:
        ; lt r7, r6, 16
        cmp bl, 16
        setb r12b
        ; branch r7, true, @for_3_body
        or r12b, r12b
        jnz @for_3_body
        ; const r1, 10
        mov cl, 10
        ; call printChar[r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const r6, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; const r7, 15
        mov r12b, 15
        ; move r0, r6
        mov al, bl
        ; and r0, r0, r7
        and al, r12b
        ; equals r7, r0, 0
        cmp al, 0
        sete r12b
        ; branch r7, false, @if_6_end
        or r12b, r12b
        jz @if_6_end
        ; move r1, r6
        mov cl, bl
        ; call printHex2[r1]
        sub rsp, 20h; shadow space
        call @printHex2
        add rsp, 20h
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const r7, 7
        mov r12b, 7
        ; move r0, r6
        mov al, bl
        ; and r0, r0, r7
        and al, r12b
        ; equals r7, r0, 0
        cmp al, 0
        sete r12b
        ; branch r7, false, @if_7_end
        or r12b, r12b
        jz @if_7_end
        ; const r1, 32
        mov cl, 32
        ; call printChar[r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@if_7_end:
        ; move r1, r6
        mov cl, bl
        ; call printChar[r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; 35:3 if i & 15 == 15
        ; const r7, 15
        mov r12b, 15
        ; move r0, r6
        mov al, bl
        ; and r0, r0, r7
        and al, r12b
        ; equals r7, r0, 15
        cmp al, 15
        sete r12b
        ; branch r7, false, @for_5_continue
        or r12b, r12b
        jz @for_5_continue
        ; const r1, 10
        mov cl, 10
        ; call printChar[r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@for_5_continue:
        ; inc r6
        inc bl
@for_5:
        ; lt r0, r6, 128
        cmp bl, 128
        setb al
        ; branch r0, true, @for_5_body
        or al, al
        jnz @for_5_body
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
        string_0 db ' x', 0x00

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
