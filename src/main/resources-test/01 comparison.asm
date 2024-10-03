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
        ; call r0(i64 length), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r0(i64 length)]
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
        ; const r0(i64 length), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r0(i64 length)
        lea rax, [rsp+0]
        mov [rax], rcx
@for_4:
        ; copy r0(u8* str), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; load r1(u8 t.3), [r0(u8* str)]
        mov dl, [rcx]
        ; const r2(u8 t.4), 0
        mov r9b, 0
        ; notequals r1(bool t.2), r1(u8 t.3), r2(u8 t.4)
        cmp dl, r9b
        setne dl
        ; branch r1(bool t.2), false, @for_4_break
        or dl, dl
        jz @for_4_break
        ; const r0(i64 t.5), 1
        mov rcx, 1
        ; copy r1(i64 length), length(1@function,i64)
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r0(i64 length), r1(i64 length), r0(i64 t.5)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; copy length(1@function,i64), r0(i64 length)
        lea rax, [rsp+0]
        mov [rax], rcx
        ; copy r0(u8* str), str(0@argument,u8*)
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; cast r0(i64 t.7), r0(u8* str)
        ; const r1(i64 t.8), 1
        mov rdx, 1
        ; add r0(i64 t.6), r0(i64 t.7), r1(i64 t.8)
        add rcx, rdx
        ; cast r0(u8* str), r0(i64 t.6)
        ; copy str(0@argument,u8*), r0(u8* str)
        lea rax, [rsp+56]
        mov [rax], rcx
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; copy r0(i64 length), length(1@function,i64)
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0(i64 length)
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
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
        ; const r0(u8* t.4), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0(u8* t.4)]
        push rcx
          call @printString
        add rsp, 8
        ; const r0(i16 a), 1
        mov cx, 1
        ; const r1(i16 b), 2
        mov dx, 2
        ; lt r2(bool t.6), r0(i16 a), r1(i16 b)
        cmp cx, dx
        setl r9b
        ; cast r2(i64 t.5), r2(bool t.6)
        movzx r9, r9b
        ; copy a(0@function,i16), r0(i16 a)
        lea rax, [rsp+0]
        mov [rax], cx
        ; copy b(1@function,i16), r1(i16 b)
        lea rax, [rsp+2]
        mov [rax], dx
        ; call _, printIntLf [r2(i64 t.5)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lt r2(bool t.8), r0(i16 b), r1(i16 a)
        cmp cx, dx
        setl r9b
        ; cast r2(i64 t.7), r2(bool t.8)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.7)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.9), [string-1]
        lea rcx, [string_1]
        ; call _, printString [r0(u8* t.9)]
        push rcx
          call @printString
        add rsp, 8
        ; const r0(u8 c), 0
        mov cl, 0
        ; const r1(u8 d), 128
        mov dl, 128
        ; lt r2(bool t.11), r0(u8 c), r1(u8 d)
        cmp cl, dl
        setb r9b
        ; cast r2(i64 t.10), r2(bool t.11)
        movzx r9, r9b
        ; copy c(2@function,u8), r0(u8 c)
        lea rax, [rsp+4]
        mov [rax], cl
        ; copy d(3@function,u8), r1(u8 d)
        lea rax, [rsp+5]
        mov [rax], dl
        ; call _, printIntLf [r2(i64 t.10)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov cl, [rax]
        ; copy r1(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov dl, [rax]
        ; lt r2(bool t.13), r0(u8 d), r1(u8 c)
        cmp cl, dl
        setb r9b
        ; cast r2(i64 t.12), r2(bool t.13)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.12)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.14), [string-2]
        lea rcx, [string_2]
        ; call _, printString [r0(u8* t.14)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lteq r2(bool t.16), r0(i16 a), r1(i16 b)
        cmp cx, dx
        setle r9b
        ; cast r2(i64 t.15), r2(bool t.16)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.15)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lteq r2(bool t.18), r0(i16 b), r1(i16 a)
        cmp cx, dx
        setle r9b
        ; cast r2(i64 t.17), r2(bool t.18)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.17)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.19), [string-3]
        lea rcx, [string_3]
        ; call _, printString [r0(u8* t.19)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov cl, [rax]
        ; copy r1(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov dl, [rax]
        ; lteq r2(bool t.21), r0(u8 c), r1(u8 d)
        cmp cl, dl
        setbe r9b
        ; cast r2(i64 t.20), r2(bool t.21)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.20)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov cl, [rax]
        ; copy r1(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov dl, [rax]
        ; lteq r2(bool t.23), r0(u8 d), r1(u8 c)
        cmp cl, dl
        setbe r9b
        ; cast r2(i64 t.22), r2(bool t.23)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.22)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.24), [string-4]
        lea rcx, [string_4]
        ; call _, printString [r0(u8* t.24)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; equals r2(bool t.26), r0(i16 a), r1(i16 b)
        cmp cx, dx
        sete r9b
        ; cast r2(i64 t.25), r2(bool t.26)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.25)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; equals r2(bool t.28), r0(i16 b), r1(i16 a)
        cmp cx, dx
        sete r9b
        ; cast r2(i64 t.27), r2(bool t.28)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.27)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.29), [string-5]
        lea rcx, [string_5]
        ; call _, printString [r0(u8* t.29)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; notequals r2(bool t.31), r0(i16 a), r1(i16 b)
        cmp cx, dx
        setne r9b
        ; cast r2(i64 t.30), r2(bool t.31)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.30)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; notequals r2(bool t.33), r0(i16 b), r1(i16 a)
        cmp cx, dx
        setne r9b
        ; cast r2(i64 t.32), r2(bool t.33)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.32)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.34), [string-6]
        lea rcx, [string_6]
        ; call _, printString [r0(u8* t.34)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; gteq r2(bool t.36), r0(i16 a), r1(i16 b)
        cmp cx, dx
        setge r9b
        ; cast r2(i64 t.35), r2(bool t.36)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.35)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; gteq r2(bool t.38), r0(i16 b), r1(i16 a)
        cmp cx, dx
        setge r9b
        ; cast r2(i64 t.37), r2(bool t.38)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.37)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.39), [string-7]
        lea rcx, [string_7]
        ; call _, printString [r0(u8* t.39)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov cl, [rax]
        ; copy r1(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov dl, [rax]
        ; gteq r2(bool t.41), r0(u8 c), r1(u8 d)
        cmp cl, dl
        setae r9b
        ; cast r2(i64 t.40), r2(bool t.41)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.40)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov cl, [rax]
        ; copy r1(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov dl, [rax]
        ; gteq r2(bool t.43), r0(u8 d), r1(u8 c)
        cmp cl, dl
        setae r9b
        ; cast r2(i64 t.42), r2(bool t.43)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.42)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.44), [string-8]
        lea rcx, [string_8]
        ; call _, printString [r0(u8* t.44)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; gt r2(bool t.46), r0(i16 a), r1(i16 b)
        cmp cx, dx
        setg r9b
        ; cast r2(i64 t.45), r2(bool t.46)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.45)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; gt r0(bool t.48), r0(i16 b), r1(i16 a)
        cmp cx, dx
        setg cl
        ; cast r0(i64 t.47), r0(bool t.48)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.47)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.49), [string-9]
        lea rcx, [string_9]
        ; call _, printString [r0(u8* t.49)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov cl, [rax]
        ; copy r1(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov dl, [rax]
        ; gt r2(bool t.51), r0(u8 c), r1(u8 d)
        cmp cl, dl
        seta r9b
        ; cast r2(i64 t.50), r2(bool t.51)
        movzx r9, r9b
        ; call _, printIntLf [r2(i64 t.50)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(u8 d), d(3@function,u8)
        lea rax, [rsp+5]
        mov cl, [rax]
        ; copy r1(u8 c), c(2@function,u8)
        lea rax, [rsp+4]
        mov dl, [rax]
        ; gt r0(bool t.53), r0(u8 d), r1(u8 c)
        cmp cl, dl
        seta cl
        ; cast r0(i64 t.52), r0(bool t.53)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.52)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 416
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
