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
        ;   rsp+8: arg str
@printString:
        ; call r0(i64 length), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r0(i64 length)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ret

        ; void printChar
        ;   rsp+8: arg chr
@printChar:
        ; addrof r0(u8* t.1), chr(0@argument,u8)
        lea rcx, [rsp+8]
        ; const r1(i64 t.2), 1
        mov rdx, 1
        ; call _, printStringLength [r0(u8* t.1), r1(i64 t.2)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ret

        ; void printUint
        ;   rsp+40: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 32
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
        lea rax, [rsp+40]
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
        ; cast r3(i64 t.10), r0(u8 pos)
        movzx r10, cl
        ; array r3(u8* t.11), buffer(1@function,u8*) + r3(i64 t.10)
        lea rax, [rsp+0]
        add r10, rax
        ; store [r3(u8* t.11)], r1(u8 digit)
        mov [r10], dl
        ; 19:3 if number == 0
        ; const r1(i64 t.13), 0
        mov rdx, 0
        ; equals r1(bool t.12), r2(i64 number), r1(i64 t.13)
        cmp r9, rdx
        sete dl
        ; copy pos(2@function,u8), r0(u8 pos)
        lea rax, [rsp+20]
        mov [rax], cl
        ; copy number(0@argument,i64), r2(i64 number)
        lea rax, [rsp+40]
        mov [rax], r9
        ; branch r1(bool t.12), false, @while_1
        or dl, dl
        jz @while_1
        ; copy r0(u8 pos), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64 t.15), r0(u8 pos)
        movzx rdx, cl
        ; addrof r1(u8* t.14), [buffer(1@function,u8*) + r1(i64 t.15)]
        lea rax, [rsp+0]
        add rdx, rax
        ; const r2(u8 t.18), 20
        mov r9b, 20
        ; sub r0(u8 t.17), r2(u8 t.18), r0(u8 pos)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64 t.16), r0(u8 t.17)
        movzx rcx, cl
        ; call _, printStringLength [r1(u8* t.14), r0(i64 t.16)]
        push rdx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 32
        ret

        ; void printIntLf
        ;   rsp+8: arg number
@printIntLf:
        ; 27:2 if number < 0
        ; const r0(i64 t.2), 0
        mov rcx, 0
        ; copy r1(i64 number), number(0@argument,i64)
        lea rax, [rsp+8]
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
        lea rax, [rsp+8]
        mov rcx, [rax]
        ; neg r0(i64 number), r0(i64 number)
        neg rcx
        ; copy number(0@argument,i64), r0(i64 number)
        lea rax, [rsp+8]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+8]
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
        ret

        ; i64 strlen
        ;   rsp+24: arg str
        ;   rsp+0: var length
@strlen:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0(i64 length), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r0(i64 length)
        lea rax, [rsp+0]
        mov [rax], rcx
@for_4:
        ; copy r0(u8* str), str(0@argument,u8*)
        lea rax, [rsp+24]
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
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; cast r0(i64 t.7), r0(u8* str)
        ; const r1(i64 t.8), 1
        mov rdx, 1
        ; add r0(i64 t.6), r0(i64 t.7), r1(i64 t.8)
        add rcx, rdx
        ; cast r0(u8* str), r0(i64 t.6)
        ; copy str(0@argument,u8*), r0(u8* str)
        lea rax, [rsp+24]
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
        add rsp, 16
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
        ;   rsp+6: var d
        ;   rsp+8: var t
        ;   rsp+9: var f
        ;   rsp+10: var b1
        ;   rsp+11: var t.38
        ;   rsp+12: var t.40
        ;   rsp+13: var t.42
        ;   rsp+14: var t.44
        ;   rsp+15: var t.47
        ;   rsp+16: var t.49
        ;   rsp+17: var t.51
        ;   rsp+18: var t.53
        ;   rsp+19: var t.64
        ;   rsp+20: var t.66
