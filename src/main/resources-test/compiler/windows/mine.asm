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

        ; void printUint@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
@printUint@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printUint@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call @printUint@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+152: arg number
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
        ;   rsp+128: var t.17
        ;   rsp+129: var t.18
@printUint@i64:
        ; reserve space for local variables
        sub rsp, 144
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
        lea rax, [rsp+152]
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
        ; const t.13, 0
        mov rax, 0
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; equals t.12, number, t.13
        lea rax, [rsp+152]
        mov rbx, [rax]
        lea rax, [rsp+96]
        mov rcx, [rax]
        cmp rbx, rcx
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.12, false, @while_1, @while_1_break
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @while_1
        ; cast t.15(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+112]
        mov [rax], rbx
        ; cast t.16(u8*), t.15(i64)
        lea rax, [rsp+112]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov [rax], rbx
        ; addrof t.14, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+104]
        mov [rbx], rax
        ; add t.14, t.14, t.16
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+120]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.18, 20
        mov al, 20
        lea rbx, [rsp+129]
        mov [rbx], al
        ; move t.17, t.18
        lea rax, [rsp+129]
        mov bl, [rax]
        lea rax, [rsp+128]
        mov [rax], bl
        ; sub t.17, t.17, pos
        lea rax, [rsp+128]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+128]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.14, t.17]
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

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
@strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 61:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; inc length
        lea rax, [rsp+0]
        mov rbx, [rax]
        inc rbx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; cast t.6(i64), str(u8*)
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; const t.7, 1
        mov rax, 1
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; move t.5, t.6
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        ; add t.5, t.5, t.7
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast str(u8*), t.5(i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], rbx
@for_3:
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
        ; branch t.2, true, @for_3_body, @for_3_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz @for_3_body
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

        ; void initRandom@i32
        ;   rsp+8: arg salt
@initRandom@i32:
        ; move __random__, salt
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ret

        ; i32 random
        ;   rsp+0: var r
        ;   rsp+4: var b
        ;   rsp+8: var c
        ;   rsp+12: var d
        ;   rsp+16: var e
        ;   rsp+20: var t.5
        ;   rsp+24: var t.6
        ;   rsp+28: var t.7
        ;   rsp+32: var t.8
        ;   rsp+36: var t.9
        ;   rsp+40: var t.10
        ;   rsp+44: var t.11
        ;   rsp+48: var t.12
        ;   rsp+52: var t.13
        ;   rsp+56: var t.14
        ;   rsp+60: var t.15
        ;   rsp+64: var t.16
        ;   rsp+68: var t.17
        ;   rsp+72: var t.18
        ;   rsp+76: var t.19
        ;   rsp+80: var t.20
@random:
        ; reserve space for local variables
        sub rsp, 96
        ; move r, __random__
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+0]
        mov [rax], ebx
        ; const t.6, 524287
        mov eax, 524287
        lea rbx, [rsp+24]
        mov [rbx], eax
        ; move t.5, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov [rax], ebx
        ; and t.5, t.5, t.6
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov ecx, [rax]
        and ebx, ecx
        lea rax, [rsp+20]
        mov [rax], ebx
        ; const t.7, 48271
        mov eax, 48271
        lea rbx, [rsp+28]
        mov [rbx], eax
        ; move b, t.5
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], ebx
        ; mul b, b, t.7
        lea rax, [rsp+4]
        mov ebx, [rax]
        lea rax, [rsp+28]
        mov ecx, [rax]
        movsxd rbx, ebx
        movsxd rcx, ecx
        imul  rbx, rcx
        lea rax, [rsp+4]
        mov [rax], ebx
        ; const t.9, 15
        mov eax, 15
        lea rbx, [rsp+36]
        mov [rbx], eax
        ; move t.8, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+32]
        mov [rax], ebx
        ; shiftright t.8, t.8, t.9
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+36]
        mov ecx, [rax]
        sar ebx, cl
        lea rax, [rsp+32]
        mov [rax], ebx
        ; const t.10, 48271
        mov eax, 48271
        lea rbx, [rsp+40]
        mov [rbx], eax
        ; move c, t.8
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mul c, c, t.10
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+40]
        mov ecx, [rax]
        movsxd rbx, ebx
        movsxd rcx, ecx
        imul  rbx, rcx
        lea rax, [rsp+8]
        mov [rax], ebx
        ; const t.12, 65535
        mov eax, 65535
        lea rbx, [rsp+48]
        mov [rbx], eax
        ; move t.11, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov [rax], ebx
        ; and t.11, t.11, t.12
        lea rax, [rsp+44]
        mov ebx, [rax]
        lea rax, [rsp+48]
        mov ecx, [rax]
        and ebx, ecx
        lea rax, [rsp+44]
        mov [rax], ebx
        ; const t.13, 15
        mov eax, 15
        lea rbx, [rsp+52]
        mov [rbx], eax
        ; move d, t.11
        lea rax, [rsp+44]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], ebx
        ; shiftleft d, d, t.13
        lea rax, [rsp+12]
        mov ebx, [rax]
        lea rax, [rsp+52]
        mov ecx, [rax]
        sal ebx, cl
        lea rax, [rsp+12]
        mov [rax], ebx
        ; const t.16, 16
        mov eax, 16
        lea rbx, [rsp+64]
        mov [rbx], eax
        ; move t.15, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+60]
        mov [rax], ebx
        ; shiftright t.15, t.15, t.16
        lea rax, [rsp+60]
        mov ebx, [rax]
        lea rax, [rsp+64]
        mov ecx, [rax]
        sar ebx, cl
        lea rax, [rsp+60]
        mov [rax], ebx
        ; move t.14, t.15
        lea rax, [rsp+60]
        mov ebx, [rax]
        lea rax, [rsp+56]
        mov [rax], ebx
        ; add t.14, t.14, b
        lea rax, [rsp+56]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+56]
        mov [rax], ebx
        ; move e, t.14
        lea rax, [rsp+56]
        mov ebx, [rax]
        lea rax, [rsp+16]
        mov [rax], ebx
        ; add e, e, d
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+16]
        mov [rax], ebx
        ; const t.18, 2147483647
        mov eax, 2147483647
        lea rbx, [rsp+72]
        mov [rbx], eax
        ; move t.17, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+68]
        mov [rax], ebx
        ; and t.17, t.17, t.18
        lea rax, [rsp+68]
        mov ebx, [rax]
        lea rax, [rsp+72]
        mov ecx, [rax]
        and ebx, ecx
        lea rax, [rsp+68]
        mov [rax], ebx
        ; const t.20, 31
        mov eax, 31
        lea rbx, [rsp+80]
        mov [rbx], eax
        ; move t.19, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+76]
        mov [rax], ebx
        ; shiftright t.19, t.19, t.20
        lea rax, [rsp+76]
        mov ebx, [rax]
        lea rax, [rsp+80]
        mov ecx, [rax]
        sar ebx, cl
        lea rax, [rsp+76]
        mov [rax], ebx
        ; move __random__, t.17
        lea rax, [rsp+68]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ; add __random__, __random__, t.19
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+76]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [var_0]
        mov [rax], ebx
        ; 155:9 return __random__
        ; ret __random__
        lea rax, [var_0]
        mov ebx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 96
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
@rowColumnToCell@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 15:21 return row * 40 + column
        ; const t.4, 40
        mov ax, 40
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; move t.3, row
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mul t.3, t.3, t.4
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        movsx rbx, bx
        movsx rcx, cx
        imul  rbx, rcx
        lea rax, [rsp+2]
        mov [rax], bx
        ; move t.2, t.3
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov [rax], bx
        ; add t.2, t.2, column
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+32]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+0]
        mov [rax], bx
        ; ret t.2
        lea rax, [rsp+0]
        mov bx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getCell@i16@i16
        ;   rsp+72: arg row
        ;   rsp+64: arg column
        ;   rsp+0: var t.2
        ;   rsp+8: var t.3
        ;   rsp+16: var t.4
        ;   rsp+24: var t.5
        ;   rsp+32: var t.6
