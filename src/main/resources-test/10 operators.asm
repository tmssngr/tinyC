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
        ; call length, strlen, [str]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @strlen
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call _, printStringLength [str, length]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
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
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2, 1
        mov rax, 1
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call _, printStringLength [t.1, t.2]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
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
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 13:2 while true
@while_1:
        ; const t.5, 1
        mov al, 1
        lea rbx, [rsp+33]
        mov [rbx], al
        ; sub pos, pos, t.5
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.6, 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; mod remainder, number, t.6
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.7, 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number, number, t.7
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+152]
        mov [rdx], rbx
        ; cast t.8, remainder
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; add digit, t.8, t.9
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.11, pos
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.12, t.11
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.10, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.10, t.10, t.12
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.10], digit
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 19:3 if number == 0
        ; const t.14, 0
        mov rax, 0
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; equals t.13, number, t.14
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.13, false, @while_1
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.16, pos
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; cast t.17, t.16
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.15, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.15, t.15, t.17
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.20, 20
        mov al, 20
        lea rbx, [rsp+137]
        mov [rbx], al
        ; sub t.19, t.20, pos
        lea rax, [rsp+137]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+136]
        mov [rax], bl
        ; cast t.18, t.19
        lea rax, [rsp+136]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printStringLength [t.15, t.18]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+136]
        mov rbx, [rax]
        push rbx
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
        ; const t.2, 0
        mov rax, 0
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; lt t.1, number, t.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        cmp rbx, rcx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.3, 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call _, printChar [t.3]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
@if_3_end:
        ; call _, printUint [number]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint
        add rsp, 8
        ; const t.4, 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call _, printChar [t.4]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
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
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 37:2 for *str != 0
@for_4:
        ; load t.3, [str]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+10]
        mov [rbx], al
        ; notequals t.2, t.3, t.4
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2, false, @for_4_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jz @for_4_break
        ; const t.5, 1
        mov rax, 1
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; add length, length, t.5
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; cast t.7, str
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8, 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6, t.7, t.8
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast str, t.6
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
        jmp @for_4
@for_4_break:
        ; 40:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+6: var d
        ;   rsp+8: var t
        ;   rsp+9: var f
        ;   rsp+10: var b10
        ;   rsp+11: var b6
        ;   rsp+12: var b1
        ;   rsp+16: var t.9
        ;   rsp+24: var t.10
        ;   rsp+32: var t.11
        ;   rsp+40: var t.12
        ;   rsp+48: var t.13
        ;   rsp+56: var t.14
        ;   rsp+64: var t.15
        ;   rsp+72: var t.16
        ;   rsp+80: var t.17
        ;   rsp+88: var t.18
        ;   rsp+96: var t.19
        ;   rsp+104: var t.20
        ;   rsp+112: var t.21
        ;   rsp+120: var t.22
        ;   rsp+128: var t.23
        ;   rsp+136: var t.24
        ;   rsp+144: var t.25
        ;   rsp+152: var t.26
        ;   rsp+160: var t.27
        ;   rsp+168: var t.28
        ;   rsp+176: var t.29
        ;   rsp+184: var t.30
        ;   rsp+192: var t.31
        ;   rsp+200: var t.32
        ;   rsp+208: var t.33
        ;   rsp+216: var t.34
        ;   rsp+224: var t.35
        ;   rsp+232: var t.36
        ;   rsp+240: var t.37
        ;   rsp+248: var t.38
        ;   rsp+256: var t.39
        ;   rsp+264: var t.40
        ;   rsp+272: var t.41
        ;   rsp+280: var t.42
        ;   rsp+288: var t.43
        ;   rsp+296: var t.44
        ;   rsp+304: var t.45
        ;   rsp+312: var t.46
        ;   rsp+320: var t.47
        ;   rsp+328: var t.48
        ;   rsp+336: var t.49
        ;   rsp+344: var t.50
        ;   rsp+352: var t.51
        ;   rsp+360: var t.52
        ;   rsp+368: var t.53
        ;   rsp+376: var t.54
        ;   rsp+384: var t.55
        ;   rsp+392: var t.56
        ;   rsp+400: var t.57
        ;   rsp+408: var t.58
        ;   rsp+416: var t.59
        ;   rsp+424: var t.60
        ;   rsp+432: var t.61
        ;   rsp+433: var t.62
        ;   rsp+440: var t.63
        ;   rsp+448: var t.64
        ;   rsp+456: var t.65
        ;   rsp+464: var t.66
        ;   rsp+472: var t.67
        ;   rsp+480: var t.68
        ;   rsp+488: var t.69
        ;   rsp+496: var t.70
        ;   rsp+504: var t.71
        ;   rsp+512: var t.72
