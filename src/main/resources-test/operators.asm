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

        ; void printString@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length
@printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; const t.2, 1
        mov al, 1
        lea rbx, [rsp+8]
        mov [rbx], al
        ; call printStringLength@@u8@u8[t.1, t.2]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+136: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+40: var t.5
        ;   rsp+48: var t.6
        ;   rsp+56: var t.7
        ;   rsp+57: var t.8
        ;   rsp+64: var t.9
        ;   rsp+72: var t.10
        ;   rsp+80: var t.11
        ;   rsp+88: var t.12
        ;   rsp+96: var t.13
        ;   rsp+104: var t.14
        ;   rsp+112: var t.15
        ;   rsp+120: var t.16
        ;   rsp+121: var t.17
@printUint@i64:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 25:2 while true
@while_1:
        ; dec pos
        lea rax, [rsp+20]
        mov bl, [rax]
        dec bl
        lea rax, [rsp+20]
        mov [rax], bl
        ; const t.5, 10
        mov rax, 10
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; move remainder, number
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, t.5
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], rbx
        ; const t.6, 10
        mov rax, 10
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; div number, number, t.6
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        mov rax, rbx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+136]
        mov [rdx], rbx
        ; cast t.7(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.8, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; move digit, t.7
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, t.8
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.10(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.11(u8*), t.10(i64)
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; addrof t.9, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.9, t.9, t.11
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; store [t.9], digit
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 31:3 if number == 0
        ; equals t.12, number, 0
        lea rax, [rsp+136]
        mov rbx, [rax]
        cmp rbx, 0
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.12, false, @while_1, @while_1_break
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.14(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+104]
        mov [rax], rbx
        ; cast t.15(u8*), t.14(i64)
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov [rax], rbx
        ; addrof t.13, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; add t.13, t.13, t.15
        lea rax, [rsp+96]
        mov rbx, [rax]
        lea rax, [rsp+112]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+96]
        mov [rax], rbx
        ; const t.17, 20
        mov al, 20
        lea rbx, [rsp+121]
        mov [rbx], al
        ; move t.16, t.17
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+120]
        mov [rax], bl
        ; sub t.16, t.16, pos
        lea rax, [rsp+120]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.13, t.16]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+128]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 128
        ret

        ; void printIntLf@bool
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
@printIntLf@bool:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(bool)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@u8
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
@printIntLf@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(u8)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
@printIntLf@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
@printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; 51:2 if number < 0
        ; lt t.1, number, 0
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, false, @if_3_end, @if_3_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.2, 45
        mov al, 45
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call printChar@u8[t.2]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+24]
        mov [rax], rbx
@if_3_end:
        ; call printUint@i64[number]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printUint@i64
        add rsp, 8
        ; const t.3, 10
        mov al, 10
        lea rbx, [rsp+2]
        mov [rbx], al
        ; call printChar@u8[t.3]
        lea rax, [rsp+2]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+16: var t.4
        ;   rsp+24: var t.5
        ;   rsp+32: var t.6
@strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 61:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; inc length
        lea rax, [rsp+0]
        mov rbx, [rax]
        inc rbx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; cast t.5(i64), str(u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; const t.6, 1
        mov rax, 1
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; move t.4, t.5
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        ; add t.4, t.4, t.6
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast str(u8*), t.4(i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
@for_4:
        ; load t.3, [str]
        lea rax, [rsp+56]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+9]
        mov [rbx], al
        ; notequals t.2, t.3, 0
        lea rax, [rsp+9]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.2, true, @for_4_body, @for_4_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz @for_4_body
        ; 64:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2
@printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
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
        ;   rsp+26: var t.11
        ;   rsp+28: var t.12
        ;   rsp+30: var t.13
        ;   rsp+32: var t.14
        ;   rsp+40: var t.15
        ;   rsp+42: var t.16
        ;   rsp+44: var t.17
        ;   rsp+46: var t.18
        ;   rsp+48: var t.19
        ;   rsp+56: var t.20
        ;   rsp+58: var t.21
        ;   rsp+60: var t.22
        ;   rsp+62: var t.23
        ;   rsp+64: var t.24
        ;   rsp+72: var t.25
        ;   rsp+73: var t.26
        ;   rsp+74: var t.27
        ;   rsp+75: var t.28
        ;   rsp+80: var t.29
        ;   rsp+88: var t.30
        ;   rsp+89: var t.31
        ;   rsp+90: var t.32
        ;   rsp+91: var t.33
        ;   rsp+96: var t.34
        ;   rsp+104: var t.35
        ;   rsp+105: var t.36
        ;   rsp+112: var t.37
        ;   rsp+120: var t.38
        ;   rsp+121: var t.39
        ;   rsp+122: var t.40
        ;   rsp+123: var t.41
        ;   rsp+124: var t.42
        ;   rsp+126: var t.43
        ;   rsp+128: var t.44
@main:
        ; reserve space for local variables
        sub rsp, 144
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.9, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call printString@@u8[t.9]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
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
        ; move t.10, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; and t.10, t.10, a
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+24]
        mov [rax], bx
        ; call printIntLf@i16[t.10]
        lea rax, [rsp+24]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.11, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+26]
        mov [rax], bx
        ; and t.11, t.11, b
        lea rax, [rsp+26]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+26]
        mov [rax], bx
        ; call printIntLf@i16[t.11]
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.12, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov [rax], bx
        ; and t.12, t.12, a
        lea rax, [rsp+28]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+28]
        mov [rax], bx
        ; call printIntLf@i16[t.12]
        lea rax, [rsp+28]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.13, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+30]
        mov [rax], bx
        ; and t.13, t.13, b
        lea rax, [rsp+30]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        and bx, cx
        lea rax, [rsp+30]
        mov [rax], bx
        ; call printIntLf@i16[t.13]
        lea rax, [rsp+30]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; const t.14, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call printString@@u8[t.14]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; move t.15, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; or t.15, t.15, a
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+40]
        mov [rax], bx
        ; call printIntLf@i16[t.15]
        lea rax, [rsp+40]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.16, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+42]
        mov [rax], bx
        ; or t.16, t.16, b
        lea rax, [rsp+42]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+42]
        mov [rax], bx
        ; call printIntLf@i16[t.16]
        lea rax, [rsp+42]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.17, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+44]
        mov [rax], bx
        ; or t.17, t.17, a
        lea rax, [rsp+44]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+44]
        mov [rax], bx
        ; call printIntLf@i16[t.17]
        lea rax, [rsp+44]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.18, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov [rax], bx
        ; or t.18, t.18, b
        lea rax, [rsp+46]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        or bx, cx
        lea rax, [rsp+46]
        mov [rax], bx
        ; call printIntLf@i16[t.18]
        lea rax, [rsp+46]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; const t.19, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; call printString@@u8[t.19]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; move t.20, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov [rax], bx
        ; xor t.20, t.20, a
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+56]
        mov [rax], bx
        ; call printIntLf@i16[t.20]
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.21, a
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+58]
        mov [rax], bx
        ; xor t.21, t.21, c
        lea rax, [rsp+58]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+58]
        mov [rax], bx
        ; call printIntLf@i16[t.21]
        lea rax, [rsp+58]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.22, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+60]
        mov [rax], bx
        ; xor t.22, t.22, a
        lea rax, [rsp+60]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+60]
        mov [rax], bx
        ; call printIntLf@i16[t.22]
        lea rax, [rsp+60]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; move t.23, b
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+62]
        mov [rax], bx
        ; xor t.23, t.23, c
        lea rax, [rsp+62]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        xor bx, cx
        lea rax, [rsp+62]
        mov [rax], bx
        ; call printIntLf@i16[t.23]
        lea rax, [rsp+62]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; const t.24, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; call printString@@u8[t.24]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; 26:15 logic and
        ; move t.25, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov [rax], bl
        ; branch t.25, false, @and_next_5, @and_2nd_5
        lea rax, [rsp+72]
        mov bl, [rax]
        or bl, bl
        jz @and_next_5
        ; move t.25, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+72]
        mov [rax], bl
@and_next_5:
        ; call printIntLf@bool[t.25]
        lea rax, [rsp+72]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 27:15 logic and
        ; move t.26, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+73]
        mov [rax], bl
        ; branch t.26, false, @and_next_6, @and_2nd_6
        lea rax, [rsp+73]
        mov bl, [rax]
        or bl, bl
        jz @and_next_6
        ; move t.26, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+73]
        mov [rax], bl
@and_next_6:
        ; call printIntLf@bool[t.26]
        lea rax, [rsp+73]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 28:15 logic and
        ; move t.27, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+74]
        mov [rax], bl
        ; branch t.27, false, @and_next_7, @and_2nd_7
        lea rax, [rsp+74]
        mov bl, [rax]
        or bl, bl
        jz @and_next_7
        ; move t.27, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+74]
        mov [rax], bl