@getCell@i16@i16:
        ; reserve space for local variables
        sub rsp, 48
        ; 19:15 return [...]
        ; call t.5 = rowColumnToCell@i16@i16[row, column] -> i16
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @rowColumnToCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+24]
        mov [rbx], ax
        ; cast t.4(i64), t.5(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+16]
        mov [rax], rbx
        ; cast t.6(u8*), t.4(i64)
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; addrof t.3, [field]
        lea rax, [var_1]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.3, t.3, t.6
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; load t.2, [t.3]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+0]
        mov [rbx], al
        ; ret t.2
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; bool isBomb@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isBomb@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 23:27 return cell & 1 != 0
        ; const t.3, 1
        mov al, 1
        lea rbx, [rsp+2]
        mov [rbx], al
        ; move t.2, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        ; and t.2, t.2, t.3
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+3]
        mov [rbx], al
        ; notequals t.1, t.2, t.4
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; ret t.1
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isOpen@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isOpen@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 27:27 return cell & 2 != 0
        ; const t.3, 2
        mov al, 2
        lea rbx, [rsp+2]
        mov [rbx], al
        ; move t.2, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        ; and t.2, t.2, t.3
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+3]
        mov [rbx], al
        ; notequals t.1, t.2, t.4
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; ret t.1
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isFlag@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isFlag@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 31:27 return cell & 4 != 0
        ; const t.3, 4
        mov al, 4
        lea rbx, [rsp+2]
        mov [rbx], al
        ; move t.2, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        ; and t.2, t.2, t.3
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+2]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+1]
        mov [rax], bl
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+3]
        mov [rbx], al
        ; notequals t.1, t.2, t.4
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; ret t.1
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
@checkCellBounds@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const t.3, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; gteq t.2, row, t.3
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setge bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.2, false, @and_next_6, @and_2nd_6
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @and_next_6
        ; const t.4, 20
        mov ax, 20
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; lt t.2, row, t.4
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
@and_next_6:
        ; branch t.2, false, @and_next_5, @and_2nd_5
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @and_next_5
        ; const t.5, 0
        mov ax, 0
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; gteq t.2, column, t.5
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setge bl
        lea rax, [rsp+0]
        mov [rax], bl
@and_next_5:
        ; branch t.2, false, @and_next_4, @and_2nd_4
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @and_next_4
        ; const t.6, 40
        mov ax, 40
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; lt t.2, column, t.6
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
@and_next_4:
        ; ret t.2
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void setCell@i16@i16@u8
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg cell
        ;   rsp+0: var t.3
        ;   rsp+8: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
@setCell@i16@i16@u8:
        ; reserve space for local variables
        sub rsp, 32
        ; call t.5 = rowColumnToCell@i16@i16[row, column] -> i16
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @rowColumnToCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+16]
        mov [rbx], ax
        ; cast t.4(i64), t.5(i16)
        lea rax, [rsp+16]
        mov bx, [rax]
        movzx rbx, bx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; cast t.6(u8*), t.4(i64)
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; addrof t.3, [field]
        lea rax, [var_1]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; add t.3, t.3, t.6
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; store [t.3], cell
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov cl, [rax]
        mov [rbx], cl
        ; release space for local variables
        add rsp, 32
        ret

        ; u8 getBombCountAround@i16@i16
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var count
        ;   rsp+2: var dr
        ;   rsp+4: var r
        ;   rsp+6: var dc
        ;   rsp+8: var c
        ;   rsp+10: var cell
        ;   rsp+11: var t.8
        ;   rsp+12: var t.9
        ;   rsp+14: var t.10
        ;   rsp+16: var t.11
        ;   rsp+18: var t.12
        ;   rsp+19: var t.13
@getBombCountAround@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; const count, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const dr, -1
        mov ax, -1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 45:2 for dr <= 1
        jmp @for_7
@for_7_body:
        ; move r, row
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; add r, r, dr
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+4]
        mov [rax], bx
        ; const dc, -1
        mov ax, -1
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; 47:3 for dc <= 1
        jmp @for_8
@for_8_body:
        ; move c, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov [rax], bx
        ; add c, c, dc
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+8]
        mov [rax], bx
        ; 49:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; call t.12 = checkCellBounds@i16@i16[r, c] -> bool
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @checkCellBounds@i16@i16
        add rsp, 24
        lea rbx, [rsp+18]
        mov [rbx], al
        ; branch t.12, false, @for_8_continue, @if_9_then
        lea rax, [rsp+18]
        mov bl, [rax]
        or bl, bl
        jz @for_8_continue
        ; call cell = getCell@i16@i16[r, c] -> u8
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+10]
        mov [rbx], al
        ; 51:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; call t.13 = isBomb@u8[cell] -> bool
        lea rax, [rsp+10]
        mov bl, [rax]
        push rbx
          call @isBomb@u8
        add rsp, 8
        lea rbx, [rsp+19]
        mov [rbx], al
        ; branch t.13, false, @for_8_continue, @if_10_then
        lea rax, [rsp+19]
        mov bl, [rax]
        or bl, bl
        jz @for_8_continue
        ; inc count
        lea rax, [rsp+0]
        mov bl, [rax]
        inc bl
        lea rax, [rsp+0]
        mov [rax], bl
@for_8_continue:
        ; inc dc
        lea rax, [rsp+6]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+6]
        mov [rax], bx
@for_8:
        ; const t.11, 1
        mov ax, 1
        lea rbx, [rsp+16]
        mov [rbx], ax
        ; lteq t.10, dc, t.11
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+16]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+14]
        mov [rax], bl
        ; branch t.10, true, @for_8_body, @for_7_continue
        lea rax, [rsp+14]
        mov bl, [rax]
        or bl, bl
        jnz @for_8_body
        ; inc dr
        lea rax, [rsp+2]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+2]
        mov [rax], bx
@for_7:
        ; const t.9, 1
        mov ax, 1
        lea rbx, [rsp+12]
        mov [rbx], ax
        ; lteq t.8, dr, t.9
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+11]
        mov [rax], bl
        ; branch t.8, true, @for_7_body, @for_7_break
        lea rax, [rsp+11]
        mov bl, [rax]
        or bl, bl
        jnz @for_7_body
        ; 57:9 return count
        ; ret count
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 32
        ret

        ; u8 getSpacer@i16@i16@i16@i16
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg rowCursor
        ;   rsp+32: arg columnCursor
        ;   rsp+0: var t.4
        ;   rsp+1: var t.5
        ;   rsp+2: var t.6
        ;   rsp+3: var t.7
        ;   rsp+4: var t.8
        ;   rsp+6: var t.9
        ;   rsp+8: var t.10
        ;   rsp+9: var t.11