@main:
        ; reserve space for local variables
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0(u8* t.9), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0(u8* t.9)]
        push rcx
          call @printString
        add rsp, 8
        ; const r0(i16 a), 0
        mov cx, 0
        ; const r1(i16 b), 1
        mov dx, 1
        ; const r2(i16 c), 2
        mov r9w, 2
        ; const r3(i16 d), 3
        mov r10w, 3
        ; Spill a
        ; copy a(0@function,i16), r0(i16 a)
        lea rax, [rsp+0]
        mov [rax], cx
        ; const r0(bool t), 1
        mov cl, 1
        ; Spill t
        ; copy t(4@function,bool), r0(bool t)
        lea rax, [rsp+8]
        mov [rax], cl
        ; const r0(bool f), 0
        mov cl, 0
        ; Spill f
        ; copy f(5@function,bool), r0(bool f)
        lea rax, [rsp+9]
        mov [rax], cl
        ; Spill b
        ; copy b(1@function,i16), r1(i16 b)
        lea rax, [rsp+2]
        mov [rax], dx
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; and r1(i16 t.11), r0(i16 a), r0(i16 a)
        mov dx, cx
        and dx, cx
        ; cast r1(i64 t.10), r1(i16 t.11)
        movzx rdx, dx
        ; copy c(2@function,i16), r2(i16 c)
        lea rax, [rsp+4]
        mov [rax], r9w
        ; copy d(3@function,i16), r3(i16 d)
        lea rax, [rsp+6]
        mov [rax], r10w
        ; call _, printIntLf [r1(i64 t.10)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; and r2(i16 t.13), r0(i16 a), r1(i16 b)
        mov r9w, cx
        and r9w, dx
        ; cast r2(i64 t.12), r2(i16 t.13)
        movzx r9, r9w
        ; call _, printIntLf [r2(i64 t.12)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; and r2(i16 t.15), r0(i16 b), r1(i16 a)
        mov r9w, cx
        and r9w, dx
        ; cast r2(i64 t.14), r2(i16 t.15)
        movzx r9, r9w
        ; call _, printIntLf [r2(i64 t.14)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; and r1(i16 t.17), r0(i16 b), r0(i16 b)
        mov dx, cx
        and dx, cx
        ; cast r1(i64 t.16), r1(i16 t.17)
        movzx rdx, dx
        ; call _, printIntLf [r1(i64 t.16)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.18), [string-1]
        lea rcx, [string_1]
        ; call _, printString [r0(u8* t.18)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; or r1(i16 t.20), r0(i16 a), r0(i16 a)
        mov dx, cx
        or dx, cx
        ; cast r1(i64 t.19), r1(i16 t.20)
        movzx rdx, dx
        ; call _, printIntLf [r1(i64 t.19)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; or r2(i16 t.22), r0(i16 a), r1(i16 b)
        mov r9w, cx
        or r9w, dx
        ; cast r2(i64 t.21), r2(i16 t.22)
        movzx r9, r9w
        ; call _, printIntLf [r2(i64 t.21)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; or r2(i16 t.24), r0(i16 b), r1(i16 a)
        mov r9w, cx
        or r9w, dx
        ; cast r2(i64 t.23), r2(i16 t.24)
        movzx r9, r9w
        ; call _, printIntLf [r2(i64 t.23)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; or r1(i16 t.26), r0(i16 b), r0(i16 b)
        mov dx, cx
        or dx, cx
        ; cast r1(i64 t.25), r1(i16 t.26)
        movzx rdx, dx
        ; call _, printIntLf [r1(i64 t.25)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.27), [string-2]
        lea rcx, [string_2]
        ; call _, printString [r0(u8* t.27)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; xor r1(i16 t.29), r0(i16 a), r0(i16 a)
        mov dx, cx
        xor dx, cx
        ; cast r1(i64 t.28), r1(i16 t.29)
        movzx rdx, dx
        ; call _, printIntLf [r1(i64 t.28)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 a), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r1(i16 c), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; xor r2(i16 t.31), r0(i16 a), r1(i16 c)
        mov r9w, cx
        xor r9w, dx
        ; cast r2(i64 t.30), r2(i16 t.31)
        movzx r9, r9w
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
        ; xor r1(i16 t.33), r0(i16 b), r1(i16 a)
        mov ax, cx
        xor ax, dx
        mov dx, ax
        ; cast r1(i64 t.32), r1(i16 t.33)
        movzx rdx, dx
        ; call _, printIntLf [r1(i64 t.32)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 c), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; xor r2(i16 t.35), r0(i16 b), r1(i16 c)
        mov r9w, cx
        xor r9w, dx
        ; cast r2(i64 t.34), r2(i16 t.35)
        movzx r9, r9w
        ; call _, printIntLf [r2(i64 t.34)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.36), [string-3]
        lea rcx, [string_3]
        ; call _, printString [r0(u8* t.36)]
        push rcx
          call @printString
        add rsp, 8
        ; 26:15 logic and
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.38), r0(bool f)
        mov dl, cl
        ; copy t.38(7@function,bool), r1(bool t.38)
        lea rax, [rsp+11]
        mov [rax], dl
        ; branch r1(bool t.38), false, @and_next_5
        or dl, dl
        jz @and_next_5
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.38), r0(bool f)
        mov dl, cl
        ; copy t.38(7@function,bool), r1(bool t.38)
        lea rax, [rsp+11]
        mov [rax], dl
@and_next_5:
        ; copy r0(bool t.38), t.38(7@function,bool)
        lea rax, [rsp+11]
        mov cl, [rax]
        ; cast r0(i64 t.37), r0(bool t.38)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.37)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 27:15 logic and
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.40), r0(bool f)
        mov dl, cl
        ; copy t.40(8@function,bool), r1(bool t.40)
        lea rax, [rsp+12]
        mov [rax], dl
        ; branch r1(bool t.40), false, @and_next_6
        or dl, dl
        jz @and_next_6
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.40), r0(bool t)
        mov dl, cl
        ; copy t.40(8@function,bool), r1(bool t.40)
        lea rax, [rsp+12]
        mov [rax], dl
@and_next_6:
        ; copy r0(bool t.40), t.40(8@function,bool)
        lea rax, [rsp+12]
        mov cl, [rax]
        ; cast r0(i64 t.39), r0(bool t.40)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.39)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 28:15 logic and
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.42), r0(bool t)
        mov dl, cl
        ; copy t.42(9@function,bool), r1(bool t.42)
        lea rax, [rsp+13]
        mov [rax], dl
        ; branch r1(bool t.42), false, @and_next_7
        or dl, dl
        jz @and_next_7
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.42), r0(bool f)
        mov dl, cl
        ; copy t.42(9@function,bool), r1(bool t.42)
        lea rax, [rsp+13]
        mov [rax], dl
