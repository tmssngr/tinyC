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
        ;   rsp+129: var t.19
@printUint@i64:
        ; reserve space for local variables
        sub rsp, 144
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 25:2 while true
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
        ; move remainder, number
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, t.6
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
        ; cast t.8(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; const t.9, 48
        mov al, 48
        lea rbx, [rsp+57]
        mov [rbx], al
        ; move digit, t.8
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, t.9
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.11(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; cast t.12(u8*), t.11(i64)
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
        ; 31:3 if number == 0
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
        ; branch t.13, false, @while_1, @while_1_break
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.16(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; cast t.17(u8*), t.16(i64)
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
        ; const t.19, 20
        mov al, 20
        lea rbx, [rsp+129]
        mov [rbx], al
        ; move t.18, t.19
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+128]
        mov [rax], bl
        ; sub t.18, t.18, pos
        lea rax, [rsp+128]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+128]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.15, t.18]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+136]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call @printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 144
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

        ; void printIntLf@i64
        ;   rsp+40: arg number
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
        ;   rsp+16: var t.3
        ;   rsp+17: var t.4
@printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 32
        ; 51:2 if number < 0
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
        ; branch t.1, false, @if_3_end, @if_3_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_3_end
        ; const t.3, 45
        mov al, 45
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call printChar@u8[t.3]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; neg number, number
        lea rax, [rsp+40]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+40]
        mov [rax], rbx
@if_3_end:
        ; call printUint@i64[number]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printUint@i64
        add rsp, 8
        ; const t.4, 10
        mov al, 10
        lea rbx, [rsp+17]
        mov [rbx], al
        ; call printChar@u8[t.4]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 32
        ret

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
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
        ; cast t.7(i64), str(u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; const t.8, 1
        mov rax, 1
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; move t.6, t.7
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; add t.6, t.6, t.8
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; cast str(u8*), t.6(i64)
        lea rax, [rsp+24]
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
        ;   rsp+5: var d
        ;   rsp+8: var t.4
        ;   rsp+16: var t.5
        ;   rsp+17: var t.6
        ;   rsp+24: var t.7
        ;   rsp+32: var t.8
        ;   rsp+33: var t.9
        ;   rsp+40: var t.10
        ;   rsp+48: var t.11
        ;   rsp+49: var t.12
        ;   rsp+56: var t.13
        ;   rsp+64: var t.14
        ;   rsp+65: var t.15
        ;   rsp+72: var t.16
        ;   rsp+80: var t.17
        ;   rsp+81: var t.18
        ;   rsp+88: var t.19
        ;   rsp+96: var t.20
        ;   rsp+97: var t.21
        ;   rsp+104: var t.22
        ;   rsp+112: var t.23
        ;   rsp+113: var t.24
        ;   rsp+120: var t.25
        ;   rsp+128: var t.26
        ;   rsp+129: var t.27
        ;   rsp+136: var t.28
        ;   rsp+144: var t.29
        ;   rsp+145: var t.30
        ;   rsp+152: var t.31
        ;   rsp+160: var t.32
        ;   rsp+161: var t.33
@main:
        ; reserve space for local variables
        sub rsp, 176
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.4, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.4]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; const a, 1
        mov ax, 1
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const b, 2
        mov ax, 2
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; lt t.5, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; call printIntLf@bool[t.5]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; lt t.6, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+17]
        mov [rax], bl
        ; call printIntLf@bool[t.6]
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.7, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.7]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; const c, 0
        mov al, 0
        lea rbx, [rsp+4]
        mov [rbx], al
        ; const d, 128
        mov al, 128
        lea rbx, [rsp+5]
        mov [rbx], al
        ; lt t.8, c, d
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+32]
        mov [rax], bl
        ; call printIntLf@bool[t.8]
        lea rax, [rsp+32]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; lt t.9, d, c
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+33]
        mov [rax], bl
        ; call printIntLf@bool[t.9]
        lea rax, [rsp+33]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.10, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; call printString@@u8[t.10]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; lteq t.11, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+48]
        mov [rax], bl
        ; call printIntLf@bool[t.11]
        lea rax, [rsp+48]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; lteq t.12, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+49]
        mov [rax], bl
        ; call printIntLf@bool[t.12]
        lea rax, [rsp+49]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.13, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+56]
        mov [rbx], rax
        ; call printString@@u8[t.13]
        lea rax, [rsp+56]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; lteq t.14, c, d
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+64]
        mov [rax], bl
        ; call printIntLf@bool[t.14]
        lea rax, [rsp+64]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; lteq t.15, d, c
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+65]
        mov [rax], bl
        ; call printIntLf@bool[t.15]
        lea rax, [rsp+65]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.16, [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; call printString@@u8[t.16]
        lea rax, [rsp+72]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; equals t.17, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+80]
        mov [rax], bl
        ; call printIntLf@bool[t.17]
        lea rax, [rsp+80]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; equals t.18, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+81]
        mov [rax], bl
        ; call printIntLf@bool[t.18]
        lea rax, [rsp+81]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.19, [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+88]
        mov [rbx], rax
        ; call printString@@u8[t.19]
        lea rax, [rsp+88]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; notequals t.20, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setne bl
        lea rax, [rsp+96]
        mov [rax], bl
        ; call printIntLf@bool[t.20]
        lea rax, [rsp+96]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; notequals t.21, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        setne bl
        lea rax, [rsp+97]
        mov [rax], bl
        ; call printIntLf@bool[t.21]
        lea rax, [rsp+97]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.22, [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; call printString@@u8[t.22]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; gteq t.23, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setge bl
        lea rax, [rsp+112]
        mov [rax], bl
        ; call printIntLf@bool[t.23]
        lea rax, [rsp+112]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; gteq t.24, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        setge bl
        lea rax, [rsp+113]
        mov [rax], bl
        ; call printIntLf@bool[t.24]
        lea rax, [rsp+113]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.25, [string-7]
        lea rax, [string_7]
        lea rbx, [rsp+120]
        mov [rbx], rax
        ; call printString@@u8[t.25]
        lea rax, [rsp+120]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; gteq t.26, c, d
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+128]
        mov [rax], bl
        ; call printIntLf@bool[t.26]
        lea rax, [rsp+128]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; gteq t.27, d, c
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+129]
        mov [rax], bl
        ; call printIntLf@bool[t.27]
        lea rax, [rsp+129]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.28, [string-8]
        lea rax, [string_8]
        lea rbx, [rsp+136]
        mov [rbx], rax
        ; call printString@@u8[t.28]
        lea rax, [rsp+136]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; gt t.29, a, b
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+144]
        mov [rax], bl
        ; call printIntLf@bool[t.29]
        lea rax, [rsp+144]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; gt t.30, b, a
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+145]
        mov [rax], bl
        ; call printIntLf@bool[t.30]
        lea rax, [rsp+145]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; const t.31, [string-9]
        lea rax, [string_9]
        lea rbx, [rsp+152]
        mov [rbx], rax
        ; call printString@@u8[t.31]
        lea rax, [rsp+152]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; gt t.32, c, d
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+160]
        mov [rax], bl
        ; call printIntLf@bool[t.32]
        lea rax, [rsp+160]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; gt t.33, d, c
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+161]
        mov [rax], bl
        ; call printIntLf@bool[t.33]
        lea rax, [rsp+161]
        mov bl, [rax]
        push rbx
          call @printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 176
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