@getSpacer@i16@i16@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 61:2 if rowCursor == row
        ; equals t.4, rowCursor, row
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.4, false, @if_11_end, @if_11_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; equals t.5, columnCursor, column
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+48]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.5, true, @if_12_then, @if_12_end
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jnz @if_12_then
        ; 65:3 if columnCursor == column - 1
        ; const t.9, 1
        mov ax, 1
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; move t.8, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; sub t.8, t.8, t.9
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+4]
        mov [rax], bx
        ; equals t.7, columnCursor, t.8
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+3]
        mov [rax], bl
        ; branch t.7, false, @if_11_end, @if_13_then
        lea rax, [rsp+3]
        mov bl, [rax]
        or bl, bl
        jz @if_11_end
        jmp @if_13_then
@if_12_then:
        ; 63:11 return 91
        ; const t.6, 91
        mov al, 91
        lea rbx, [rsp+2]
        mov [rbx], al
        ; ret t.6
        lea rax, [rsp+2]
        mov bl, [rax]
        mov rax, rbx
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_13_then:
        ; 66:11 return 93
        ; const t.10, 93
        mov al, 93
        lea rbx, [rsp+8]
        mov [rbx], al
        ; ret t.10
        lea rax, [rsp+8]
        mov bl, [rax]
        mov rax, rbx
        jmp @getSpacer@i16@i16@i16@i16_ret
@if_11_end:
        ; 69:9 return 32
        ; const t.11, 32
        mov al, 32
        lea rbx, [rsp+9]
        mov [rbx], al
        ; ret t.11
        lea rax, [rsp+9]
        mov bl, [rax]
        mov rax, rbx
@getSpacer@i16@i16@i16@i16_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+40: arg cell
        ;   rsp+32: arg row
        ;   rsp+24: arg column
        ;   rsp+0: var chr
        ;   rsp+1: var count
        ;   rsp+2: var t.5
        ;   rsp+3: var t.6
        ;   rsp+4: var t.7
        ;   rsp+5: var t.8
        ;   rsp+6: var t.9
        ;   rsp+7: var t.10
@printCell@u8@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const chr, 46
        mov al, 46
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 74:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=74:13]])
        ; call t.5 = isOpen@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call @isOpen@u8
        add rsp, 8
        lea rbx, [rsp+2]
        mov [rbx], al
        ; branch t.5, false, @if_14_else, @if_14_then
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jz @if_14_else
        ; 75:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:14]])
        ; call t.6 = isBomb@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call @isBomb@u8
        add rsp, 8
        lea rbx, [rsp+3]
        mov [rbx], al
        ; branch t.6, true, @if_15_then, @if_15_else
        lea rax, [rsp+3]
        mov bl, [rax]
        or bl, bl
        jnz @if_15_then
        ; call count = getBombCountAround@i16@i16[row, column] -> u8
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getBombCountAround@i16@i16
        add rsp, 24
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 80:4 if count > 0
        ; const t.8, 0
        mov al, 0
        lea rbx, [rsp+5]
        mov [rbx], al
        ; gt t.7, count, t.8
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.7, false, @if_16_else, @if_16_then
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz @if_16_else
        jmp @if_16_then
@if_15_then:
        ; const chr, 42
        mov al, 42
        lea rbx, [rsp+0]
        mov [rbx], al
        jmp @if_14_end
@if_16_else:
        ; const chr, 32
        mov al, 32
        lea rbx, [rsp+0]
        mov [rbx], al
        jmp @if_14_else
@if_16_then:
        ; const t.9, 48
        mov al, 48
        lea rbx, [rsp+6]
        mov [rbx], al
        ; move chr, count
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; add chr, chr, t.9
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+6]
        mov cl, [rax]
        add bl, cl
        lea rax, [rsp+0]
        mov [rax], bl
        jmp @if_14_end
@if_14_else:
        ; 88:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=88:18]])
        ; call t.10 = isFlag@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call @isFlag@u8
        add rsp, 8
        lea rbx, [rsp+7]
        mov [rbx], al
        ; branch t.10, false, @if_14_end, @if_17_then
        lea rax, [rsp+7]
        mov bl, [rax]
        or bl, bl
        jz @if_14_end
        ; const chr, 35
        mov al, 35
        lea rbx, [rsp+0]
        mov [rbx], al
@if_14_end:
        ; call printChar@u8[chr]
        lea rax, [rsp+0]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printField@i16@i16
        ;   rsp+56: arg rowCursor
        ;   rsp+48: arg columnCursor
        ;   rsp+0: var row
        ;   rsp+2: var column
        ;   rsp+4: var spacer
        ;   rsp+5: var cell
        ;   rsp+6: var spacer
        ;   rsp+8: var t.7
        ;   rsp+10: var t.8
        ;   rsp+12: var t.9
        ;   rsp+14: var t.10
        ;   rsp+16: var t.11
        ;   rsp+17: var t.12
        ;   rsp+18: var t.13
        ;   rsp+20: var t.14
        ;   rsp+24: var t.15
@printField@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; const t.7, 0
        mov ax, 0
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; const t.8, 0
        mov ax, 0
        lea rbx, [rsp+10]
        mov [rbx], ax
        ; call setCursor@i16@i16[t.7, t.8]
        lea rax, [rsp+8]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+18]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @setCursor@i16@i16
        add rsp, 24
        ; const row, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 96:2 for row < 20
        jmp @for_18
@for_18_body:
        ; const t.11, 124
        mov al, 124
        lea rbx, [rsp+16]
        mov [rbx], al
        ; call printChar@u8[t.11]
        lea rax, [rsp+16]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; const column, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 98:3 for column < 40
        jmp @for_19
@for_19_body:
        ; call spacer = getSpacer@i16@i16@i16@i16[row, column, rowCursor, columnCursor] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getSpacer@i16@i16@i16@i16
        add rsp, 40
        lea rbx, [rsp+4]
        mov [rbx], al
        ; call printChar@u8[spacer]
        lea rax, [rsp+4]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; call cell = getCell@i16@i16[row, column] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+5]
        mov [rbx], al
        ; call printCell@u8@i16@i16[cell, row, column]
        lea rax, [rsp+5]
        mov bl, [rax]
        push rbx
        lea rax, [rsp+8]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+18]
        mov bx, [rax]
        push rbx
          call @printCell@u8@i16@i16
        add rsp, 24
        ; inc column
        lea rax, [rsp+2]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+2]
        mov [rax], bx
@for_19:
        ; const t.13, 40
        mov ax, 40
        lea rbx, [rsp+18]
        mov [rbx], ax
        ; lt t.12, column, t.13
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.12, true, @for_19_body, @for_19_break
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        jnz @for_19_body
        ; const t.14, 40
        mov ax, 40
        lea rbx, [rsp+20]
        mov [rbx], ax
        ; call spacer = getSpacer@i16@i16@i16@i16[row, t.14, rowCursor, columnCursor] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+28]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getSpacer@i16@i16@i16@i16
        add rsp, 40
        lea rbx, [rsp+6]
        mov [rbx], al
        ; call printChar@u8[spacer]
        lea rax, [rsp+6]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; const t.15, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.15]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; inc row
        lea rax, [rsp+0]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+0]
        mov [rax], bx