@and_next_7:
        ; call printIntLf@bool[t.27]
        lea rax, [rsp+74]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 29:15 logic and
        ; move t.28, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+75]
        mov [rax], bl
        ; branch t.28, false, @and_next_8, @and_2nd_8
        lea rax, [rsp+75]
        mov bl, [rax]
        or bl, bl
        jz @and_next_8
        ; move t.28, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+75]
        mov [rax], bl
@and_next_8:
        ; call printIntLf@bool[t.28]
        lea rax, [rsp+75]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.29, [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; call printString@@u8[t.29]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; 31:15 logic or
        ; move t.30, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.30, true, @or_next_9, @or_2nd_9
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_9
        ; move t.30, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+88]
        mov [rax], bl
@or_next_9:
        ; call printIntLf@bool[t.30]
        lea rax, [rsp+88]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 32:15 logic or
        ; move t.31, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+89]
        mov [rax], bl
        ; branch t.31, true, @or_next_10, @or_2nd_10
        lea rax, [rsp+89]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_10
        ; move t.31, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+89]
        mov [rax], bl
@or_next_10:
        ; call printIntLf@bool[t.31]
        lea rax, [rsp+89]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 33:15 logic or
        ; move t.32, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+90]
        mov [rax], bl
        ; branch t.32, true, @or_next_11, @or_2nd_11
        lea rax, [rsp+90]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_11
        ; move t.32, f
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+90]
        mov [rax], bl
@or_next_11:
        ; call printIntLf@bool[t.32]
        lea rax, [rsp+90]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 34:15 logic or
        ; move t.33, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+91]
        mov [rax], bl
        ; branch t.33, true, @or_next_12, @or_2nd_12
        lea rax, [rsp+91]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_12
        ; move t.33, t
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+91]
        mov [rax], bl
@or_next_12:
        ; call printIntLf@bool[t.33]
        lea rax, [rsp+91]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.34, [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; call printString@@u8[t.34]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; notlog t.35, f
        lea rax, [rsp+9]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+104]
        mov [rax], bl
        ; call printIntLf@bool[t.35]
        lea rax, [rsp+104]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; notlog t.36, t
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+105]
        mov [rax], bl
        ; call printIntLf@bool[t.36]
        lea rax, [rsp+105]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.37, [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+112]
        mov [rbx], rax
        ; call printString@@u8[t.37]
        lea rax, [rsp+112]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
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
        ; move t.39, b10
        lea rax, [rsp+10]
        mov bl, [rax]
        lea rax, [rsp+121]
        mov [rax], bl
        ; and t.39, t.39, b6
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+11]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+121]
        mov [rax], bl
        ; move t.38, t.39
        lea rax, [rsp+121]
        mov bl, [rax]
        lea rax, [rsp+120]
        mov [rax], bl
        ; or t.38, t.38, b1
        lea rax, [rsp+120]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+120]
        mov [rax], bl
        ; call printIntLf@u8[t.38]
        lea rax, [rsp+120]
        mov bl, [rax]
        push rbx
          call @printIntLf@u8
        add rsp, 8
        ; 43:20 logic or
        ; equals t.40, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+122]
        mov [rax], bl
        ; branch t.40, true, @or_next_13, @or_2nd_13
        lea rax, [rsp+122]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_13
        ; lt t.40, c, d
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+122]
        mov [rax], bl
@or_next_13:
        ; call printIntLf@bool[t.40]
        lea rax, [rsp+122]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; 44:20 logic and
        ; equals t.41, b, c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+123]
        mov [rax], bl
        ; branch t.41, false, @and_next_14, @and_2nd_14
        lea rax, [rsp+123]
        mov bl, [rax]
        or bl, bl
        jz @and_next_14
        ; lt t.41, c, d
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+123]
        mov [rax], bl
@and_next_14:
        ; call printIntLf@bool[t.41]
        lea rax, [rsp+123]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.42, -1
        mov ax, -1
        lea rbx, [rsp+124]
        mov [rbx], ax
        ; call printIntLf@i16[t.42]
        lea rax, [rsp+124]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; neg t.43, b
        lea rax, [rsp+2]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+126]
        mov [rax], bx
        ; call printIntLf@i16[t.43]
        lea rax, [rsp+126]
        mov bx, [rax]
        push rbx
          call @printIntLf@i16
        add rsp, 8
        ; not t.44, b1
        lea rax, [rsp+12]
        mov bl, [rax]
        not rbx
        lea rax, [rsp+128]
        mov [rax], bl
        ; call printIntLf@u8[t.44]
        lea rax, [rsp+128]
        mov bl, [rax]
        push rbx
          call @printIntLf@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 144
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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
