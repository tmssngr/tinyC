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
        ; call r.0(0@register,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r.0(0@register,i64)]
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
        ; addrof r.0(0@register,u8*), chr(0@argument,u8)
        lea rcx, [rsp+8]
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; call _, printStringLength [r.0(0@register,u8*), r.1(1@register,i64)]
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
        ; const r.0(0@register,u8), 20
        mov cl, 20
        ; 13:2 while true
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), pos(2@function,u8)
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r.1(1@register,i64), 10
        mov rdx, 10
        ; copy r.2(2@register,i64), number(0@argument,i64)
        lea rax, [rsp+40]
        mov r9, [rax]
        ; mod r.1(1@register,i64), r.2(2@register,i64), r.1(1@register,i64)
        mov rax, r9
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r.3(3@register,i64), 10
        mov r10, 10
        ; div r.2(2@register,i64), r.2(2@register,i64), r.3(3@register,i64)
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r.1(1@register,u8), r.1(1@register,i64)
        ; const r.3(3@register,u8), 48
        mov r10b, 48
        ; add r.1(1@register,u8), r.1(1@register,u8), r.3(3@register,u8)
        add dl, r10b
        ; cast r.3(3@register,i64), r.0(0@register,u8)
        movzx r10, cl
        ; array r.3(3@register,u8*), buffer(1@function,u8*) + r.3(3@register,i64)
        lea rax, [rsp+0]
        add r10, rax
        ; store [r.3(3@register,u8*)], r.1(1@register,u8)
        mov [r10], dl
        ; 19:3 if number == 0
        ; const r.1(1@register,i64), 0
        mov rdx, 0
        ; equals r.1(1@register,bool), r.2(2@register,i64), r.1(1@register,i64)
        cmp r9, rdx
        sete dl
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rax, [rsp+20]
        mov [rax], cl
        ; copy number(0@argument,i64), r.2(2@register,i64)
        lea rax, [rsp+40]
        mov [rax], r9
        ; branch r.1(1@register,bool), false, @while_1
        or dl, dl
        jz @while_1
        ; copy r.0(0@register,u8), pos(2@function,u8)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r.1(1@register,i64), r.0(0@register,u8)
        movzx rdx, cl
        ; addrof r.1(1@register,u8*), [buffer(1@function,u8*) + r.1(1@register,i64)]
        lea rax, [rsp+0]
        add rdx, rax
        ; const r.2(2@register,u8), 20
        mov r9b, 20
        ; sub r.0(0@register,u8), r.2(2@register,u8), r.0(0@register,u8)
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printStringLength [r.1(1@register,u8*), r.0(0@register,i64)]
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
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; copy r.1(1@register,i64), number(0@argument,i64)
        lea rax, [rsp+8]
        mov rdx, [rax]
        ; lt r.0(0@register,bool), r.1(1@register,i64), r.0(0@register,i64)
        cmp rdx, rcx
        setl cl
        ; branch r.0(0@register,bool), false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; const r.0(0@register,u8), 45
        mov cl, 45
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; copy r.0(0@register,i64), number(0@argument,i64)
        lea rax, [rsp+8]
        mov rcx, [rax]
        ; neg r.0(0@register,i64), r.0(0@register,i64)
        neg rcx
        ; copy number(0@argument,i64), r.0(0@register,i64)
        lea rax, [rsp+8]
        mov [rax], rcx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+8]
        mov rax, [rax]
        push rax
          call @printUint
        add rsp, 8
        ; const r.0(0@register,u8), 10
        mov cl, 10
        ; call _, printChar [r.0(0@register,u8)]
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
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rax, [rsp+0]
        mov [rax], rcx