@for_18:
        ; const t.10, 20
        mov ax, 20
        lea rbx, [rsp+14]
        mov [rbx], ax
        ; lt t.9, row, t.10
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.9, true, @for_18_body, @printField@i16@i16_ret
        lea rax, [rsp+12]
        mov bl, [rax]
        or bl, bl
        jnz @for_18_body
        ; release space for local variables
        add rsp, 32
        ret

        ; void printSpaces@i16
        ;   rsp+24: arg i
        ;   rsp+0: var t.1
        ;   rsp+2: var t.2
        ;   rsp+4: var t.3
@printSpaces@i16:
        ; reserve space for local variables
        sub rsp, 16
        jmp @for_20
@for_20_body:
        ; const t.3, 48
        mov al, 48
        lea rbx, [rsp+4]
        mov [rbx], al
        ; call printChar@u8[t.3]
        lea rax, [rsp+4]
        mov bl, [rax]
        push rbx
          call @printChar@u8
        add rsp, 8
        ; dec i
        lea rax, [rsp+24]
        mov bx, [rax]
        dec bx
        lea rax, [rsp+24]
        mov [rax], bx
@for_20:
        ; const t.2, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; gt t.1, i, t.2
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, true, @for_20_body, @printSpaces@i16_ret
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jnz @for_20_body
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getDigitCount@i16
        ;   rsp+24: arg value
        ;   rsp+0: var count
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
@getDigitCount@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const count, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 118:2 if value < 0
        ; const t.3, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; lt t.2, value, t.3
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.2, false, @while_22, @if_21_then
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jz @while_22
        ; const count, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; neg value, value
        lea rax, [rsp+24]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+24]
        mov [rax], bx
@while_22:
        ; inc count
        lea rax, [rsp+0]
        mov bl, [rax]
        inc bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; const t.4, 10
        mov ax, 10
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; div value, value, t.4
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+24]
        mov [rdx], bx
        ; 126:3 if value == 0
        ; const t.6, 0
        mov ax, 0
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; equals t.5, value, t.6
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+6]
        mov [rax], bl
        ; branch t.5, false, @while_22, @while_22_break
        lea rax, [rsp+6]
        mov bl, [rax]
        or bl, bl
        jz @while_22
        ; 131:9 return count
        ; ret count
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; i16 getHiddenCount
        ;   rsp+0: var count
        ;   rsp+2: var r
        ;   rsp+4: var c
        ;   rsp+6: var cell
        ;   rsp+7: var t.4
        ;   rsp+8: var t.5
        ;   rsp+10: var t.6
        ;   rsp+12: var t.7
        ;   rsp+14: var t.8
        ;   rsp+15: var t.9
        ;   rsp+16: var t.10
        ;   rsp+17: var t.11
@getHiddenCount:
        ; reserve space for local variables
        sub rsp, 32
        ; const count, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const r, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 136:2 for r < 20
        jmp @for_24
@for_24_body:
        ; const c, 0
        mov ax, 0
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 137:3 for c < 40
        jmp @for_25
@for_25_body:
        ; call cell = getCell@i16@i16[r, c] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+12]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+6]
        mov [rbx], al
        ; 139:4 if cell & 6 == 0
        ; const t.10, 6
        mov al, 6
        lea rbx, [rsp+16]
        mov [rbx], al
        ; move t.9, cell
        lea rax, [rsp+6]
        mov bl, [rax]
        lea rax, [rsp+15]
        mov [rax], bl
        ; and t.9, t.9, t.10
        lea rax, [rsp+15]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov cl, [rax]
        and bl, cl
        lea rax, [rsp+15]
        mov [rax], bl
        ; const t.11, 0
        mov al, 0
        lea rbx, [rsp+17]
        mov [rbx], al
        ; equals t.8, t.9, t.11
        lea rax, [rsp+15]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov cl, [rax]
        cmp bl, cl
        sete bl
        lea rax, [rsp+14]
        mov [rax], bl
        ; branch t.8, false, @for_25_continue, @if_26_then
        lea rax, [rsp+14]
        mov bl, [rax]
        or bl, bl
        jz @for_25_continue
        ; inc count
        lea rax, [rsp+0]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+0]
        mov [rax], bx
@for_25_continue:
        ; inc c
        lea rax, [rsp+4]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+4]
        mov [rax], bx
@for_25:
        ; const t.7, 40
        mov ax, 40
        lea rbx, [rsp+12]
        mov [rbx], ax
        ; lt t.6, c, t.7
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+10]
        mov [rax], bl
        ; branch t.6, true, @for_25_body, @for_24_continue
        lea rax, [rsp+10]
        mov bl, [rax]
        or bl, bl
        jnz @for_25_body
        ; inc r
        lea rax, [rsp+2]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+2]
        mov [rax], bx
@for_24:
        ; const t.5, 20
        mov ax, 20
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; lt t.4, r, t.5
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+7]
        mov [rax], bl
        ; branch t.4, true, @for_24_body, @for_24_break
        lea rax, [rsp+7]
        mov bl, [rax]
        or bl, bl
        jnz @for_24_body
        ; 144:9 return count
        ; ret count
        lea rax, [rsp+0]
        mov bx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 32
        ret

        ; bool printLeft
        ;   rsp+0: var count
        ;   rsp+2: var leftDigits
        ;   rsp+4: var bombDigits
        ;   rsp+6: var t.3
        ;   rsp+7: var t.4
        ;   rsp+8: var t.5
        ;   rsp+16: var t.6
        ;   rsp+24: var t.7
        ;   rsp+26: var t.8
        ;   rsp+28: var t.9
@printLeft:
        ; reserve space for local variables
        sub rsp, 32
        ; call count = getHiddenCount[] -> i16
        sub rsp, 8
          call @getHiddenCount
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; call t.3 = getDigitCount@i16[count] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call @getDigitCount@i16
        add rsp, 8
        lea rbx, [rsp+6]
        mov [rbx], al
        ; cast leftDigits(i16), t.3(u8)
        lea rax, [rsp+6]
        mov bl, [rax]
        movzx bx, bl
        lea rax, [rsp+2]
        mov [rax], bx
        ; const t.5, 40
        mov ax, 40
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; call t.4 = getDigitCount@i16[t.5] -> u8
        lea rax, [rsp+8]
        mov bx, [rax]
        push rbx
          call @getDigitCount@i16
        add rsp, 8
        lea rbx, [rsp+7]
        mov [rbx], al
        ; cast bombDigits(i16), t.4(u8)
        lea rax, [rsp+7]
        mov bl, [rax]
        movzx bx, bl
        lea rax, [rsp+4]
        mov [rax], bx
        ; const t.6, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call printString@@u8[t.6]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        ; move t.7, bombDigits
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; sub t.7, t.7, leftDigits
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+24]
        mov [rax], bx
        ; call printSpaces@i16[t.7]
        lea rax, [rsp+24]
        mov bx, [rax]
        push rbx
          call @printSpaces@i16
        add rsp, 8
        ; call printUint@i16[count]
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call @printUint@i16
        add rsp, 8
        ; 155:15 return count == 0
        ; const t.9, 0
        mov ax, 0
        lea rbx, [rsp+28]
        mov [rbx], ax
        ; equals t.8, count, t.9
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+26]
        mov [rax], bl
        ; ret t.8
        lea rax, [rsp+26]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 32
        ret

        ; i16 abs@i16
        ;   rsp+24: arg a
        ;   rsp+0: var t.1
        ;   rsp+2: var t.2
        ;   rsp+4: var t.3
