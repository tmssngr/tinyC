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

        ; void printString
        ;   rsp+24: arg str
        ;   rsp+0: var length
@printString:
        ; reserve space for local variables
        sub rsp, 16
        ; call r0, strlen, [str]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str, r0]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof r0, chr
        lea rcx, [rsp+24]
        ; const r1, 1
        mov rdx, 1
        ; call _, printStringLength [r0, r1]
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
        ; const r0, 20
        mov cl, 20
        ; 13:2 while true
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r0, 1
        mov cl, 1
        ; move r1, pos
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r0, r1, r0
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r1, 10
        mov rdx, 10
        ; move r2, number
        lea rax, [rsp+152]
        mov r9, [rax]
        ; move r3, r2
        mov r10, r9
        ; mod r1, r3, r1
        mov rax, r10
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r3, 10
        mov r10, 10
        ; div r2, r2, r3
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r1(u8), r1(i64)
        ; const r3, 48
        mov r10b, 48
        ; add r1, r1, r3
        add dl, r10b
        ; cast r3(i64), r0(u8)
        movzx r10, cl
        ; cast r3(u8*), r3(i64)
        ; Spill pos
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
        ; addrof r0, [buffer]
        lea rcx, [rsp+0]
        ; add r0, r0, r3
        add rcx, r10
        ; store [r0], r1
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r0, 0
        mov rcx, 0
        ; equals r0, r2, r0
        cmp r9, rcx
        sete cl
        ; move number, r2
        lea rax, [rsp+152]
        mov [rax], r9
        ; branch r0, false, @while_1
        or cl, cl
        jz @while_1
        ; move r0, pos
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64), r0(u8)
        movzx rdx, cl
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [buffer]
        lea r9, [rsp+0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; const r2, 20
        mov r9b, 20
        ; sub r0, r2, r0
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; call _, printStringLength [r1, r0]
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
        ; const r0, 0
        mov rcx, 0
        ; move r1, number
        lea rax, [rsp+40]
        mov rdx, [rax]
        ; lt r0, r1, r0
        cmp rdx, rcx
        setl cl
        ; branch r0, false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; const r0, 45
        mov cl, 45
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; move r0, number
        lea rax, [rsp+40]
        mov rcx, [rax]
        ; neg r0, r0
        neg rcx
        ; move number, r0
        lea rax, [rsp+40]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+40]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r0, 10
        mov cl, 10
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; i64 strlen
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
@strlen:
        ; reserve space for local variables
        sub rsp, 48
        ; const r0, 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
        jmp @for_4
@for_4_body:
        ; const r0, 1
        mov rcx, 1
        ; move r1, length
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; move r1, str
        lea rax, [rsp+56]
        mov rdx, [rax]
        ; cast r1(i64), r1(u8*)
        ; const r2, 1
        mov r9, 1
        ; add r1, r1, r2
        add rdx, r9
        ; cast r1(u8*), r1(i64)
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
        ; move str, r1
        lea rax, [rsp+56]
        mov [rax], rdx
@for_4:
        ; move r0, str
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; load r1, [r0]
        mov dl, [rcx]
        ; const r2, 0
        mov r9b, 0
        ; notequals r1, r1, r2
        cmp dl, r9b
        setne dl
        ; branch r1, true, @for_4_body
        or dl, dl
        jnz @for_4_body
        ; 40:9 return length
        ; move r0, length
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+5: var d
        ;   rsp+8: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
        ;   rsp+48: var t.9
        ;   rsp+56: var t.10
        ;   rsp+64: var t.11
        ;   rsp+72: var t.12
        ;   rsp+80: var t.13
        ;   rsp+88: var t.14
        ;   rsp+96: var t.15
        ;   rsp+104: var t.16
        ;   rsp+112: var t.17
        ;   rsp+120: var t.18
        ;   rsp+128: var t.19
        ;   rsp+136: var t.20
        ;   rsp+144: var t.21
        ;   rsp+152: var t.22
        ;   rsp+160: var t.23
        ;   rsp+168: var t.24
        ;   rsp+176: var t.25
        ;   rsp+184: var t.26
        ;   rsp+192: var t.27
        ;   rsp+200: var t.28
        ;   rsp+208: var t.29
        ;   rsp+216: var t.30
        ;   rsp+224: var t.31
        ;   rsp+232: var t.32
        ;   rsp+240: var t.33
        ;   rsp+248: var t.34
        ;   rsp+256: var t.35
        ;   rsp+264: var t.36
        ;   rsp+272: var t.37
        ;   rsp+280: var t.38
        ;   rsp+288: var t.39
        ;   rsp+296: var t.40
        ;   rsp+304: var t.41
        ;   rsp+312: var t.42
        ;   rsp+320: var t.43
        ;   rsp+328: var t.44
        ;   rsp+336: var t.45
        ;   rsp+344: var t.46
        ;   rsp+352: var t.47
        ;   rsp+360: var t.48
        ;   rsp+368: var t.49
        ;   rsp+376: var t.50
        ;   rsp+384: var t.51
        ;   rsp+392: var t.52
        ;   rsp+400: var t.53