@main:
        ; reserve space for local variables
        sub rsp, 528
        ; const t.9, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call _, printString [t.9]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const a, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const b, 1
        mov ax, 1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; const c, 2
        mov ax, 2
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; const d, 3
        mov ax, 3
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; const t, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; const f, 0
        mov al, 0
        lea rbx, [rsp+9]
        mov [rbx], al
        ; and t.11, a, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+32]
        mov [rax], bx
        ; cast t.10, t.11
        lea rax, [rsp+32]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; call _, printIntLf [t.10]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; and t.13, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+48]
        mov [rax], bx
        ; cast t.12, t.13
        lea rax, [rsp+48]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; call _, printIntLf [t.12]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; and t.15, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+64]
        mov [rax], bx
        ; cast t.14, t.15
        lea rax, [rsp+64]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+56]
        mov [rax], rbx
        ; call _, printIntLf [t.14]
        lea rax, [rsp+56]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; and t.17, b, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+80]
        mov [rax], bx
        ; cast t.16, t.17
        lea rax, [rsp+80]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+72]
        mov [rax], rbx
        ; call _, printIntLf [t.16]
        lea rax, [rsp+72]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.18, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; call _, printString [t.18]
        lea rax, [rsp+88]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; or t.20, a, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+104]
        mov [rax], bx
        ; cast t.19, t.20
        lea rax, [rsp+104]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+96]
        mov [rax], rbx
        ; call _, printIntLf [t.19]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; or t.22, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+120]
        mov [rax], bx
        ; cast t.21, t.22
        lea rax, [rsp+120]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+112]
        mov [rax], rbx
        ; call _, printIntLf [t.21]
        lea rax, [rsp+112]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; or t.24, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+136]
        mov [rax], bx
        ; cast t.23, t.24
        lea rax, [rsp+136]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+128]
        mov [rax], rbx
        ; call _, printIntLf [t.23]
        lea rax, [rsp+128]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; or t.26, b, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+152]
        mov [rax], bx
        ; cast t.25, t.26
        lea rax, [rsp+152]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+144]
        mov [rax], rbx
        ; call _, printIntLf [t.25]
        lea rax, [rsp+144]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.27, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+160]
        mov [rbx], rax
        ; call _, printString [t.27]
        lea rax, [rsp+160]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; xor t.29, a, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+176]
        mov [rax], bx
        ; cast t.28, t.29
        lea rax, [rsp+176]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+168]
        mov [rax], rbx
        ; call _, printIntLf [t.28]
        lea rax, [rsp+168]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; xor t.31, a, c
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+192]
        mov [rax], bx
        ; cast t.30, t.31
        lea rax, [rsp+192]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+184]
        mov [rax], rbx
        ; call _, printIntLf [t.30]
        lea rax, [rsp+184]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; xor t.33, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+208]
        mov [rax], bx
        ; cast t.32, t.33
        lea rax, [rsp+208]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+200]
        mov [rax], rbx
        ; call _, printIntLf [t.32]
        lea rax, [rsp+200]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; xor t.35, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+224]
        mov [rax], bx
        ; cast t.34, t.35
        lea rax, [rsp+224]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+216]
        mov [rax], rbx
        ; call _, printIntLf [t.34]
        lea rax, [rsp+216]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.36, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+232]
        mov [rbx], rax
        ; call _, printString [t.36]
        lea rax, [rsp+232]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; 26:15 logic and
        ; move t.38, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+248]
        mov [rax], bl
        ; branch t.38, false, @and_next_5
        lea rax, [rsp+248]
        mov bl, [rax]
        or bl, bl
        jz @and_next_5
        ; move t.38, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+248]
        mov [rax], bl