@abs@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 159:2 if a < 0
        ; const t.2, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; lt t.1, a, t.2
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, true, @if_27_then, @if_27_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jnz @if_27_then
        ; 162:9 return a
        ; ret a
        lea rax, [rsp+24]
        mov bx, [rax]
        mov rax, rbx
        jmp @abs@i16_ret
@if_27_then:
        ; 160:10 return -a
        ; neg t.3, a
        lea rax, [rsp+24]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+4]
        mov [rax], bx
        ; ret t.3
        lea rax, [rsp+4]
        mov bx, [rax]
        mov rax, rbx
@abs@i16_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void clearField
        ;   rsp+0: var r
        ;   rsp+2: var c
        ;   rsp+4: var t.2
        ;   rsp+6: var t.3
        ;   rsp+8: var t.4
        ;   rsp+10: var t.5
        ;   rsp+12: var t.6
@clearField:
        ; reserve space for local variables
        sub rsp, 16
        ; const r, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 166:2 for r < 20
        jmp @for_28
@for_28_body:
        ; const c, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 167:3 for c < 40
        jmp @for_29
@for_29_body:
        ; const t.6, 0
        mov al, 0
        lea rbx, [rsp+12]
        mov [rbx], al
        ; call setCell@i16@i16@u8[r, c, t.6]
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+28]
        mov bl, [rax]
        push rbx
          call @setCell@i16@i16@u8
        add rsp, 24
        ; inc c
        lea rax, [rsp+2]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+2]
        mov [rax], bx
@for_29:
        ; const t.5, 40
        mov ax, 40
        lea rbx, [rsp+10]
        mov [rbx], ax
        ; lt t.4, c, t.5
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.4, true, @for_29_body, @for_28_continue
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz @for_29_body
        ; inc r
        lea rax, [rsp+0]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+0]
        mov [rax], bx
@for_28:
        ; const t.3, 20
        mov ax, 20
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; lt t.2, r, t.3
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.2, true, @for_28_body, @clearField_ret
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jnz @for_28_body
        ; release space for local variables
        add rsp, 16
        ret

        ; void initField@i16@i16
        ;   rsp+88: arg curr_r
        ;   rsp+80: arg curr_c
        ;   rsp+0: var bombs
        ;   rsp+2: var row
        ;   rsp+4: var column
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
        ;   rsp+12: var t.7
        ;   rsp+16: var t.8
        ;   rsp+20: var t.9
        ;   rsp+24: var t.10
        ;   rsp+28: var t.11
        ;   rsp+32: var t.12
        ;   rsp+36: var t.13
        ;   rsp+38: var t.14
        ;   rsp+40: var t.15
        ;   rsp+42: var t.16
        ;   rsp+44: var t.17
        ;   rsp+46: var t.18
        ;   rsp+48: var t.19
        ;   rsp+50: var t.20
@initField@i16@i16:
        ; reserve space for local variables
        sub rsp, 64
        ; const bombs, 40
        mov ax, 40
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 174:2 for bombs > 0
        jmp @for_30
@for_30_body:
        ; call t.8 = random[] -> i32
        sub rsp, 8
          call @random
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], eax
        ; const t.9, 20
        mov eax, 20
        lea rbx, [rsp+20]
        mov [rbx], eax
        ; move t.7, t.8
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], ebx
        ; mod t.7, t.7, t.9
        lea rax, [rsp+12]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov ecx, [rax]
        movsxd rax, ebx
        movsxd rcx, ecx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+12]
        mov [rdx], ebx
        ; cast row(i16), t.7(i32)
        lea rax, [rsp+12]
        mov ebx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; call t.11 = random[] -> i32
        sub rsp, 8
          call @random
        add rsp, 8
        lea rbx, [rsp+28]
        mov [rbx], eax
        ; const t.12, 40
        mov eax, 40
        lea rbx, [rsp+32]
        mov [rbx], eax
        ; move t.10, t.11
        lea rax, [rsp+28]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov [rax], ebx
        ; mod t.10, t.10, t.12
        lea rax, [rsp+24]
        mov ebx, [rax]
        lea rax, [rsp+32]
        mov ecx, [rax]
        movsxd rax, ebx
        movsxd rcx, ecx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+24]
        mov [rdx], ebx
        ; cast column(i16), t.10(i32)
        lea rax, [rsp+24]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; 177:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move t.15, row
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; sub t.15, t.15, curr_r
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+88]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+40]
        mov [rax], bx
        ; call t.14 = abs@i16[t.15] -> i16
        lea rax, [rsp+40]
        mov bx, [rax]
        push rbx
          call @abs@i16
        add rsp, 8
        lea rbx, [rsp+38]
        mov [rbx], ax
        ; const t.16, 1
        mov ax, 1
        lea rbx, [rsp+42]
        mov [rbx], ax
        ; gt t.13, t.14, t.16
        lea rax, [rsp+38]
        mov bx, [rax]
        lea rax, [rsp+42]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+36]
        mov [rax], bl
        ; branch t.13, true, @or_next_32, @or_2nd_32
        lea rax, [rsp+36]
        mov bl, [rax]
        or bl, bl
        jnz @or_next_32
        ; move t.18, column
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov [rax], bx
        ; sub t.18, t.18, curr_c
        lea rax, [rsp+46]
        mov bx, [rax]
        lea rax, [rsp+80]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+46]
        mov [rax], bx
        ; call t.17 = abs@i16[t.18] -> i16
        lea rax, [rsp+46]
        mov bx, [rax]
        push rbx
          call @abs@i16
        add rsp, 8
        lea rbx, [rsp+44]
        mov [rbx], ax
        ; const t.19, 1
        mov ax, 1
        lea rbx, [rsp+48]
        mov [rbx], ax
        ; gt t.13, t.17, t.19
        lea rax, [rsp+44]
        mov bx, [rax]
        lea rax, [rsp+48]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+36]
        mov [rax], bl
@or_next_32:
        ; branch t.13, false, @for_30_continue, @if_31_then
        lea rax, [rsp+36]
        mov bl, [rax]
        or bl, bl
        jz @for_30_continue
        ; const t.20, 1
        mov al, 1
        lea rbx, [rsp+50]
        mov [rbx], al
        ; call setCell@i16@i16@u8[row, column, t.20]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+12]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+66]
        mov bl, [rax]
        push rbx
          call @setCell@i16@i16@u8
        add rsp, 24
@for_30_continue:
        ; dec bombs
        lea rax, [rsp+0]
        mov bx, [rax]
        dec bx
        lea rax, [rsp+0]
        mov [rax], bx
