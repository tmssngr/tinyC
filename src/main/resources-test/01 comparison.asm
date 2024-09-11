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
        ; call r.0(0@register,i64), strlen, [str(0@argument,u8*)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str(0@argument,u8*), r.0(0@register,i64)]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printString_ret:
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
        ; addrof r.0(0@register,u8*), chr(0@argument,u8)
        lea rax, [rsp+24]
        mov rcx, rax
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; call _, printStringLength [r.0(0@register,u8*), r.1(1@register,i64)]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
@printChar_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
        ;   rsp+136: arg number
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
        ;   rsp+121: var t.18
@printUint:
        ; reserve space for local variables
        sub rsp, 128
        ; const r.0(0@register,u8), 20
        mov cl, 20
        ; 13:2 while true
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+20]
        mov [rbx], cl
@while_1:
        ; const r.0(0@register,u8), 1
        mov cl, 1
        ; copy r.1(1@register,u8), pos(2@function,u8)
        lea rbx, [rsp+20]
        mov dl, [rbx]
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r.1(1@register,i64), 10
        mov rdx, 10
        ; copy r.2(2@register,i64), number(0@argument,i64)
        lea rbx, [rsp+136]
        mov r9, [rbx]
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
        ; copy pos(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+20]
        mov [rbx], cl
        ; cast r.0(0@register,i64), r.0(0@register,u8)
        movzx rcx, cl
        ; array r.0(0@register,u8*), buffer(1@function,u8*) + r.0(0@register,i64)
        lea rax, [rsp+0]
        add rcx, rax
        ; store [r.0(0@register,u8*)], r.1(1@register,u8)
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; copy number(0@argument,i64), r.2(2@register,i64)
        lea rbx, [rsp+136]
        mov [rbx], r9
        ; equals r.0(0@register,bool), r.2(2@register,i64), r.0(0@register,i64)
        cmp r9, rcx
        sete cl
        ; branch r.0(0@register,bool), false, @if_2_end
        or cl, cl
        jz @if_2_end
        ; @if_2_then
@if_2_then:
        ; jump @while_1_break
        jmp @while_1_break
@if_2_end:
        ; jump @while_1
        jmp @while_1
@while_1_break:
        ; copy r.0(0@register,u8), pos(2@function,u8)
        lea rbx, [rsp+20]
        mov cl, [rbx]
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
@printUint_ret:
        ; release space for local variables
        add rsp, 128
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
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; copy r.1(1@register,i64), number(0@argument,i64)
        lea rbx, [rsp+40]
        mov rdx, [rbx]
        ; lt r.0(0@register,bool), r.1(1@register,i64), r.0(0@register,i64)
        cmp rdx, rcx
        setl cl
        ; branch r.0(0@register,bool), false, @if_3_end
        or cl, cl
        jz @if_3_end
        ; @if_3_then
@if_3_then:
        ; const r.0(0@register,u8), 45
        mov cl, 45
        ; call _, printChar [r.0(0@register,u8)]
        push rcx
          call @printChar
        add rsp, 8
        ; copy r.0(0@register,i64), number(0@argument,i64)
        lea rbx, [rsp+40]
        mov rcx, [rbx]
        ; neg r.0(0@register,i64), r.0(0@register,i64)
        neg rcx
        ; copy number(0@argument,i64), r.0(0@register,i64)
        lea rbx, [rsp+40]
        mov [rbx], rcx
@if_3_end:
        ; call _, printUint [number(0@argument,i64)]
        lea rax, [rsp+40]
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
@printIntLf_ret:
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
        ; const r.0(0@register,i64), 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rbx, [rsp+0]
        mov [rbx], rcx
@for_4:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rbx, [rsp+56]
        mov rcx, [rbx]
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        mov cl, [rcx]
        ; const r.1(1@register,u8), 0
        mov dl, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setne cl
        ; branch r.0(0@register,bool), false, @for_4_break
        or cl, cl
        jz @for_4_break
        ; @for_4_body