@and_next_5:
        ; cast t.37, t.38
        lea rax, [rsp+248]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+240]
        mov [rax], rbx
        ; call _, printIntLf [t.37]
        lea rax, [rsp+240]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 27:15 logic and
        ; move t.40, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+264]
        mov [rax], bl
        ; branch t.40, false, @and_next_6
        lea rax, [rsp+264]
        mov bl, [rax]
        or bl, bl
        jz @and_next_6
        ; move t.40, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+264]
        mov [rax], bl
@and_next_6:
        ; cast t.39, t.40
        lea rax, [rsp+264]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+256]
        mov [rax], rbx
        ; call _, printIntLf [t.39]
        lea rax, [rsp+256]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 28:15 logic and
        ; move t.42, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+280]
        mov [rax], bl
        ; branch t.42, false, @and_next_7
        lea rax, [rsp+280]
        mov bl, [rax]
        or bl, bl
        jz @and_next_7
        ; move t.42, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+280]
        mov [rax], bl
@and_next_7:
        ; cast t.41, t.42
        lea rax, [rsp+280]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+272]
        mov [rax], rbx
        ; call _, printIntLf [t.41]
        lea rax, [rsp+272]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 29:15 logic and
        ; move t.44, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+296]
        mov [rax], bl
        ; branch t.44, false, @and_next_8
        lea rax, [rsp+296]
        mov bl, [rax]
        or bl, bl
        jz @and_next_8
        ; move t.44, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+296]
        mov [rax], bl
@and_next_8:
        ; cast t.43, t.44
        lea rax, [rsp+296]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+288]
        mov [rax], rbx
        ; call _, printIntLf [t.43]
        lea rax, [rsp+288]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.45, [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+304]
        mov [rbx], rax
        ; call _, printString [t.45]
        lea rax, [rsp+304]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; 31:15 logic or
        ; move t.47, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+320]
        mov [rax], bl
        ; branch t.47, true, @or_next_9
        lea rax, [rsp+320]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_9
        ; move t.47, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+320]
        mov [rax], bl
@or_next_9:
        ; cast t.46, t.47
        lea rax, [rsp+320]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+312]
        mov [rax], rbx
        ; call _, printIntLf [t.46]
        lea rax, [rsp+312]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 32:15 logic or
        ; move t.49, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+336]
        mov [rax], bl
        ; branch t.49, true, @or_next_10
        lea rax, [rsp+336]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_10
        ; move t.49, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+336]
        mov [rax], bl
@or_next_10:
        ; cast t.48, t.49
        lea rax, [rsp+336]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+328]
        mov [rax], rbx
        ; call _, printIntLf [t.48]
        lea rax, [rsp+328]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 33:15 logic or
        ; move t.51, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+352]
        mov [rax], bl
        ; branch t.51, true, @or_next_11
        lea rax, [rsp+352]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_11
        ; move t.51, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+352]
        mov [rax], bl
@or_next_11:
        ; cast t.50, t.51
        lea rax, [rsp+352]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+344]
        mov [rax], rbx
        ; call _, printIntLf [t.50]
        lea rax, [rsp+344]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 34:15 logic or
        ; move t.53, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+368]
        mov [rax], bl
        ; branch t.53, true, @or_next_12
        lea rax, [rsp+368]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_12
        ; move t.53, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+368]
        mov [rax], bl