@for_30:
        ; const t.6, 0
        mov ax, 0
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; gt t.5, bombs, t.6
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+6]
        mov [rax], bl
        ; branch t.5, true, @for_30_body, @initField@i16@i16_ret
        lea rax, [rsp+6]
        mov bl, [rax]
        or bl, bl
        jnz @for_30_body
        ; release space for local variables
        add rsp, 64
        ret

        ; void maybeRevealAround@i16@i16
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var dr
        ;   rsp+2: var r
        ;   rsp+4: var dc
        ;   rsp+6: var c
        ;   rsp+8: var cell
        ;   rsp+9: var t.7
        ;   rsp+10: var t.8
        ;   rsp+11: var t.9
        ;   rsp+12: var t.10
        ;   rsp+14: var t.11
        ;   rsp+16: var t.12
        ;   rsp+18: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
        ;   rsp+26: var t.17
        ;   rsp+27: var t.18
        ;   rsp+28: var t.19
        ;   rsp+29: var t.20
        ;   rsp+30: var t.21
@maybeRevealAround@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; 185:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=185:30]]) != 0
        ; call t.8 = getBombCountAround@i16@i16[row, column] -> u8
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getBombCountAround@i16@i16
        add rsp, 24
        lea rbx, [rsp+10]
        mov [rbx], al
        ; const t.9, 0
        mov al, 0
        lea rbx, [rsp+11]
        mov [rbx], al
        ; notequals t.7, t.8, t.9
        lea rax, [rsp+10]
        mov bl, [rax]
        lea rax, [rsp+11]
        mov cl, [rax]
        cmp bl, cl
        setne bl
        lea rax, [rsp+9]
        mov [rax], bl
        ; branch t.7, true, @maybeRevealAround@i16@i16_ret, @if_33_end
        lea rax, [rsp+9]
        mov bl, [rax]
        or bl, bl
        jnz @maybeRevealAround@i16@i16_ret
        ; const dr, -1
        mov ax, -1
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 189:2 for dr <= 1
        jmp @for_34
@for_34_body:
        ; move r, row
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; add r, r, dr
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+2]
        mov [rax], bx
        ; const dc, -1
        mov ax, -1
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 191:3 for dc <= 1
        jmp @for_35
@for_35_body:
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; const t.15, 0
        mov ax, 0
        lea rbx, [rsp+22]
        mov [rbx], ax
        ; equals t.14, dr, t.15
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+22]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+20]
        mov [rax], bl
        ; branch t.14, false, @and_next_37, @and_2nd_37
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jz @and_next_37
        ; const t.16, 0
        mov ax, 0
        lea rbx, [rsp+24]
        mov [rbx], ax
        ; equals t.14, dc, t.16
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+20]
        mov [rax], bl
@and_next_37:
        ; branch t.14, true, @for_35_continue, @if_36_end
        lea rax, [rsp+20]
        mov bl, [rax]
        or bl, bl
        jnz @for_35_continue
        ; move c, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        ; add c, c, dc
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+6]
        mov [rax], bx
        ; 197:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; call t.18 = checkCellBounds@i16@i16[r, c] -> bool
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @checkCellBounds@i16@i16
        add rsp, 24
        lea rbx, [rsp+27]
        mov [rbx], al
        ; notlog t.17, t.18
        lea rax, [rsp+27]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+26]
        mov [rax], bl
        ; branch t.17, true, @for_35_continue, @if_38_end
        lea rax, [rsp+26]
        mov bl, [rax]
        or bl, bl
        jnz @for_35_continue
        ; call cell = getCell@i16@i16[r, c] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+8]
        mov [rbx], al
        ; 202:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; call t.19 = isOpen@u8[cell] -> bool
        lea rax, [rsp+8]
        mov bl, [rax]
        push rbx
          call @isOpen@u8
        add rsp, 8
        lea rbx, [rsp+28]
        mov [rbx], al
        ; branch t.19, true, @for_35_continue, @if_39_end
        lea rax, [rsp+28]
        mov bl, [rax]
        or bl, bl
        jnz @for_35_continue
        ; const t.21, 2
        mov al, 2
        lea rbx, [rsp+30]
        mov [rbx], al
        ; move t.20, cell
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+29]
        mov [rax], bl
        ; or t.20, t.20, t.21
        lea rax, [rsp+29]
        mov bl, [rax]
        lea rax, [rsp+30]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+29]
        mov [rax], bl
        ; call setCell@i16@i16@u8[r, c, t.20]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+45]
        mov bl, [rax]
        push rbx
          call @setCell@i16@i16@u8
        add rsp, 24
        ; call maybeRevealAround@i16@i16[r, c]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @maybeRevealAround@i16@i16
        add rsp, 24
@for_35_continue:
        ; inc dc
        lea rax, [rsp+4]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+4]
        mov [rax], bx
@for_35:
        ; const t.13, 1
        mov ax, 1
        lea rbx, [rsp+18]
        mov [rbx], ax
        ; lteq t.12, dc, t.13
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.12, true, @for_35_body, @for_34_continue
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz @for_35_body
        ; inc dr
        lea rax, [rsp+0]
        mov bx, [rax]
        inc bx
        lea rax, [rsp+0]
        mov [rax], bx
@for_34:
        ; const t.11, 1
        mov ax, 1
        lea rbx, [rsp+14]
        mov [rbx], ax
        ; lteq t.10, dr, t.11
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.10, true, @for_34_body, @maybeRevealAround@i16@i16_ret
        lea rax, [rsp+12]
        mov bl, [rax]
        or bl, bl
        jnz @for_34_body
@maybeRevealAround@i16@i16_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var needsInitialize
        ;   rsp+2: var curr_c
        ;   rsp+4: var curr_r
        ;   rsp+6: var chr
        ;   rsp+8: var cell
        ;   rsp+9: var cell
        ;   rsp+12: var t.6
        ;   rsp+16: var t.7
        ;   rsp+17: var t.8
        ;   rsp+24: var t.9
        ;   rsp+32: var t.10
        ;   rsp+34: var t.11
        ;   rsp+36: var t.12
        ;   rsp+38: var t.13
        ;   rsp+40: var t.14
        ;   rsp+42: var t.15
        ;   rsp+44: var t.16
        ;   rsp+46: var t.17
        ;   rsp+48: var t.18
        ;   rsp+50: var t.19
        ;   rsp+52: var t.20
        ;   rsp+54: var t.21
        ;   rsp+56: var t.22
        ;   rsp+58: var t.23
        ;   rsp+60: var t.24
        ;   rsp+62: var t.25
        ;   rsp+64: var t.26
        ;   rsp+66: var t.27
        ;   rsp+68: var t.28
        ;   rsp+70: var t.29
        ;   rsp+72: var t.30
        ;   rsp+74: var t.31
        ;   rsp+76: var t.32
        ;   rsp+78: var t.33
        ;   rsp+80: var t.34
        ;   rsp+82: var t.35
        ;   rsp+84: var t.36
        ;   rsp+86: var t.37
        ;   rsp+88: var t.38
        ;   rsp+90: var t.39
        ;   rsp+92: var t.40
        ;   rsp+94: var t.41
        ;   rsp+96: var t.42
        ;   rsp+98: var t.43
        ;   rsp+100: var t.44
        ;   rsp+102: var t.45
        ;   rsp+103: var t.46
        ;   rsp+104: var t.47
        ;   rsp+105: var t.48
        ;   rsp+106: var t.49
        ;   rsp+108: var t.50
        ;   rsp+110: var t.51
        ;   rsp+111: var t.52
        ;   rsp+112: var t.53
        ;   rsp+113: var t.54
        ;   rsp+114: var t.55
        ;   rsp+120: var t.56