@for_4_body:
        ; const r.0(0@register,i64), 1
        mov rcx, 1
        ; copy r.1(1@register,i64), length(1@function,i64)
        lea rbx, [rsp+0]
        mov rdx, [rbx]
        ; add r.0(0@register,i64), r.1(1@register,i64), r.0(0@register,i64)
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; copy length(1@function,i64), r.0(0@register,i64)
        lea rbx, [rsp+0]
        mov [rbx], rcx
@for_4_continue:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        lea rbx, [rsp+56]
        mov rcx, [rbx]
        ; cast r.0(0@register,i64), r.0(0@register,u8*)
        ; const r.1(1@register,i64), 1
        mov rdx, 1
        ; add r.0(0@register,i64), r.0(0@register,i64), r.1(1@register,i64)
        add rcx, rdx
        ; cast r.0(0@register,u8*), r.0(0@register,i64)
        ; copy str(0@argument,u8*), r.0(0@register,u8*)
        lea rbx, [rsp+56]
        mov [rbx], rcx
        ; jump @for_4
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; copy r.0(0@register,i64), length(1@function,i64)
        lea rbx, [rsp+0]
        mov rcx, [rbx]
        ; ret r.0(0@register,i64)
        mov rax, rcx
@strlen_ret:
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
        ; const r.0(0@register,u8*), [string-0]
        lea rcx, [string_0]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; const r.0(0@register,i16), 1
        mov cx, 1
        ; const r.1(1@register,i16), 2
        mov dx, 2
        ; copy a(0@function,i16), r.0(0@register,i16)
        lea rbx, [rsp+0]
        mov [rbx], cx
        ; copy b(1@function,i16), r.1(1@register,i16)
        lea rbx, [rsp+2]
        mov [rbx], dx
        ; lt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setl cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov dx, [rbx]
        ; lt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setl cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-1]
        lea rcx, [string_1]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; const r.0(0@register,u8), 0
        mov cl, 0
        ; const r.1(1@register,u8), 128
        mov dl, 128
        ; copy c(2@function,u8), r.0(0@register,u8)
        lea rbx, [rsp+4]
        mov [rbx], cl
        ; copy d(3@function,u8), r.1(1@register,u8)
        lea rbx, [rsp+5]
        mov [rbx], dl
        ; lt r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setb cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov dl, [rbx]
        ; lt r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setb cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-2]
        lea rcx, [string_2]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov dx, [rbx]
        ; lteq r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setle cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov dx, [rbx]
        ; lteq r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setle cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-3]
        lea rcx, [string_3]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov dl, [rbx]
        ; lteq r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setbe cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov dl, [rbx]
        ; lteq r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setbe cl
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
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov dx, [rbx]
        ; equals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov dx, [rbx]
        ; equals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        sete cl
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
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov dx, [rbx]
        ; notequals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setne cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov dx, [rbx]
        ; notequals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setne cl
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
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov dx, [rbx]
        ; gteq r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setge cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov dx, [rbx]
        ; gteq r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setge cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-7]
        lea rcx, [string_7]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov dl, [rbx]
        ; gteq r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setae cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov dl, [rbx]
        ; gteq r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        setae cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-8]
        lea rcx, [string_8]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov dx, [rbx]
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setg cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,i16), b(1@function,i16)
        lea rbx, [rsp+2]
        mov cx, [rbx]
        ; copy r.1(1@register,i16), a(0@function,i16)
        lea rbx, [rsp+0]
        mov dx, [rbx]
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        cmp cx, dx
        setg cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; const r.0(0@register,u8*), [string-9]
        lea rcx, [string_9]
        ; call _, printString [r.0(0@register,u8*)]
        push rcx
          call @printString
        add rsp, 8
        ; copy r.0(0@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov dl, [rbx]
        ; gt r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        seta cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
        ; copy r.0(0@register,u8), d(3@function,u8)
        lea rbx, [rsp+5]
        mov cl, [rbx]
        ; copy r.1(1@register,u8), c(2@function,u8)
        lea rbx, [rsp+4]
        mov dl, [rbx]
        ; gt r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        cmp cl, dl
        seta cl
        ; cast r.0(0@register,i64), r.0(0@register,bool)
        movzx rcx, cl
        ; call _, printIntLf [r.0(0@register,i64)]
        push rcx
          call @printIntLf
        add rsp, 8
@main_ret:
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