@main:
        ; reserve space for local variables
        sub rsp, 416
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; const r0, 1
        mov cx, 1
        ; const r1, 2
        mov dx, 2
        ; lt r2, r0, r1
        cmp cx, dx
        setl r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; move a, r0
        lea rax, [rsp+0]
        mov [rax], cx
        ; move b, r1
        lea rax, [rsp+2]
        mov [rax], dx
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, a
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lt r2, r0, r1
        cmp cx, dx
        setl r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-1]
        lea rcx, [string_1]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; const r0, 0
        mov cl, 0
        ; const r1, 128
        mov dl, 128
        ; lt r2, r0, r1
        cmp cl, dl
        setb r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; move c, r0
        lea rax, [rsp+4]
        mov [rax], cl
        ; move d, r1
        lea rax, [rsp+5]
        mov [rax], dl
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, d
        lea rax, [rsp+5]
        mov cl, [rax]
        ; move r1, c
        lea rax, [rsp+4]
        mov dl, [rax]
        ; lt r2, r0, r1
        cmp cl, dl
        setb r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-2]
        lea rcx, [string_2]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, b
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lteq r2, r0, r1
        cmp cx, dx
        setle r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, a
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lteq r2, r0, r1
        cmp cx, dx
        setle r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-3]
        lea rcx, [string_3]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, c
        lea rax, [rsp+4]
        mov cl, [rax]
        ; move r1, d
        lea rax, [rsp+5]
        mov dl, [rax]
        ; lteq r2, r0, r1
        cmp cl, dl
        setbe r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, d
        lea rax, [rsp+5]
        mov cl, [rax]
        ; move r1, c
        lea rax, [rsp+4]
        mov dl, [rax]
        ; lteq r2, r0, r1
        cmp cl, dl
        setbe r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-4]
        lea rcx, [string_4]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, b
        lea rax, [rsp+2]
        mov dx, [rax]
        ; equals r2, r0, r1
        cmp cx, dx
        sete r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, a
        lea rax, [rsp+0]
        mov dx, [rax]
        ; equals r2, r0, r1
        cmp cx, dx
        sete r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-5]
        lea rcx, [string_5]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, b
        lea rax, [rsp+2]
        mov dx, [rax]
        ; notequals r2, r0, r1
        cmp cx, dx
        setne r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, a
        lea rax, [rsp+0]
        mov dx, [rax]
        ; notequals r2, r0, r1
        cmp cx, dx
        setne r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-6]
        lea rcx, [string_6]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, b
        lea rax, [rsp+2]
        mov dx, [rax]
        ; gteq r2, r0, r1
        cmp cx, dx
        setge r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, a
        lea rax, [rsp+0]
        mov dx, [rax]
        ; gteq r2, r0, r1
        cmp cx, dx
        setge r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-7]
        lea rcx, [string_7]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, c
        lea rax, [rsp+4]
        mov cl, [rax]
        ; move r1, d
        lea rax, [rsp+5]
        mov dl, [rax]
        ; gteq r2, r0, r1
        cmp cl, dl
        setae r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, d
        lea rax, [rsp+5]
        mov cl, [rax]
        ; move r1, c
        lea rax, [rsp+4]
        mov dl, [rax]
        ; gteq r2, r0, r1
        cmp cl, dl
        setae r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0, [string-8]
        lea rcx, [string_8]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, a
        lea rax, [rsp+0]
        mov cx, [rax]
        ; move r1, b
        lea rax, [rsp+2]
        mov dx, [rax]
        ; gt r2, r0, r1
        cmp cx, dx
        setg r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, b
        lea rax, [rsp+2]
        mov cx, [rax]
        ; move r1, a
        lea rax, [rsp+0]
        mov dx, [rax]
        ; gt r0, r0, r1
        cmp cx, dx
        setg cl
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0, [string-9]
        lea rcx, [string_9]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; move r0, c
        lea rax, [rsp+4]
        mov cl, [rax]
        ; move r1, d
        lea rax, [rsp+5]
        mov dl, [rax]
        ; gt r2, r0, r1
        cmp cl, dl
        seta r9b
        ; cast r2(i64), r2(bool)
        movzx r9, r9b
        ; call _, printIntLf [r2]
        push r9
          call @printIntLf
        add rsp, 8
        ; move r0, d
        lea rax, [rsp+5]
        mov cl, [rax]
        ; move r1, c
        lea rax, [rsp+4]
        mov dl, [rax]
        ; gt r0, r0, r1
        cmp cl, dl
        seta cl
        ; cast r0(i64), r0(bool)
        movzx rcx, cl
        ; call _, printIntLf [r0]
        push rcx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 416
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