@for_4:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        mov dl, [rcx]
        ; const r.2(2@register,u8), 0
        mov r9b, 0
        ; notequals r.1(1@register,bool), r.1(1@register,u8), r.2(2@register,u8)
        cmp dl, r9b
        setne dl
        ; branch r.1(1@register,bool), false, @for_4_break
        or dl, dl
        jz @for_4_break
        ; const r.0(0@register,i64), 1
        mov rcx, 1
        ; copy r.1(1@register,i64), length(1@function,i64)
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r.0(0@register,i64), r.1(1@register,i64), r.0(0@register,i64)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rax, [rsp+0]
        mov [rax], rcx
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rax, [rsp+24]
        mov rcx, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,u8*)
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; add r.0(0@register,i64), r.0(0@register,i64), r.1(1@register,i64)
        add rcx, rdx
        ; cast r.0(0@register,u8*), r.0(0@register,i64)
        ; copy str(0@argument,u8*), r.0(0@register,u8*)
        lea rax, [rsp+24]
        mov [rax], rcx
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; copy r.0(0@register,i64), length(1@function,i64)
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r.0(0@register,i64)
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
        ; const r.0(0@register,u8*), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; const r.0(0@register,i16), 0
        mov cx, 0
        ; const r.1(1@register,i16), 1
        mov dx, 1
        ; const r.2(2@register,i16), 2
        mov r9w, 2
        ; const r.3(3@register,i16), 3
        mov r10w, 3
        ; Spill a
        ; copy a(0@function,i16), r.0(0@register,i16)
        lea rax, [rsp+0]
        mov [rax], cx
        ; const r.0(0@register,bool), 1
        mov cl, 1
        ; Spill t
        ; copy t(4@function,bool), r.0(0@register,bool)
        lea rax, [rsp+8]
        mov [rax], cl
        ; const r.0(0@register,bool), 0
        mov cl, 0
        ; Spill f
        ; copy f(5@function,bool), r.0(0@register,bool)
        lea rax, [rsp+9]
        mov [rax], cl
        ; Spill b
        ; copy b(1@function,i16), r.1(1@register,i16)
        lea rax, [rsp+2]
        mov [rax], dx
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; and r.1(1@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        mov dx, cx
        and dx, cx
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        movzx rdx, dx
        ; copy c(2@function,i16), r.2(2@register,i16)
        lea rax, [rsp+4]
        mov [rax], r9w
        ; copy d(3@function,i16), r.3(3@register,i16)
        lea rax, [rsp+6]
        mov [rax], r10w
        ; call _, printIntLf [r.1(1@register,i64)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; and r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        and r9w, dx
        ; cast r.2(2@register,i64), r.2(2@register,i16)
        movzx r9, r9w
        ; call _, printIntLf [r.2(2@register,i64)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; and r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        and r9w, dx
        ; cast r.2(2@register,i64), r.2(2@register,i16)
        movzx r9, r9w
        ; call _, printIntLf [r.2(2@register,i64)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; and r.1(1@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        mov dx, cx
        and dx, cx
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        movzx rdx, dx
        ; call _, printIntLf [r.1(1@register,i64)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-1]
        lea rcx, [string_1]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; or r.1(1@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        mov dx, cx
        or dx, cx
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        movzx rdx, dx
        ; call _, printIntLf [r.1(1@register,i64)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov dx, [rax]
        ; or r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        or r9w, dx
        ; cast r.2(2@register,i64), r.2(2@register,i16)
        movzx r9, r9w
        ; call _, printIntLf [r.2(2@register,i64)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; or r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        or r9w, dx
        ; cast r.2(2@register,i64), r.2(2@register,i16)
        movzx r9, r9w
        ; call _, printIntLf [r.2(2@register,i64)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; or r.1(1@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        mov dx, cx
        or dx, cx
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        movzx rdx, dx
        ; call _, printIntLf [r.1(1@register,i64)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-2]
        lea rcx, [string_2]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; xor r.1(1@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        mov dx, cx
        xor dx, cx
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        movzx rdx, dx
        ; call _, printIntLf [r.1(1@register,i64)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov cx, [rax]
        ; copy r.1(1@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; xor r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        xor r9w, dx
        ; cast r.2(2@register,i64), r.2(2@register,i16)
        movzx r9, r9w
        ; call _, printIntLf [r.2(2@register,i64)]
        push r9
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rax, [rsp+0]
        mov dx, [rax]
        ; xor r.1(1@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov ax, cx
        xor ax, dx
        mov dx, ax
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        movzx rdx, dx
        ; call _, printIntLf [r.1(1@register,i64)]
        push rdx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r.1(1@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; xor r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        mov r9w, cx
        xor r9w, dx
        ; cast r.2(2@register,i64), r.2(2@register,i16)
        movzx r9, r9w
        ; call _, printIntLf [r.2(2@register,i64)]
        push r9
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-3]
        lea rcx, [string_3]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; 26:15 logic and
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.38(7@function,bool), r.1(1@register,bool)
        lea rax, [rsp+11]
        mov [rax], dl
        ; branch r.1(1@register,bool), false, @and_next_5
        or dl, dl
        jz @and_next_5
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.38(7@function,bool), r.1(1@register,bool)
        lea rax, [rsp+11]
        mov [rax], dl
@and_next_5:
        ; copy r.0(0@register,bool), t.38(7@function,bool)
        lea rax, [rsp+11]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 27:15 logic and
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.40(8@function,bool), r.1(1@register,bool)
        lea rax, [rsp+12]
        mov [rax], dl
        ; branch r.1(1@register,bool), false, @and_next_6
        or dl, dl
        jz @and_next_6
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.40(8@function,bool), r.1(1@register,bool)
        lea rax, [rsp+12]
        mov [rax], dl
@and_next_6:
        ; copy r.0(0@register,bool), t.40(8@function,bool)
        lea rax, [rsp+12]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 28:15 logic and
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.42(9@function,bool), r.1(1@register,bool)
        lea rax, [rsp+13]
        mov [rax], dl
        ; branch r.1(1@register,bool), false, @and_next_7
        or dl, dl
        jz @and_next_7
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.42(9@function,bool), r.1(1@register,bool)
        lea rax, [rsp+13]
        mov [rax], dl
@and_next_7:
        ; copy r.0(0@register,bool), t.42(9@function,bool)
        lea rax, [rsp+13]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 29:15 logic and
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.44(10@function,bool), r.1(1@register,bool)
        lea rax, [rsp+14]
        mov [rax], dl
        ; branch r.1(1@register,bool), false, @and_next_8
        or dl, dl
        jz @and_next_8
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.44(10@function,bool), r.1(1@register,bool)
        lea rax, [rsp+14]
        mov [rax], dl
@and_next_8:
        ; copy r.0(0@register,bool), t.44(10@function,bool)
        lea rax, [rsp+14]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-4]
        lea rcx, [string_4]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; 31:15 logic or
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.47(11@function,bool), r.1(1@register,bool)
        lea rax, [rsp+15]
        mov [rax], dl
        ; branch r.1(1@register,bool), true, @or_next_9
        or dl, dl
        jnz @or_next_9
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.47(11@function,bool), r.1(1@register,bool)
        lea rax, [rsp+15]
        mov [rax], dl
@or_next_9:
        ; copy r.0(0@register,bool), t.47(11@function,bool)
        lea rax, [rsp+15]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 32:15 logic or
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.49(12@function,bool), r.1(1@register,bool)
        lea rax, [rsp+16]
        mov [rax], dl
        ; branch r.1(1@register,bool), true, @or_next_10
        or dl, dl
        jnz @or_next_10
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.49(12@function,bool), r.1(1@register,bool)
        lea rax, [rsp+16]
        mov [rax], dl
@or_next_10:
        ; copy r.0(0@register,bool), t.49(12@function,bool)
        lea rax, [rsp+16]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 33:15 logic or
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.51(13@function,bool), r.1(1@register,bool)
        lea rax, [rsp+17]
        mov [rax], dl
        ; branch r.1(1@register,bool), true, @or_next_11
        or dl, dl
        jnz @or_next_11
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.51(13@function,bool), r.1(1@register,bool)
        lea rax, [rsp+17]
        mov [rax], dl
@or_next_11:
        ; copy r.0(0@register,bool), t.51(13@function,bool)
        lea rax, [rsp+17]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 34:15 logic or
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.53(14@function,bool), r.1(1@register,bool)
        lea rax, [rsp+18]
        mov [rax], dl
        ; branch r.1(1@register,bool), true, @or_next_12
        or dl, dl
        jnz @or_next_12
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; copy r.1(1@register,bool), r.0(0@register,bool)
        mov dl, cl
        ; copy t.53(14@function,bool), r.1(1@register,bool)
        lea rax, [rsp+18]
        mov [rax], dl
@or_next_12:
        ; copy r.0(0@register,bool), t.53(14@function,bool)
        lea rax, [rsp+18]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-5]
        lea rcx, [string_5]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,bool), f(5@function,bool)
        lea rax, [rsp+9]
        mov cl, [rax]
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        or cl, cl
        sete cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,bool), t(4@function,bool)
        lea rax, [rsp+8]
        mov cl, [rax]
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        or cl, cl
        sete cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-6]
        lea rcx, [string_6]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; const r.0(0@register,u8), 10
        mov cl, 10
        ; const r.1(1@register,u8), 6
        mov dl, 6
        ; const r.2(2@register,u8), 1
        mov r9b, 1
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        and cl, dl
        ; or r.0(0@register,u8), r.0(0@register,u8), r.2(2@register,u8)
        or cl, r9b
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; copy b1(6@function,u8), r.2(2@register,u8)
        lea rax, [rsp+10]
        mov [rax], r9b
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 43:20 logic or
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r.1(1@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete r9b
        ; copy t.64(15@function,bool), r.2(2@register,bool)
        lea rax, [rsp+19]
        mov [rax], r9b
        ; branch r.2(2@register,bool), true, @or_next_13
        or r9b, r9b
        jnz @or_next_13
        ; copy r.0(0@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov cx, [rax]
        ; copy r.1(1@register,i16), d(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lt r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setl r9b
        ; copy t.64(15@function,bool), r.2(2@register,bool)
        lea rax, [rsp+19]
        mov [rax], r9b
@or_next_13:
        ; copy r.0(0@register,bool), t.64(15@function,bool)
        lea rax, [rsp+19]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; 44:20 logic and
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; copy r.1(1@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete r9b
        ; copy t.66(16@function,bool), r.2(2@register,bool)
        lea rax, [rsp+20]
        mov [rax], r9b
        ; branch r.2(2@register,bool), false, @and_next_14
        or r9b, r9b
        jz @and_next_14
        ; copy r.0(0@register,i16), c(2@function,i16)
        lea rax, [rsp+4]
        mov cx, [rax]
        ; copy r.1(1@register,i16), d(3@function,i16)
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setl cl
        ; copy t.66(16@function,bool), r.0(0@register,bool)
        lea rax, [rsp+20]
        mov [rax], cl
@and_next_14:
        ; copy r.0(0@register,bool), t.66(16@function,bool)
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,i16), -1
        mov cx, -1
        ; cast r.0(0@register,i64), r.0(0@register,i16)
        movzx rcx, cx
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rax, [rsp+2]
        mov cx, [rax]
        ; neg r.0(0@register,i16), r.0(0@register,i16)
        neg rcx
        ; cast r.0(0@register,i64), r.0(0@register,i16)
        movzx rcx, cx
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), b1(6@function,u8)
        lea rax, [rsp+10]
        mov cl, [rax]
        ; not r.0(0@register,u8), r.0(0@register,u8)
        not rcx
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
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