@and_next_7:
        ; copy r0(bool t.42), t.42(9@function,bool)
        lea rax, [rsp+13]
        mov cl, [rax]
        ; cast r0(i64 t.41), r0(bool t.42)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.41)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 29:15 logic and
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.44), r0(bool t)
        mov dl, cl
        ; copy t.44(10@function,bool), r1(bool t.44)
        lea rax, [rsp+14]
        mov [rax], dl
        ; branch r1(bool t.44), false, @and_next_8
        or dl, dl
        jz @and_next_8
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.44), r0(bool t)
        mov dl, cl
        ; copy t.44(10@function,bool), r1(bool t.44)
        lea rax, [rsp+14]
        mov [rax], dl
@and_next_8:
        ; copy r0(bool t.44), t.44(10@function,bool)
        lea rax, [rsp+14]
        mov cl, [rax]
        ; cast r0(i64 t.43), r0(bool t.44)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.43)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.45), [string-4]
        lea rcx, [string_4]
        ; call _, printString [r0(u8* t.45)]
        push rcx
          call @printString
        add rsp, 8
        ; 31:15 logic or
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.47), r0(bool f)
        mov dl, cl
        ; copy t.47(11@function,bool), r1(bool t.47)
        lea rax, [rsp+15]
        mov [rax], dl
        ; branch r1(bool t.47), true, @or_next_9
        or dl, dl
        jnz @or_next_9
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.47), r0(bool f)
        mov dl, cl
        ; copy t.47(11@function,bool), r1(bool t.47)
        lea rax, [rsp+15]
        mov [rax], dl
@or_next_9:
        ; copy r0(bool t.47), t.47(11@function,bool)
        lea rax, [rsp+15]
        mov cl, [rax]
        ; cast r0(i64 t.46), r0(bool t.47)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.46)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 32:15 logic or
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.49), r0(bool f)
        mov dl, cl
        ; copy t.49(12@function,bool), r1(bool t.49)
        lea rax, [rsp+16]
        mov [rax], dl
        ; branch r1(bool t.49), true, @or_next_10
        or dl, dl
        jnz @or_next_10
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.49), r0(bool t)
        mov dl, cl
        ; copy t.49(12@function,bool), r1(bool t.49)
        lea rax, [rsp+16]
        mov [rax], dl
@or_next_10:
        ; copy r0(bool t.49), t.49(12@function,bool)
        lea rax, [rsp+16]
        mov cl, [rax]
        ; cast r0(i64 t.48), r0(bool t.49)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.48)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 33:15 logic or
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.51), r0(bool t)
        mov dl, cl
        ; copy t.51(13@function,bool), r1(bool t.51)
        lea rax, [rsp+17]
        mov [rax], dl
        ; branch r1(bool t.51), true, @or_next_11
        or dl, dl
        jnz @or_next_11
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r1(bool t.51), r0(bool f)
        mov dl, cl
        ; copy t.51(13@function,bool), r1(bool t.51)
        lea rax, [rsp+17]
        mov [rax], dl
@or_next_11:
        ; copy r0(bool t.51), t.51(13@function,bool)
        lea rax, [rsp+17]
        mov cl, [rax]
        ; cast r0(i64 t.50), r0(bool t.51)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.50)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 34:15 logic or
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.53), r0(bool t)
        mov dl, cl
        ; copy t.53(14@function,bool), r1(bool t.53)
        lea rax, [rsp+18]
        mov [rax], dl
        ; branch r1(bool t.53), true, @or_next_12
        or dl, dl
        jnz @or_next_12
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r1(bool t.53), r0(bool t)
        mov dl, cl
        ; copy t.53(14@function,bool), r1(bool t.53)
        lea rax, [rsp+18]
        mov [rax], dl