@main:
        ; reserve space for local variables
        sub rsp, 128
        ; begin initialize global variables
        ; const __random__, 0
        mov eax, 0
        lea rbx, [var_0]
        mov [rbx], eax
        ; end initialize global variables
        ; const t.6, 7439742
        mov eax, 7439742
        lea rbx, [rsp+12]
        mov [rbx], eax
        ; call initRandom@i32[t.6]
        lea rax, [rsp+12]
        mov ebx, [rax]
        push rbx
          call @initRandom@i32
        add rsp, 8
        ; const needsInitialize, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; call clearField[]
        sub rsp, 8
          call @clearField
        add rsp, 8
        ; const curr_c, 20
        mov ax, 20
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; const curr_r, 10
        mov ax, 10
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 218:2 while true
        jmp @while_40
@if_41_then:
        ; 221:4 if printLeft([])
        ; call t.8 = printLeft[] -> bool
        sub rsp, 8
          call @printLeft
        add rsp, 8
        lea rbx, [rsp+17]
        mov [rbx], al
        ; branch t.8, true, @if_42_then, @if_41_end
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        jnz @if_42_then
@if_41_end:
        ; call chr = getChar[] -> i16
        sub rsp, 8
          call @getChar
        add rsp, 8
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; 228:3 if chr == 27
        ; const t.11, 27
        mov ax, 27
        lea rbx, [rsp+34]
        mov [rbx], ax
        ; equals t.10, chr, t.11
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+34]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+32]
        mov [rax], bl
        ; branch t.10, true, @main_ret, @if_43_end
        lea rax, [rsp+32]
        mov bl, [rax]
        or bl, bl
        jnz @main_ret
        ; 233:3 if chr == -8120
        ; const t.13, -8120
        mov ax, -8120
        lea rbx, [rsp+38]
        mov [rbx], ax
        ; equals t.12, chr, t.13
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+38]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+36]
        mov [rax], bl
        ; branch t.12, true, @if_44_then, @if_44_else
        lea rax, [rsp+36]
        mov bl, [rax]
        or bl, bl
        jnz @if_44_then
        ; 237:8 if chr == -8112
        ; const t.20, -8112
        mov ax, -8112
        lea rbx, [rsp+52]
        mov [rbx], ax
        ; equals t.19, chr, t.20
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+52]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+50]
        mov [rax], bl
        ; branch t.19, false, @if_45_else, @if_45_then
        lea rax, [rsp+50]
        mov bl, [rax]
        or bl, bl
        jz @if_45_else
        jmp @if_45_then
@if_44_then:
        ; const t.16, 20
        mov ax, 20
        lea rbx, [rsp+44]
        mov [rbx], ax
        ; move t.15, curr_r
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+42]
        mov [rax], bx
        ; add t.15, t.15, t.16
        lea rax, [rsp+42]
        mov bx, [rax]
        lea rax, [rsp+44]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+42]
        mov [rax], bx
        ; const t.17, 1
        mov ax, 1
        lea rbx, [rsp+46]
        mov [rbx], ax
        ; move t.14, t.15
        lea rax, [rsp+42]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; sub t.14, t.14, t.17
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+40]
        mov [rax], bx
        ; const t.18, 20
        mov ax, 20
        lea rbx, [rsp+48]
        mov [rbx], ax
        ; move curr_r, t.14
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; mod curr_r, curr_r, t.18
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+48]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+4]
        mov [rdx], bx
        jmp @while_40
@if_45_else:
        ; 241:8 if chr == -8117
        ; const t.25, -8117
        mov ax, -8117
        lea rbx, [rsp+62]
        mov [rbx], ax
        ; equals t.24, chr, t.25
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+62]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+60]
        mov [rax], bl
        ; branch t.24, false, @if_46_else, @if_46_then
        lea rax, [rsp+60]
        mov bl, [rax]
        or bl, bl
        jz @if_46_else
        jmp @if_46_then
@if_45_then:
        ; const t.22, 1
        mov ax, 1
        lea rbx, [rsp+56]
        mov [rbx], ax
        ; move t.21, curr_r
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+54]
        mov [rax], bx
        ; add t.21, t.21, t.22
        lea rax, [rsp+54]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+54]
        mov [rax], bx
        ; const t.23, 20
        mov ax, 20
        lea rbx, [rsp+58]
        mov [rbx], ax
        ; move curr_r, t.21
        lea rax, [rsp+54]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; mod curr_r, curr_r, t.23
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+58]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+4]
        mov [rdx], bx
        jmp @while_40
@if_46_else:
        ; 245:8 if chr == -8117
        ; const t.32, -8117
        mov ax, -8117
        lea rbx, [rsp+76]
        mov [rbx], ax
        ; equals t.31, chr, t.32
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+76]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+74]
        mov [rax], bl
        ; branch t.31, false, @if_47_else, @if_47_then
        lea rax, [rsp+74]
        mov bl, [rax]
        or bl, bl
        jz @if_47_else
        jmp @if_47_then
@if_46_then:
        ; const t.28, 40
        mov ax, 40
        lea rbx, [rsp+68]
        mov [rbx], ax
        ; move t.27, curr_c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+66]
        mov [rax], bx
        ; add t.27, t.27, t.28
        lea rax, [rsp+66]
        mov bx, [rax]
        lea rax, [rsp+68]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+66]
        mov [rax], bx
        ; const t.29, 1
        mov ax, 1
        lea rbx, [rsp+70]
        mov [rbx], ax
        ; move t.26, t.27
        lea rax, [rsp+66]
        mov bx, [rax]
        lea rax, [rsp+64]
        mov [rax], bx
        ; sub t.26, t.26, t.29
        lea rax, [rsp+64]
        mov bx, [rax]
        lea rax, [rsp+70]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+64]
        mov [rax], bx
        ; const t.30, 40
        mov ax, 40
        lea rbx, [rsp+72]
        mov [rbx], ax
        ; move curr_c, t.26
        lea rax, [rsp+64]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mod curr_c, curr_c, t.30
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+72]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+2]
        mov [rdx], bx
        jmp @while_40
@if_47_else:
        ; 249:8 if chr == -8115
        ; const t.39, -8115
        mov ax, -8115
        lea rbx, [rsp+90]
        mov [rbx], ax
        ; equals t.38, chr, t.39
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+90]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; branch t.38, false, @if_48_else, @if_48_then
        lea rax, [rsp+88]
        mov bl, [rax]
        or bl, bl
        jz @if_48_else
        jmp @if_48_then