@or_next_12:
        ; cast t.52, t.53
        lea rax, [rsp+368]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+360]
        mov [rax], rbx
        ; call _, printIntLf [t.52]
        lea rax, [rsp+360]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.54, [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+376]
        mov [rbx], rax
        ; call _, printString [t.54]
        lea rax, [rsp+376]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; notlog t.56, f
        lea rax, [rsp+9]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+392]
        mov [rax], bl
        ; cast t.55, t.56
        lea rax, [rsp+392]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+384]
        mov [rax], rbx
        ; call _, printIntLf [t.55]
        lea rax, [rsp+384]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; notlog t.58, t
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+408]
        mov [rax], bl
        ; cast t.57, t.58
        lea rax, [rsp+408]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+400]
        mov [rax], rbx
        ; call _, printIntLf [t.57]
        lea rax, [rsp+400]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.59, [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+416]
        mov [rbx], rax
        ; call _, printString [t.59]
        lea rax, [rsp+416]
        mov rbx, [rax]
        push rbx
          call @printString
        add rsp, 8
        ; const b10, 10
        mov al, 10
        lea rbx, [rsp+10]
        mov [rbx], al
        ; const b6, 6
        mov al, 6
        lea rbx, [rsp+11]
        mov [rbx], al
        ; const b1, 1
        mov al, 1
        lea rbx, [rsp+12]
        mov [rbx], al
        ; and t.62, b10, b6
        lea rax, [rsp+10]
        mov bl, [rax]
        lea rax, [rsp+11]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+433]
        mov [rax], bl
        ; or t.61, t.62, b1
        lea rax, [rsp+433]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+432]
        mov [rax], bl
        ; cast t.60, t.61
        lea rax, [rsp+432]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+424]
        mov [rax], rbx
        ; call _, printIntLf [t.60]
        lea rax, [rsp+424]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 43:20 logic or
        ; equals t.64, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+448]
        mov [rax], bl
        ; branch t.64, true, @or_next_13
        lea rax, [rsp+448]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_13
        ; lt t.64, c, d
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+448]
        mov [rax], bl
@or_next_13:
        ; cast t.63, t.64
        lea rax, [rsp+448]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+440]
        mov [rax], rbx
        ; call _, printIntLf [t.63]
        lea rax, [rsp+440]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; 44:20 logic and
        ; equals t.66, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+464]
        mov [rax], bl
        ; branch t.66, false, @and_next_14
        lea rax, [rsp+464]
        mov bl, [rax]
        or bl, bl
        jz @and_next_14
        ; lt t.66, c, d
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+464]
        mov [rax], bl
@and_next_14:
        ; cast t.65, t.66
        lea rax, [rsp+464]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+456]
        mov [rax], rbx
        ; call _, printIntLf [t.65]
        lea rax, [rsp+456]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; const t.68, -1
        mov ax, -1
        lea rbx, [rsp+480]
        mov [rbx], ax
        ; cast t.67, t.68
        lea rax, [rsp+480]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+472]
        mov [rax], rbx
        ; call _, printIntLf [t.67]
        lea rax, [rsp+472]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; neg t.70, b
        lea rax, [rsp+2]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+496]
        mov [rax], bx
        ; cast t.69, t.70
        lea rax, [rsp+496]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+488]
        mov [rax], rbx
        ; call _, printIntLf [t.69]
        lea rax, [rsp+488]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; not t.72, b1
        lea rax, [rsp+12]
        mov bl, [rax]
        not rbx
        lea rax, [rsp+512]
        mov [rax], bl
        ; cast t.71, t.72
        lea rax, [rsp+512]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+504]
        mov [rax], rbx
        ; call _, printIntLf [t.71]
        lea rax, [rsp+504]
        mov rbx, [rax]
        push rbx
          call @printIntLf
        add rsp, 8
        ; release space for local variables
        add rsp, 528
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