@or_next_12:
        ; copy r0(bool t.53), t.53(14@function,bool)
        lea rax, [rsp+18]
        mov cl, [rax]
        ; cast r0(i64 t.52), r0(bool t.53)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.52)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.54), [string-5]
        lea rcx, [string_5]
        ; call _, printString [r0(u8* t.54)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r0(bool f), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; notlog r0(bool t.56), r0(bool f)
        or cl, cl
        sete cl
        ; cast r0(i64 t.55), r0(bool t.56)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.55)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r0(bool t), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; notlog r0(bool t.58), r0(bool t)
        or cl, cl
        sete cl
        ; cast r0(i64 t.57), r0(bool t.58)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.57)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0(u8* t.59), [string-6]
        lea rcx, [string_6]
        ; call _, printString [r0(u8* t.59)]
        push rcx
          call @printString
        add rsp, 8
        ; const r0(u8 b10), 10
        mov cl, 10
        ; const r1(u8 b6), 6
        mov dl, 6
        ; const r2(u8 b1), 1
        mov r9b, 1
        ; and r0(u8 t.62), r0(u8 b10), r1(u8 b6)
        and cl, dl
        ; or r0(u8 t.61), r0(u8 t.62), r2(u8 b1)
        or cl, r9b
        ; cast r0(i64 t.60), r0(u8 t.61)
        movzx rcx, cl
        ; copy b1(6@function,u8), r2(u8 b1)
        lea rax, [rsp+10]
        mov [rax], r9b
        ; call _, printIntLf [r0(i64 t.60)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 43:20 logic or
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 c), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r2(bool t.64), r0(i16 b), r1(i16 c)
        cmp cx, dx
        sete r9b
        ; copy t.64(15@function,bool), r2(bool t.64)
        lea rax, [rsp+19]
        mov [rax], r9b
        ; branch r2(bool t.64), true, @or_next_13
        or r9b, r9b
        jnz @or_next_13
        ; copy r0(i16 c), c(2@function,i16)
        lea rax, [rsp+4]
        mov cx, [rax]
        ; copy r1(i16 d), d(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lt r2(bool t.64), r0(i16 c), r1(i16 d)
        cmp cx, dx
        setl r9b
        ; copy t.64(15@function,bool), r2(bool t.64)
        lea rax, [rsp+19]
        mov [rax], r9b
@or_next_13:
        ; copy r0(bool t.64), t.64(15@function,bool)
        lea rax, [rsp+19]
        mov cl, [rax]
        ; cast r0(i64 t.63), r0(bool t.64)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.63)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 44:20 logic and
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r1(i16 c), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r2(bool t.66), r0(i16 b), r1(i16 c)
        cmp cx, dx
        sete r9b
        ; copy t.66(16@function,bool), r2(bool t.66)
        lea rax, [rsp+20]
        mov [rax], r9b
        ; branch r2(bool t.66), false, @and_next_14
        or r9b, r9b
        jz @and_next_14
        ; copy r0(i16 c), c(2@function,i16)
        lea rax, [rsp+4]
        mov cx, [rax]
        ; copy r1(i16 d), d(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lt r0(bool t.66), r0(i16 c), r1(i16 d)
        cmp cx, dx
        setl cl
        ; copy t.66(16@function,bool), r0(bool t.66)
        lea rax, [rsp+20]
        mov [rax], cl
@and_next_14:
        ; copy r0(bool t.66), t.66(16@function,bool)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r0(i64 t.65), r0(bool t.66)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.65)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r0(i16 t.68), -1
        mov cx, -1
        ; cast r0(i64 t.67), r0(i16 t.68)
        movzx rcx, cx
        ; call _, printIntLf [r0(i64 t.67)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r0(i16 b), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; neg r0(i16 t.70), r0(i16 b)
        neg rcx
        ; cast r0(i64 t.69), r0(i16 t.70)
        movzx rcx, cx
        ; call _, printIntLf [r0(i64 t.69)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r0(u8 b1), b1(6@function,u8)
        lea rax, [rsp+10]
        mov cl, [rax]
        ; not r0(u8 t.72), r0(u8 b1)
        not rcx
        ; cast r0(i64 t.71), r0(u8 t.72)
        movzx rcx, cl
        ; call _, printIntLf [r0(i64 t.71)]
        push rcx
          call @printIntLf
        add rsp, 8
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