@if_47_then:
        ; const t.35, 40
        mov ax, 40
        lea rbx, [rsp+82]
        mov [rbx], ax
        ; move t.34, curr_c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+80]
        mov [rax], bx
        ; add t.34, t.34, t.35
        lea rax, [rsp+80]
        mov bx, [rax]
        lea rax, [rsp+82]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+80]
        mov [rax], bx
        ; const t.36, 1
        mov ax, 1
        lea rbx, [rsp+84]
        mov [rbx], ax
        ; move t.33, t.34
        lea rax, [rsp+80]
        mov bx, [rax]
        lea rax, [rsp+78]
        mov [rax], bx
        ; sub t.33, t.33, t.36
        lea rax, [rsp+78]
        mov bx, [rax]
        lea rax, [rsp+84]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+78]
        mov [rax], bx
        ; const t.37, 40
        mov ax, 40
        lea rbx, [rsp+86]
        mov [rbx], ax
        ; move curr_c, t.33
        lea rax, [rsp+78]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mod curr_c, curr_c, t.37
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+86]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+2]
        mov [rdx], bx
        jmp @while_40
@if_48_else:
        ; 253:8 if chr == 32
        ; const t.44, 32
        mov ax, 32
        lea rbx, [rsp+100]
        mov [rbx], ax
        ; equals t.43, chr, t.44
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+100]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+98]
        mov [rax], bl
        ; branch t.43, false, @if_49_else, @if_49_then
        lea rax, [rsp+98]
        mov bl, [rax]
        or bl, bl
        jz @if_49_else
        jmp @if_49_then
@if_48_then:
        ; const t.41, 1
        mov ax, 1
        lea rbx, [rsp+94]
        mov [rbx], ax
        ; move t.40, curr_c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+92]
        mov [rax], bx
        ; add t.40, t.40, t.41
        lea rax, [rsp+92]
        mov bx, [rax]
        lea rax, [rsp+94]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+92]
        mov [rax], bx
        ; const t.42, 40
        mov ax, 40
        lea rbx, [rsp+96]
        mov [rbx], ax
        ; move curr_c, t.40
        lea rax, [rsp+92]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mod curr_c, curr_c, t.42
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+96]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rdx
        lea rdx, [rsp+2]
        mov [rdx], bx
        jmp @while_40
@if_49_then:
        ; 254:4 if !needsInitialize
        ; notlog t.45, needsInitialize
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+102]
        mov [rax], bl
        ; branch t.45, false, @while_40, @if_50_then
        lea rax, [rsp+102]
        mov bl, [rax]
        or bl, bl
        jz @while_40
        ; call cell = getCell@i16@i16[curr_r, curr_c] -> u8
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+8]
        mov [rbx], al
        ; 256:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; call t.47 = isOpen@u8[cell] -> bool
        lea rax, [rsp+8]
        mov bl, [rax]
        push rbx
          call @isOpen@u8
        add rsp, 8
        lea rbx, [rsp+104]
        mov [rbx], al
        ; notlog t.46, t.47
        lea rax, [rsp+104]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+103]
        mov [rax], bl
        ; branch t.46, false, @while_40, @if_51_then
        lea rax, [rsp+103]
        mov bl, [rax]
        or bl, bl
        jz @while_40
        ; const t.48, 4
        mov al, 4
        lea rbx, [rsp+105]
        mov [rbx], al
        ; xor cell, cell, t.48
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+105]
        mov cl, [rax]
        xor bl, cl
        lea rax, [rsp+8]
        mov [rax], bl
        ; call setCell@i16@i16@u8[curr_r, curr_c, cell]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+24]
        mov bl, [rax]
        push rbx
          call @setCell@i16@i16@u8
        add rsp, 24
@if_49_else:
        ; 262:8 if chr == 13
        ; const t.50, 13
        mov ax, 13
        lea rbx, [rsp+108]
        mov [rbx], ax
        ; equals t.49, chr, t.50
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+108]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+106]
        mov [rax], bl
        ; branch t.49, true, @if_52_then, @while_40
        lea rax, [rsp+106]
        mov bl, [rax]
        or bl, bl
        jnz @if_52_then
@while_40:
        ; call printField@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @printField@i16@i16
        add rsp, 24
        ; 220:3 if !needsInitialize
        ; notlog t.7, needsInitialize
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.7, false, @if_41_end, @if_41_then
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz @if_41_end
        jmp @if_41_then
@if_42_then:
        ; const t.9, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.9]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
        jmp @main_ret
@if_52_then:
        ; branch needsInitialize, false, @if_53_end, @if_53_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz @if_53_end
        ; call initField@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @initField@i16@i16
        add rsp, 24
@if_53_end:
        ; call cell = getCell@i16@i16[curr_r, curr_c] -> u8
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+9]
        mov [rbx], al
        ; 268:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; call t.52 = isOpen@u8[cell] -> bool
        lea rax, [rsp+9]
        mov bl, [rax]
        push rbx
          call @isOpen@u8
        add rsp, 8
        lea rbx, [rsp+111]
        mov [rbx], al
        ; notlog t.51, t.52
        lea rax, [rsp+111]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+110]
        mov [rax], bl
        ; branch t.51, false, @if_54_end, @if_54_then
        lea rax, [rsp+110]
        mov bl, [rax]
        or bl, bl
        jz @if_54_end
        ; const t.54, 2
        mov al, 2
        lea rbx, [rsp+113]
        mov [rbx], al
        ; move t.53, cell
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+112]
        mov [rax], bl
        ; or t.53, t.53, t.54
        lea rax, [rsp+112]
        mov bl, [rax]
        lea rax, [rsp+113]
        mov cl, [rax]
        or bl, cl
        lea rax, [rsp+112]
        mov [rax], bl
        ; call setCell@i16@i16@u8[curr_r, curr_c, t.53]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+128]
        mov bl, [rax]
        push rbx
          call @setCell@i16@i16@u8
        add rsp, 24
@if_54_end:
        ; 271:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; call t.55 = isBomb@u8[cell] -> bool
        lea rax, [rsp+9]
        mov bl, [rax]
        push rbx
          call @isBomb@u8
        add rsp, 8
        lea rbx, [rsp+114]
        mov [rbx], al
        ; branch t.55, true, @if_55_then, @if_55_end
        lea rax, [rsp+114]
        mov bl, [rax]
        or bl, bl
        jnz @if_55_then
        ; call maybeRevealAround@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @maybeRevealAround@i16@i16
        add rsp, 24
        jmp @main_ret
@if_55_then:
        ; call printField@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call @printField@i16@i16
        add rsp, 24
        ; const t.56, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+120]
        mov [rbx], rax
        ; call printString@@u8[t.56]
        lea rax, [rsp+120]
        mov rbx, [rax]
        push rbx
          call @printString@@u8
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 128
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

        ; i16 getChar
@getChar:
        sub    rsp, 28h
          call [_getch]
          test al, al
          js   .1
          jnz  .2
          dec  al
.1:
          mov  rbx, rax
          shl  rbx, 8
          call [_getch]
          or   rax, rbx
.2:
        add    rsp, 28h
        ret

        ; void setCursor@i16@i16
@setCursor@i16@i16:
        mov     rdi, rsp
        and     spl, 0xf0

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     dx, [rdi+10h]
        shl     rdx, 16
        mov     dx, [rdi+18h]
        sub     rsp, 20h
          call   [SetConsoleCursorPosition]
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
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/6400)
        var_1 rb 6400

section '.data' data readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

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
