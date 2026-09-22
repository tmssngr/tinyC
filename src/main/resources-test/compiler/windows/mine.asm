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
          call _main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void printString@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length.1
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length.1 = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@i64[str, length.1]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1.1
_printChar@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof t.1.1, chr
        lea rax, [rsp+24]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printStringLength@@u8@u8[t.1.1, 1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
        mov  rax, 1
        push rax
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printUint@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printUint@i64[t.1.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printUint@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+136: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos.1
        ;   rsp+24: var number.1
        ;   rsp+32: var pos.2
        ;   rsp+33: var pos.3
        ;   rsp+40: var remainder.1
        ;   rsp+48: var number.2
        ;   rsp+56: var t.5.1
        ;   rsp+57: var digit.1
        ;   rsp+64: var t.7.1
        ;   rsp+72: var t.6.1
        ;   rsp+80: var t.6.2
        ;   rsp+88: var t.9.1
        ;   rsp+96: var t.8.1
        ;   rsp+104: var t.8.2
        ;   rsp+112: var t.11.1
        ;   rsp+113: var t.10.1
_printUint@i64:
        ; reserve space for local variables
        sub rsp, 128
        ; const pos.1, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 28:2 while true
        ; move number.1, number
        lea rax, [rsp+136]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; move pos.2, pos.1
        lea rax, [rsp+20]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        jmp _while_1
_printUint@i64.no_critical_edge_4:
        ; move number.1, number.2
        lea rax, [rsp+48]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; move pos.2, pos.3
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
_while_1:
        ; move pos.3, pos.2
        lea rax, [rsp+32]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        ; sub pos.3, pos.3, 1
        lea rax, [rsp+33]
        mov bl, [rax]
        sub bl, 1
        lea rax, [rsp+33]
        mov [rax], bl
        ; move remainder.1, number.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov [rax], rbx
        ; mod remainder.1, remainder.1, 10
        lea rax, [rsp+40]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+40]
        mov [rcx], rbx
        ; move number.2, number.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov [rax], rbx
        ; div number.2, number.2, 10
        lea rax, [rsp+48]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+48]
        mov [rcx], rbx
        ; cast t.5.1(u8), remainder.1(i64)
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+56]
        mov [rax], bl
        ; move digit.1, t.5.1
        lea rax, [rsp+56]
        mov bl, [rax]
        lea rax, [rsp+57]
        mov [rax], bl
        ; add digit.1, digit.1, 48
        lea rax, [rsp+57]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+57]
        mov [rax], bl
        ; cast t.7.1(i64), pos.3(u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+64]
        mov [rax], rbx
        ; addrof t.6.1, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; move t.6.2, t.6.1
        lea rax, [rsp+72]
        mov rbx, [rax]
        lea rax, [rsp+80]
        mov [rax], rbx
        ; add t.6.2, t.6.2, t.7.1
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+64]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+80]
        mov [rax], rbx
        ; store [t.6.2], digit.1
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+57]
        mov cl, [rax]
        mov [rbx], cl
        ; 34:3 if number == 0
        ; branch number.2 notequals 0: printUint@i64.no_critical_edge_4, while_1_break
        lea rax, [rsp+48]
        mov rbx, [rax]
        cmp rbx, 0
        jne _printUint@i64.no_critical_edge_4
        ; cast t.9.1(i64), pos.3(u8)
        lea rax, [rsp+33]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+88]
        mov [rax], rbx
        ; addrof t.8.1, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; move t.8.2, t.8.1
        lea rax, [rsp+96]
        mov rbx, [rax]
        lea rax, [rsp+104]
        mov [rax], rbx
        ; add t.8.2, t.8.2, t.9.1
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+104]
        mov [rax], rbx
        ; const t.11.1, 20
        mov al, 20
        lea rbx, [rsp+112]
        mov [rbx], al
        ; move t.10.1, t.11.1
        lea rax, [rsp+112]
        mov bl, [rax]
        lea rax, [rsp+113]
        mov [rax], bl
        ; sub t.10.1, t.10.1, pos.3
        lea rax, [rsp+113]
        mov bl, [rax]
        lea rax, [rsp+33]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+113]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.8.2, t.10.1]
        lea rax, [rsp+104]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+121]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 128
        ret

        ; i64 strlen@@u8
        ;   rsp+56: arg str
        ;   rsp+0: var length.1
        ;   rsp+8: var str.1
        ;   rsp+16: var length.2
        ;   rsp+24: var t.2.1
        ;   rsp+32: var length.3
        ;   rsp+40: var str.2
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 48
        ; const length.1, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        ; move str.1, str
        lea rax, [rsp+56]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.1
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
        jmp _for_3
_for_3_body:
        ; move length.3, length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov [rax], rbx
        ; add length.3, length.3, 1
        lea rax, [rsp+32]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+32]
        mov [rax], rbx
        ; move str.2, str.1
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+40]
        mov [rax], rbx
        ; add str.2, str.2, 1
        lea rax, [rsp+40]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+40]
        mov [rax], rbx
        ; move str.1, str.2
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move length.2, length.3
        lea rax, [rsp+32]
        mov rbx, [rax]
        lea rax, [rsp+16]
        mov [rax], rbx
_for_3:
        ; load t.2.1, [str.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+24]
        mov [rbx], al
        ; branch t.2.1 notequals 0: for_3_body, for_3_break
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 0
        jne _for_3_body
        ; 67:9 return length
        ; ret length.2
        lea rax, [rsp+16]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2.1
_printStringLength@@u8@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.2.1(i64), length(u8)
        lea rax, [rsp+32]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printStringLength@@u8@i64[str, t.2.1]
        lea rax, [rsp+40]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void initRandom@i32
        ;   rsp+24: arg salt
        ;   rsp+0: var a.__random__
        ;   rsp+8: var t.__random__
_initRandom@i32:
        ; reserve space for local variables
        sub rsp, 16
        ; move t.__random__, salt
        lea rax, [rsp+24]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; addrof a.__random__, __random__
        lea rax, [var_0]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; store [a.__random__], t.__random__
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov ecx, [rax]
        mov [rbx], ecx
        ; release space for local variables
        add rsp, 16
        ret

        ; i32 random
        ;   rsp+0: var r.1
        ;   rsp+4: var t.5.1
        ;   rsp+8: var b.1
        ;   rsp+12: var t.6.1
        ;   rsp+16: var c.1
        ;   rsp+20: var t.7.1
        ;   rsp+24: var d.1
        ;   rsp+28: var t.9.1
        ;   rsp+32: var t.8.1
        ;   rsp+36: var e.1
        ;   rsp+40: var t.10.1
        ;   rsp+44: var t.11.1
        ;   rsp+48: var a.__random__
        ;   rsp+56: var t.__random__
        ;   rsp+64: var a.__random__1
        ;   rsp+72: var t.__random__1
        ;   rsp+80: var a.__random__2
        ;   rsp+88: var t.__random__2
_random:
        ; reserve space for local variables
        sub rsp, 96
        ; addrof a.__random__, __random__
        lea rax, [var_0]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; load t.__random__, [a.__random__]
        lea rax, [rsp+48]
        mov rbx, [rax]
        mov eax, [rbx]
        lea rbx, [rsp+56]
        mov [rbx], eax
        ; move r.1, t.__random__
        lea rax, [rsp+56]
        mov ebx, [rax]
        lea rax, [rsp+0]
        mov [rax], ebx
        ; move t.5.1, r.1
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], ebx
        ; and t.5.1, t.5.1, 524287
        lea rax, [rsp+4]
        mov ebx, [rax]
        and ebx, 524287
        lea rax, [rsp+4]
        mov [rax], ebx
        ; move b.1, t.5.1
        lea rax, [rsp+4]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mul b.1, b.1, 48271
        lea rax, [rsp+8]
        mov ebx, [rax]
        movsxd rbx, ebx
        imul  rbx, 48271
        lea rax, [rsp+8]
        mov [rax], ebx
        ; move t.6.1, r.1
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], ebx
        ; shiftright t.6.1, t.6.1, 15
        lea rax, [rsp+12]
        mov ebx, [rax]
        sar ebx, 15
        lea rax, [rsp+12]
        mov [rax], ebx
        ; move c.1, t.6.1
        lea rax, [rsp+12]
        mov ebx, [rax]
        lea rax, [rsp+16]
        mov [rax], ebx
        ; mul c.1, c.1, 48271
        lea rax, [rsp+16]
        mov ebx, [rax]
        movsxd rbx, ebx
        imul  rbx, 48271
        lea rax, [rsp+16]
        mov [rax], ebx
        ; move t.7.1, c.1
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov [rax], ebx
        ; and t.7.1, t.7.1, 65535
        lea rax, [rsp+20]
        mov ebx, [rax]
        and ebx, 65535
        lea rax, [rsp+20]
        mov [rax], ebx
        ; move d.1, t.7.1
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov [rax], ebx
        ; shiftleft d.1, d.1, 15
        lea rax, [rsp+24]
        mov ebx, [rax]
        sal ebx, 15
        lea rax, [rsp+24]
        mov [rax], ebx
        ; move t.9.1, c.1
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+28]
        mov [rax], ebx
        ; shiftright t.9.1, t.9.1, 16
        lea rax, [rsp+28]
        mov ebx, [rax]
        sar ebx, 16
        lea rax, [rsp+28]
        mov [rax], ebx
        ; move t.8.1, t.9.1
        lea rax, [rsp+28]
        mov ebx, [rax]
        lea rax, [rsp+32]
        mov [rax], ebx
        ; add t.8.1, t.8.1, b.1
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+32]
        mov [rax], ebx
        ; move e.1, t.8.1
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+36]
        mov [rax], ebx
        ; add e.1, e.1, d.1
        lea rax, [rsp+36]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+36]
        mov [rax], ebx
        ; move t.10.1, e.1
        lea rax, [rsp+36]
        mov ebx, [rax]
        lea rax, [rsp+40]
        mov [rax], ebx
        ; and t.10.1, t.10.1, 2147483647
        lea rax, [rsp+40]
        mov ebx, [rax]
        and ebx, 2147483647
        lea rax, [rsp+40]
        mov [rax], ebx
        ; move t.11.1, e.1
        lea rax, [rsp+36]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov [rax], ebx
        ; shiftright t.11.1, t.11.1, 31
        lea rax, [rsp+44]
        mov ebx, [rax]
        sar ebx, 31
        lea rax, [rsp+44]
        mov [rax], ebx
        ; move t.__random__1, t.10.1
        lea rax, [rsp+40]
        mov ebx, [rax]
        lea rax, [rsp+72]
        mov [rax], ebx
        ; add t.__random__1, t.__random__1, t.11.1
        lea rax, [rsp+72]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+72]
        mov [rax], ebx
        ; addrof a.__random__1, __random__
        lea rax, [var_0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; store [a.__random__1], t.__random__1
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov ecx, [rax]
        mov [rbx], ecx
        ; 15:9 return __random__
        ; addrof a.__random__2, __random__
        lea rax, [var_0]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; load t.__random__2, [a.__random__2]
        lea rax, [rsp+80]
        mov rbx, [rax]
        mov eax, [rbx]
        lea rbx, [rsp+88]
        mov [rbx], eax
        ; ret t.__random__2
        lea rax, [rsp+88]
        mov ebx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 96
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.3.1
        ;   rsp+2: var t.2.1
_rowColumnToCell@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 16:21 return row * 40 + column
        ; move t.3.1, row
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov [rax], bx
        ; mul t.3.1, t.3.1, 40
        lea rax, [rsp+0]
        mov bx, [rax]
        movsx rbx, bx
        imul  rbx, 40
        lea rax, [rsp+0]
        mov [rax], bx
        ; move t.2.1, t.3.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; add t.2.1, t.2.1, column
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+32]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+2]
        mov [rax], bx
        ; ret t.2.1
        lea rax, [rsp+2]
        mov bx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getCell@i16@i16
        ;   rsp+72: arg row
        ;   rsp+64: arg column
        ;   rsp+0: var t.5.1
        ;   rsp+8: var t.4.1
        ;   rsp+16: var t.3.1
        ;   rsp+24: var t.3.2
        ;   rsp+32: var t.2.1
_getCell@i16@i16:
        ; reserve space for local variables
        sub rsp, 48
        ; 20:15 return [...]
        ; call t.5.1 = rowColumnToCell@i16@i16[row, column] -> i16
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _rowColumnToCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; cast t.4.1(i64), t.5.1(i16)
        lea rax, [rsp+0]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; addrof t.3.1, [field]
        lea rax, [var_1]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; move t.3.2, t.3.1
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; add t.3.2, t.3.2, t.4.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; load t.2.1, [t.3.2]
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+32]
        mov [rbx], al
        ; ret t.2.1
        lea rax, [rsp+32]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; bool isBomb@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.2.1
        ;   rsp+1: var t.1.1
_isBomb@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 24:27 return cell & 1 != 0
        ; move t.2.1, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; and t.2.1, t.2.1, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        and bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
        ; notequals t.1.1, t.2.1, 0
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; ret t.1.1
        lea rax, [rsp+1]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isOpen@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.2.1
        ;   rsp+1: var t.1.1
_isOpen@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 28:27 return cell & 2 != 0
        ; move t.2.1, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; and t.2.1, t.2.1, 2
        lea rax, [rsp+0]
        mov bl, [rax]
        and bl, 2
        lea rax, [rsp+0]
        mov [rax], bl
        ; notequals t.1.1, t.2.1, 0
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; ret t.1.1
        lea rax, [rsp+1]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isFlag@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.2.1
        ;   rsp+1: var t.1.1
_isFlag@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 32:27 return cell & 4 != 0
        ; move t.2.1, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; and t.2.1, t.2.1, 4
        lea rax, [rsp+0]
        mov bl, [rax]
        and bl, 4
        lea rax, [rsp+0]
        mov [rax], bl
        ; notequals t.1.1, t.2.1, 0
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; ret t.1.1
        lea rax, [rsp+1]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2.1
        ;   rsp+1: var t.2.2
        ;   rsp+2: var t.2.3
        ;   rsp+3: var t.2.4
        ;   rsp+4: var t.2.5
        ;   rsp+5: var t.2.6
        ;   rsp+6: var t.2.7
_checkCellBounds@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 36:40 logic and
        ; 36:21 logic and
        ; gteq t.2.1, row, 0
        lea rax, [rsp+40]
        mov bx, [rax]
        cmp bx, 0
        setge bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.2.1 notequals 0: and_2nd_6, checkCellBounds@i16@i16.no_critical_edge_8
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_6
        ; move t.2.2, t.2.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        jmp _and_next_6
_and_2nd_6:
        ; lt t.2.3, row, 20
        lea rax, [rsp+40]
        mov bx, [rax]
        cmp bx, 20
        setl bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; move t.2.2, t.2.3
        lea rax, [rsp+2]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
_and_next_6:
        ; branch t.2.2 notequals 0: and_2nd_5, checkCellBounds@i16@i16.no_critical_edge_9
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_5
        ; move t.2.4, t.2.2
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov [rax], bl
        jmp _and_next_5
_and_2nd_5:
        ; gteq t.2.5, column, 0
        lea rax, [rsp+32]
        mov bx, [rax]
        cmp bx, 0
        setge bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; move t.2.4, t.2.5
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov [rax], bl
_and_next_5:
        ; branch t.2.4 notequals 0: and_2nd_4, checkCellBounds@i16@i16.no_critical_edge_10
        lea rax, [rsp+3]
        mov bl, [rax]
        cmp bl, 0
        jne _and_2nd_4
        ; move t.2.6, t.2.4
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov [rax], bl
        jmp _and_next_4
_and_2nd_4:
        ; lt t.2.7, column, 40
        lea rax, [rsp+32]
        mov bx, [rax]
        cmp bx, 40
        setl bl
        lea rax, [rsp+6]
        mov [rax], bl
        ; move t.2.6, t.2.7
        lea rax, [rsp+6]
        mov bl, [rax]
        lea rax, [rsp+5]
        mov [rax], bl
_and_next_4:
        ; ret t.2.6
        lea rax, [rsp+5]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void setCell@i16@i16@u8
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg cell
        ;   rsp+0: var t.5.1
        ;   rsp+8: var t.4.1
        ;   rsp+16: var t.3.1
        ;   rsp+24: var t.3.2
_setCell@i16@i16@u8:
        ; reserve space for local variables
        sub rsp, 32
        ; call t.5.1 = rowColumnToCell@i16@i16[row, column] -> i16
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _rowColumnToCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; cast t.4.1(i64), t.5.1(i16)
        lea rax, [rsp+0]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; addrof t.3.1, [field]
        lea rax, [var_1]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; move t.3.2, t.3.1
        lea rax, [rsp+16]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; add t.3.2, t.3.2, t.4.1
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+8]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+24]
        mov [rax], rbx
        ; store [t.3.2], cell
        lea rax, [rsp+24]
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
        ;   rsp+0: var count.1
        ;   rsp+2: var dr.1
        ;   rsp+4: var count.2
        ;   rsp+6: var dr.2
        ;   rsp+8: var r.1
        ;   rsp+10: var dc.1
        ;   rsp+12: var count.3
        ;   rsp+14: var dc.2
        ;   rsp+16: var dr.4
        ;   rsp+18: var c.1
        ;   rsp+20: var t.8.1
        ;   rsp+21: var count.4
        ;   rsp+22: var cell.1
        ;   rsp+23: var t.9.1
        ;   rsp+24: var dc.4
        ;   rsp+26: var count.5
_getBombCountAround@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; const count.1, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const dr.1, -1
        mov ax, -1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 46:2 for dr <= 1
        ; move count.2, count.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        ; move dr.2, dr.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        jmp _for_7
_for_7_body:
        ; move r.1, row
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov [rax], bx
        ; add r.1, r.1, dr.2
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+8]
        mov [rax], bx
        ; const dc.1, -1
        mov ax, -1
        lea rbx, [rsp+10]
        mov [rbx], ax
        ; 48:3 for dc <= 1
        ; move count.3, count.2
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov [rax], bl
        ; move dc.2, dc.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov [rax], bx
        jmp _for_8
_for_8_body:
        ; move c.1, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; add c.1, c.1, dc.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+18]
        mov [rax], bx
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; call t.8.1 = checkCellBounds@i16@i16[r.1, c.1] -> bool
        lea rax, [rsp+8]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _checkCellBounds@i16@i16
        add rsp, 24
        lea rbx, [rsp+20]
        mov [rbx], al
        ; branch t.8.1 notequals 0: if_9_then, getBombCountAround@i16@i16.no_critical_edge_11
        lea rax, [rsp+20]
        mov bl, [rax]
        cmp bl, 0
        jne _if_9_then
        ; move count.4, count.3
        lea rax, [rsp+12]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
        jmp _for_8_continue
_if_9_then:
        ; call cell.1 = getCell@i16@i16[r.1, c.1] -> u8
        lea rax, [rsp+8]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+22]
        mov [rbx], al
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; call t.9.1 = isBomb@u8[cell.1] -> bool
        lea rax, [rsp+22]
        mov bl, [rax]
        push rbx
          call _isBomb@u8
        add rsp, 8
        lea rbx, [rsp+23]
        mov [rbx], al
        ; branch t.9.1 notequals 0: if_10_then, getBombCountAround@i16@i16.no_critical_edge_12
        lea rax, [rsp+23]
        mov bl, [rax]
        cmp bl, 0
        jne _if_10_then
        ; move count.4, count.3
        lea rax, [rsp+12]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
        jmp _for_8_continue
_if_10_then:
        ; move count.5, count.3
        lea rax, [rsp+12]
        mov bl, [rax]
        lea rax, [rsp+26]
        mov [rax], bl
        ; add count.5, count.5, 1
        lea rax, [rsp+26]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+26]
        mov [rax], bl
        ; move count.4, count.5
        lea rax, [rsp+26]
        mov bl, [rax]
        lea rax, [rsp+21]
        mov [rax], bl
_for_8_continue:
        ; move dc.4, dc.2
        lea rax, [rsp+14]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; add dc.4, dc.4, 1
        lea rax, [rsp+24]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+24]
        mov [rax], bx
        ; move count.3, count.4
        lea rax, [rsp+21]
        mov bl, [rax]
        lea rax, [rsp+12]
        mov [rax], bl
        ; move dc.2, dc.4
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov [rax], bx
_for_8:
        ; branch dc.2 lteq 1: for_8_body, for_7_continue
        lea rax, [rsp+14]
        mov bx, [rax]
        cmp bx, 1
        jle _for_8_body
        ; move dr.4, dr.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+16]
        mov [rax], bx
        ; add dr.4, dr.4, 1
        lea rax, [rsp+16]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+16]
        mov [rax], bx
        ; move count.2, count.3
        lea rax, [rsp+12]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        ; move dr.2, dr.4
        lea rax, [rsp+16]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
_for_7:
        ; branch dr.2 lteq 1: for_7_body, for_7_break
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 1
        jle _for_7_body
        ; 58:9 return count
        ; ret count.2
        lea rax, [rsp+4]
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
        ;   rsp+0: var t.4.1
_getSpacer@i16@i16@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; branch rowCursor notequals row: if_11_end, if_11_then
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov cx, [rax]
        cmp bx, cx
        jne _if_11_end
        ; branch columnCursor equals column: if_12_then, if_12_end
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+48]
        mov cx, [rax]
        cmp bx, cx
        je _if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.4.1, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov [rax], bx
        ; sub t.4.1, t.4.1, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+0]
        mov [rax], bx
        ; branch columnCursor notequals t.4.1: if_11_end, if_13_then
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        cmp bx, cx
        jne _if_11_end
        jmp _if_13_then
_if_12_then:
        ; 64:11 return 91
        ; ret 91
        mov rax, 91
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_13_then:
        ; 67:11 return 93
        ; ret 93
        mov rax, 93
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_11_end:
        ; 70:9 return 32
        ; ret 32
        mov rax, 32
_getSpacer@i16@i16@i16@i16_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+40: arg cell
        ;   rsp+32: arg row
        ;   rsp+24: arg column
        ;   rsp+0: var chr.1
        ;   rsp+1: var t.5.1
        ;   rsp+2: var t.7.1
        ;   rsp+3: var t.6.1
        ;   rsp+4: var chr.2
        ;   rsp+5: var chr.3
        ;   rsp+6: var count.1
        ;   rsp+7: var chr.4
        ;   rsp+8: var chr.5
        ;   rsp+9: var chr.6
_printCell@u8@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const chr.1, 46
        mov al, 46
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; call t.5.1 = isOpen@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+1]
        mov [rbx], al
        ; branch t.5.1 notequals 0: if_14_then, if_14_else
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
        jne _if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; call t.7.1 = isFlag@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _isFlag@u8
        add rsp, 8
        lea rbx, [rsp+2]
        mov [rbx], al
        ; branch t.7.1 equals 0: printCell@u8@i16@i16.no_critical_edge_10, if_17_then
        lea rax, [rsp+2]
        mov bl, [rax]
        cmp bl, 0
        je _printCell@u8@i16@i16.no_critical_edge_10
        jmp _if_17_then
_if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; call t.6.1 = isBomb@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _isBomb@u8
        add rsp, 8
        lea rbx, [rsp+3]
        mov [rbx], al
        ; branch t.6.1 equals 0: if_15_else, if_15_then
        lea rax, [rsp+3]
        mov bl, [rax]
        cmp bl, 0
        je _if_15_else
        jmp _if_15_then
_printCell@u8@i16@i16.no_critical_edge_10:
        ; move chr.2, chr.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        jmp _if_14_end
_if_17_then:
        ; const chr.3, 35
        mov al, 35
        lea rbx, [rsp+5]
        mov [rbx], al
        ; move chr.2, chr.3
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        jmp _if_14_end
_if_15_else:
        ; call count.1 = getBombCountAround@i16@i16[row, column] -> u8
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getBombCountAround@i16@i16
        add rsp, 24
        lea rbx, [rsp+6]
        mov [rbx], al
        ; 81:4 if count > 0
        ; branch count.1 lteq 0: if_16_else, if_16_then
        lea rax, [rsp+6]
        mov bl, [rax]
        cmp bl, 0
        jbe _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr.4, 42
        mov al, 42
        lea rbx, [rsp+7]
        mov [rbx], al
        ; move chr.2, chr.4
        lea rax, [rsp+7]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        jmp _if_14_end
_if_16_else:
        ; const chr.5, 32
        mov al, 32
        lea rbx, [rsp+8]
        mov [rbx], al
        ; move chr.2, chr.5
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        jmp _if_14_end
_if_16_then:
        ; move chr.6, count.1
        lea rax, [rsp+6]
        mov bl, [rax]
        lea rax, [rsp+9]
        mov [rax], bl
        ; add chr.6, chr.6, 48
        lea rax, [rsp+9]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+9]
        mov [rax], bl
        ; move chr.2, chr.6
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
_if_14_end:
        ; call printChar@u8[chr.2]
        lea rax, [rsp+4]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printField@i16@i16
        ;   rsp+56: arg rowCursor
        ;   rsp+48: arg columnCursor
        ;   rsp+0: var row.1
        ;   rsp+2: var row.2
        ;   rsp+4: var column.1
        ;   rsp+6: var column.2
        ;   rsp+8: var spacer.1
        ;   rsp+16: var t.7.1
        ;   rsp+24: var row.4
        ;   rsp+26: var spacer.2
        ;   rsp+27: var cell.1
        ;   rsp+28: var column.3
_printField@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; call setCursor@i16@i16[0, 0]
        mov  rax, 0
        push rax
        mov  rax, 0
        push rax
        sub rsp, 8
          call _setCursor@i16@i16
        add rsp, 24
        ; const row.1, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 97:2 for row < 20
        ; move row.2, row.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        jmp _for_18
_for_18_body:
        ; call printChar@u8[124]
        mov  rax, 124
        push rax
          call _printChar@u8
        add rsp, 8
        ; const column.1, 0
        mov ax, 0
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 99:3 for column < 40
        ; move column.2, column.1
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        jmp _for_19
_for_19_body:
        ; call spacer.2 = getSpacer@i16@i16@i16@i16[row.2, column.2, rowCursor, columnCursor] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getSpacer@i16@i16@i16@i16
        add rsp, 40
        lea rbx, [rsp+26]
        mov [rbx], al
        ; call printChar@u8[spacer.2]
        lea rax, [rsp+26]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; call cell.1 = getCell@i16@i16[row.2, column.2] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+27]
        mov [rbx], al
        ; call printCell@u8@i16@i16[cell.1, row.2, column.2]
        lea rax, [rsp+27]
        mov bl, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+22]
        mov bx, [rax]
        push rbx
          call _printCell@u8@i16@i16
        add rsp, 24
        ; move column.3, column.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov [rax], bx
        ; add column.3, column.3, 1
        lea rax, [rsp+28]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+28]
        mov [rax], bx
        ; move column.2, column.3
        lea rax, [rsp+28]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
_for_19:
        ; branch column.2 lt 40: for_19_body, for_19_break
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 40
        jl _for_19_body
        ; call spacer.1 = getSpacer@i16@i16@i16@i16[row.2, 40, rowCursor, columnCursor] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        mov  rax, 40
        push rax
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+72]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getSpacer@i16@i16@i16@i16
        add rsp, 40
        lea rbx, [rsp+8]
        mov [rbx], al
        ; call printChar@u8[spacer.1]
        lea rax, [rsp+8]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; const t.7.1, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call printString@@u8[t.7.1]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; move row.4, row.2
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; add row.4, row.4, 1
        lea rax, [rsp+24]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+24]
        mov [rax], bx
        ; move row.2, row.4
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
_for_18:
        ; branch row.2 lt 20: for_18_body, printField@i16@i16_ret
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 20
        jl _for_18_body
        ; release space for local variables
        add rsp, 32
        ret

        ; void printSpaces@i16
        ;   rsp+24: arg i
        ;   rsp+0: var i.1
        ;   rsp+2: var i.2
_printSpaces@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; move i.1, i
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov [rax], bx
        jmp _for_20
_for_20_body:
        ; call printChar@u8[48]
        mov  rax, 48
        push rax
          call _printChar@u8
        add rsp, 8
        ; move i.2, i.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; sub i.2, i.2, 1
        lea rax, [rsp+2]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+2]
        mov [rax], bx
        ; move i.1, i.2
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov [rax], bx
_for_20:
        ; branch i.1 gt 0: for_20_body, printSpaces@i16_ret
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 0
        jg _for_20_body
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getDigitCount@i16
        ;   rsp+24: arg value
        ;   rsp+0: var count.1
        ;   rsp+2: var value.1
        ;   rsp+4: var count.2
        ;   rsp+5: var count.3
        ;   rsp+6: var value.2
        ;   rsp+8: var value.3
        ;   rsp+10: var count.4
        ;   rsp+11: var count.5
        ;   rsp+12: var value.4
_getDigitCount@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const count.1, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 119:2 if value < 0
        ; branch value lt 0: if_21_then, getDigitCount@i16.no_critical_edge_6
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 0
        jl _if_21_then
        ; move value.1, value
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; move count.2, count.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        jmp _if_21_end
_if_21_then:
        ; const count.3, 1
        mov al, 1
        lea rbx, [rsp+5]
        mov [rbx], al
        ; neg value.2, value
        lea rax, [rsp+24]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+6]
        mov [rax], bx
        ; move value.1, value.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; move count.2, count.3
        lea rax, [rsp+5]
        mov bl, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
_if_21_end:
        ; move value.3, value.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov [rax], bx
        ; move count.4, count.2
        lea rax, [rsp+4]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov [rax], bl
        jmp _while_22
_getDigitCount@i16.no_critical_edge_7:
        ; move value.3, value.4
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov [rax], bx
        ; move count.4, count.5
        lea rax, [rsp+11]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov [rax], bl
_while_22:
        ; move count.5, count.4
        lea rax, [rsp+10]
        mov bl, [rax]
        lea rax, [rsp+11]
        mov [rax], bl
        ; add count.5, count.5, 1
        lea rax, [rsp+11]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+11]
        mov [rax], bl
        ; move value.4, value.3
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov [rax], bx
        ; div value.4, value.4, 10
        lea rax, [rsp+12]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+12]
        mov [rcx], bx
        ; 127:3 if value == 0
        ; branch value.4 notequals 0: getDigitCount@i16.no_critical_edge_7, while_22_break
        lea rax, [rsp+12]
        mov bx, [rax]
        cmp bx, 0
        jne _getDigitCount@i16.no_critical_edge_7
        ; 132:9 return count
        ; ret count.5
        lea rax, [rsp+11]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; i16 getHiddenCount
        ;   rsp+0: var count.1
        ;   rsp+2: var r.1
        ;   rsp+4: var count.2
        ;   rsp+6: var r.2
        ;   rsp+8: var c.1
        ;   rsp+10: var count.3
        ;   rsp+12: var c.2
        ;   rsp+14: var r.4
        ;   rsp+16: var cell.1
        ;   rsp+17: var t.4.1
        ;   rsp+18: var count.4
        ;   rsp+20: var count.5
        ;   rsp+22: var c.4
_getHiddenCount:
        ; reserve space for local variables
        sub rsp, 32
        ; const count.1, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const r.1, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 137:2 for r < 20
        ; move count.2, count.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; move r.2, r.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        jmp _for_24
_for_24_body:
        ; const c.1, 0
        mov ax, 0
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; 138:3 for c < 40
        ; move count.3, count.2
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov [rax], bx
        ; move c.2, c.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov [rax], bx
        jmp _for_25
_for_25_body:
        ; call cell.1 = getCell@i16@i16[r.2, c.2] -> u8
        lea rax, [rsp+6]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+16]
        mov [rbx], al
        ; 140:4 if cell & 6 == 0
        ; move t.4.1, cell.1
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
        ; and t.4.1, t.4.1, 6
        lea rax, [rsp+17]
        mov bl, [rax]
        and bl, 6
        lea rax, [rsp+17]
        mov [rax], bl
        ; branch t.4.1 equals 0: if_26_then, getHiddenCount.no_critical_edge_10
        lea rax, [rsp+17]
        mov bl, [rax]
        cmp bl, 0
        je _if_26_then
        ; move count.4, count.3
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        jmp _for_25_continue
_if_26_then:
        ; move count.5, count.3
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        ; add count.5, count.5, 1
        lea rax, [rsp+20]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+20]
        mov [rax], bx
        ; move count.4, count.5
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
_for_25_continue:
        ; move c.4, c.2
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+22]
        mov [rax], bx
        ; add c.4, c.4, 1
        lea rax, [rsp+22]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+22]
        mov [rax], bx
        ; move count.3, count.4
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov [rax], bx
        ; move c.2, c.4
        lea rax, [rsp+22]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov [rax], bx
_for_25:
        ; branch c.2 lt 40: for_25_body, for_24_continue
        lea rax, [rsp+12]
        mov bx, [rax]
        cmp bx, 40
        jl _for_25_body
        ; move r.4, r.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov [rax], bx
        ; add r.4, r.4, 1
        lea rax, [rsp+14]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+14]
        mov [rax], bx
        ; move count.2, count.3
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; move r.2, r.4
        lea rax, [rsp+14]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
_for_24:
        ; branch r.2 lt 20: for_24_body, for_24_break
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 20
        jl _for_24_body
        ; 145:9 return count
        ; ret count.2
        lea rax, [rsp+4]
        mov bx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 32
        ret

        ; bool printLeft
        ;   rsp+0: var count.1
        ;   rsp+2: var t.3.1
        ;   rsp+4: var leftDigits.1
        ;   rsp+6: var t.4.1
        ;   rsp+8: var bombDigits.1
        ;   rsp+10: var t.5.1
        ;   rsp+12: var t.6.1
_printLeft:
        ; reserve space for local variables
        sub rsp, 16
        ; call count.1 = getHiddenCount[] -> i16
        sub rsp, 8
          call _getHiddenCount
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; call t.3.1 = getDigitCount@i16[count.1] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call _getDigitCount@i16
        add rsp, 8
        lea rbx, [rsp+2]
        mov [rbx], al
        ; cast leftDigits.1(i16), t.3.1(u8)
        lea rax, [rsp+2]
        mov bl, [rax]
        movzx bx, bl
        lea rax, [rsp+4]
        mov [rax], bx
        ; call t.4.1 = getDigitCount@i16[40] -> u8
        mov  rax, 40
        push rax
          call _getDigitCount@i16
        add rsp, 8
        lea rbx, [rsp+6]
        mov [rbx], al
        ; cast bombDigits.1(i16), t.4.1(u8)
        lea rax, [rsp+6]
        mov bl, [rax]
        movzx bx, bl
        lea rax, [rsp+8]
        mov [rax], bx
        ; call setCursor@i16@i16[20, 6]
        mov  rax, 20
        push rax
        mov  rax, 6
        push rax
        sub rsp, 8
          call _setCursor@i16@i16
        add rsp, 24
        ; move t.5.1, bombDigits.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov [rax], bx
        ; sub t.5.1, t.5.1, leftDigits.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+10]
        mov [rax], bx
        ; call printSpaces@i16[t.5.1]
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
          call _printSpaces@i16
        add rsp, 8
        ; call printUint@i16[count.1]
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call _printUint@i16
        add rsp, 8
        ; 156:15 return count == 0
        ; equals t.6.1, count.1, 0
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 0
        sete bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; ret t.6.1
        lea rax, [rsp+12]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; i16 abs@i16
        ;   rsp+24: arg a
        ;   rsp+0: var t.1.1
_abs@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; branch a lt 0: if_27_then, if_27_end
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 0
        jl _if_27_then
        ; 163:9 return a
        ; ret a
        lea rax, [rsp+24]
        mov bx, [rax]
        mov rax, rbx
        jmp _abs@i16_ret
_if_27_then:
        ; 161:10 return -a
        ; neg t.1.1, a
        lea rax, [rsp+24]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+0]
        mov [rax], bx
        ; ret t.1.1
        lea rax, [rsp+0]
        mov bx, [rax]
        mov rax, rbx
_abs@i16_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void clearField
        ;   rsp+0: var r.1
        ;   rsp+2: var r.2
        ;   rsp+4: var c.1
        ;   rsp+6: var c.2
        ;   rsp+8: var r.4
        ;   rsp+10: var c.3
_clearField:
        ; reserve space for local variables
        sub rsp, 16
        ; const r.1, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 167:2 for r < 20
        ; move r.2, r.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        jmp _for_28
_for_28_body:
        ; const c.1, 0
        mov ax, 0
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 168:3 for c < 40
        ; move c.2, c.1
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        jmp _for_29
_for_29_body:
        ; call setCell@i16@i16@u8[r.2, c.2, 0]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        mov  rax, 0
        push rax
          call _setCell@i16@i16@u8
        add rsp, 24
        ; move c.3, c.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov [rax], bx
        ; add c.3, c.3, 1
        lea rax, [rsp+10]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+10]
        mov [rax], bx
        ; move c.2, c.3
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
_for_29:
        ; branch c.2 lt 40: for_29_body, for_28_continue
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 40
        jl _for_29_body
        ; move r.4, r.2
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov [rax], bx
        ; add r.4, r.4, 1
        lea rax, [rsp+8]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+8]
        mov [rax], bx
        ; move r.2, r.4
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
_for_28:
        ; branch r.2 lt 20: for_28_body, clearField_ret
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 20
        jl _for_28_body
        ; release space for local variables
        add rsp, 16
        ret

        ; void initField@i16@i16
        ;   rsp+72: arg curr_r
        ;   rsp+64: arg curr_c
        ;   rsp+0: var bombs.1
        ;   rsp+2: var bombs.2
        ;   rsp+4: var t.6.1
        ;   rsp+8: var t.5.1
        ;   rsp+12: var row.1
        ;   rsp+16: var t.8.1
        ;   rsp+20: var t.7.1
        ;   rsp+24: var column.1
        ;   rsp+26: var t.10.1
        ;   rsp+28: var t.9.1
        ;   rsp+30: var t.12.1
        ;   rsp+32: var t.11.1
        ;   rsp+34: var bombs.5
_initField@i16@i16:
        ; reserve space for local variables
        sub rsp, 48
        ; const bombs.1, 40
        mov ax, 40
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 175:2 for bombs > 0
        ; move bombs.2, bombs.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        jmp _for_30
_for_30_body:
        ; call t.6.1 = random[] -> i32
        sub rsp, 8
          call _random
        add rsp, 8
        lea rbx, [rsp+4]
        mov [rbx], eax
        ; move t.5.1, t.6.1
        lea rax, [rsp+4]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mod t.5.1, t.5.1, 20
        lea rax, [rsp+8]
        mov ebx, [rax]
        movsxd rax, ebx
        mov rcx, 20
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+8]
        mov [rcx], ebx
        ; cast row.1(i16), t.5.1(i32)
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], bx
        ; call t.8.1 = random[] -> i32
        sub rsp, 8
          call _random
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], eax
        ; move t.7.1, t.8.1
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov [rax], ebx
        ; mod t.7.1, t.7.1, 40
        lea rax, [rsp+20]
        mov ebx, [rax]
        movsxd rax, ebx
        mov rcx, 40
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+20]
        mov [rcx], ebx
        ; cast column.1(i16), t.7.1(i32)
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; move t.10.1, row.1
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+26]
        mov [rax], bx
        ; sub t.10.1, t.10.1, curr_r
        lea rax, [rsp+26]
        mov bx, [rax]
        lea rax, [rsp+72]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+26]
        mov [rax], bx
        ; call t.9.1 = abs@i16[t.10.1] -> i16
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
          call _abs@i16
        add rsp, 8
        lea rbx, [rsp+28]
        mov [rbx], ax
        ; branch t.9.1 gt 1: if_31_then, @or_32
        lea rax, [rsp+28]
        mov bx, [rax]
        cmp bx, 1
        jg _if_31_then
        ; move t.12.1, column.1
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+30]
        mov [rax], bx
        ; sub t.12.1, t.12.1, curr_c
        lea rax, [rsp+30]
        mov bx, [rax]
        lea rax, [rsp+64]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+30]
        mov [rax], bx
        ; call t.11.1 = abs@i16[t.12.1] -> i16
        lea rax, [rsp+30]
        mov bx, [rax]
        push rbx
          call _abs@i16
        add rsp, 8
        lea rbx, [rsp+32]
        mov [rbx], ax
        ; branch t.11.1 lteq 1: for_30_continue, if_31_then
        lea rax, [rsp+32]
        mov bx, [rax]
        cmp bx, 1
        jle _for_30_continue
_if_31_then:
        ; call setCell@i16@i16@u8[row.1, column.1, 1]
        lea rax, [rsp+12]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        mov  rax, 1
        push rax
          call _setCell@i16@i16@u8
        add rsp, 24
_for_30_continue:
        ; move bombs.5, bombs.2
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+34]
        mov [rax], bx
        ; sub bombs.5, bombs.5, 1
        lea rax, [rsp+34]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+34]
        mov [rax], bx
        ; move bombs.2, bombs.5
        lea rax, [rsp+34]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
_for_30:
        ; branch bombs.2 gt 0: for_30_body, initField@i16@i16_ret
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 0
        jg _for_30_body
        ; release space for local variables
        add rsp, 48
        ret

        ; void maybeRevealAround@i16@i16
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var t.7.1
        ;   rsp+2: var dr.1
        ;   rsp+4: var dr.2
        ;   rsp+6: var r.1
        ;   rsp+8: var dc.1
        ;   rsp+10: var dc.2
        ;   rsp+12: var dr.4
        ;   rsp+14: var c.1
        ;   rsp+16: var t.8.1
        ;   rsp+17: var cell.1
        ;   rsp+18: var t.9.1
        ;   rsp+20: var dc.5
        ;   rsp+22: var t.10.1
_maybeRevealAround@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; call t.7.1 = getBombCountAround@i16@i16[row, column] -> u8
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getBombCountAround@i16@i16
        add rsp, 24
        lea rbx, [rsp+0]
        mov [rbx], al
        ; branch t.7.1 notequals 0: maybeRevealAround@i16@i16_ret, if_33_end
        lea rax, [rsp+0]
        mov bl, [rax]
        cmp bl, 0
        jne _maybeRevealAround@i16@i16_ret
        ; const dr.1, -1
        mov ax, -1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 190:2 for dr <= 1
        ; move dr.2, dr.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        jmp _for_34
_for_34_body:
        ; move r.1, row
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        ; add r.1, r.1, dr.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+6]
        mov [rax], bx
        ; const dc.1, -1
        mov ax, -1
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; 192:3 for dc <= 1
        ; move dc.2, dc.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov [rax], bx
        jmp _for_35
_for_35_body:
        ; branch dr.2 notequals 0: if_36_end, @and_37
        lea rax, [rsp+4]
        mov bx, [rax]
        cmp bx, 0
        jne _if_36_end
        ; branch dc.2 equals 0: for_35_continue, if_36_end
        lea rax, [rsp+10]
        mov bx, [rax]
        cmp bx, 0
        je _for_35_continue
_if_36_end:
        ; move c.1, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov [rax], bx
        ; add c.1, c.1, dc.2
        lea rax, [rsp+14]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+14]
        mov [rax], bx
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; call t.8.1 = checkCellBounds@i16@i16[r.1, c.1] -> bool
        lea rax, [rsp+6]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+22]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _checkCellBounds@i16@i16
        add rsp, 24
        lea rbx, [rsp+16]
        mov [rbx], al
        ; branch t.8.1 equals 0: for_35_continue, if_38_end
        lea rax, [rsp+16]
        mov bl, [rax]
        cmp bl, 0
        je _for_35_continue
        ; call cell.1 = getCell@i16@i16[r.1, c.1] -> u8
        lea rax, [rsp+6]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+22]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+17]
        mov [rbx], al
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; call t.9.1 = isOpen@u8[cell.1] -> bool
        lea rax, [rsp+17]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+18]
        mov [rbx], al
        ; branch t.9.1 notequals 0: for_35_continue, if_39_end
        lea rax, [rsp+18]
        mov bl, [rax]
        cmp bl, 0
        jne _for_35_continue
        ; move t.10.1, cell.1
        lea rax, [rsp+17]
        mov bl, [rax]
        lea rax, [rsp+22]
        mov [rax], bl
        ; or t.10.1, t.10.1, 2
        lea rax, [rsp+22]
        mov bl, [rax]
        or bl, 2
        lea rax, [rsp+22]
        mov [rax], bl
        ; call setCell@i16@i16@u8[r.1, c.1, t.10.1]
        lea rax, [rsp+6]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+22]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+38]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
        ; call maybeRevealAround@i16@i16[r.1, c.1]
        lea rax, [rsp+6]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+22]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _maybeRevealAround@i16@i16
        add rsp, 24
_for_35_continue:
        ; move dc.5, dc.2
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        ; add dc.5, dc.5, 1
        lea rax, [rsp+20]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+20]
        mov [rax], bx
        ; move dc.2, dc.5
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov [rax], bx
_for_35:
        ; branch dc.2 lteq 1: for_35_body, for_34_continue
        lea rax, [rsp+10]
        mov bx, [rax]
        cmp bx, 1
        jle _for_35_body
        ; move dr.4, dr.2
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+12]
        mov [rax], bx
        ; add dr.4, dr.4, 1
        lea rax, [rsp+12]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+12]
        mov [rax], bx
        ; move dr.2, dr.4
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
_for_34:
        ; branch dr.2 lteq 1: for_34_body, maybeRevealAround@i16@i16_ret
        lea rax, [rsp+4]
        mov bx, [rax]
        cmp bx, 1
        jle _for_34_body
_maybeRevealAround@i16@i16_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void main
        ;   rsp+0: var needsInitialize.1
        ;   rsp+2: var curr_c.1
        ;   rsp+4: var curr_r.1
        ;   rsp+8: var t.6.1
        ;   rsp+16: var needsInitialize.2
        ;   rsp+18: var curr_c.2
        ;   rsp+20: var curr_r.2
        ;   rsp+22: var t.7.1
        ;   rsp+24: var chr.1
        ;   rsp+32: var t.8.1
        ;   rsp+40: var t.10.1
        ;   rsp+42: var t.9.1
        ;   rsp+44: var curr_r.4
        ;   rsp+46: var t.11.1
        ;   rsp+48: var curr_r.5
        ;   rsp+50: var t.13.1
        ;   rsp+52: var t.12.1
        ;   rsp+54: var curr_c.4
        ;   rsp+56: var t.14.1
        ;   rsp+58: var curr_c.5
        ;   rsp+60: var cell.1
        ;   rsp+61: var t.15.1
        ;   rsp+62: var needsInitialize.4
        ;   rsp+63: var needsInitialize.5
        ;   rsp+64: var cell.2
        ;   rsp+65: var cell.3
        ;   rsp+66: var t.16.1
        ;   rsp+67: var t.17.1
        ;   rsp+68: var t.18.1
        ;   rsp+72: var t.19.1
        ;   rsp+80: var a.__random__
        ;   rsp+88: var t.__random__
_main:
        ; reserve space for local variables
        sub rsp, 96
        ; begin initialize global variables
        ; const t.__random__, 0
        mov eax, 0
        lea rbx, [rsp+88]
        mov [rbx], eax
        ; addrof a.__random__, __random__
        lea rax, [var_0]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; store [a.__random__], t.__random__
        lea rax, [rsp+80]
        mov rbx, [rax]
        lea rax, [rsp+88]
        mov ecx, [rax]
        mov [rbx], ecx
        ; end initialize global variables
        ; call initRandom@i32[7439742]
        mov  rax, 7439742
        push rax
          call _initRandom@i32
        add rsp, 8
        ; const needsInitialize.1, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; call clearField[]
        sub rsp, 8
          call _clearField
        add rsp, 8
        ; const curr_c.1, 20
        mov ax, 20
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; const curr_r.1, 10
        mov ax, 10
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; call setCursor@i16@i16[20, 0]
        mov  rax, 20
        push rax
        mov  rax, 0
        push rax
        sub rsp, 8
          call _setCursor@i16@i16
        add rsp, 24
        ; const t.6.1, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; call printString@@u8[t.6.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; 221:2 while true
        ; move needsInitialize.2, needsInitialize.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.1
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_41_then:
        ; 224:4 if printLeft([])
        ; call t.7.1 = printLeft[] -> bool
        sub rsp, 8
          call _printLeft
        add rsp, 8
        lea rbx, [rsp+22]
        mov [rbx], al
        ; branch t.7.1 notequals 0: if_42_then, if_41_end
        lea rax, [rsp+22]
        mov bl, [rax]
        cmp bl, 0
        jne _if_42_then
_if_41_end:
        ; call chr.1 = getChar[] -> i16
        sub rsp, 8
          call _getChar
        add rsp, 8
        lea rbx, [rsp+24]
        mov [rbx], ax
        ; 231:3 if chr == 27
        ; branch chr.1 equals 27: main_ret, if_43_end
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 27
        je _main_ret
        ; branch chr.1 equals -8120: if_44_then, if_44_else
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, -8120
        je _if_44_then
        ; branch chr.1 notequals -8112: if_45_else, if_45_then
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, -8112
        jne _if_45_else
        jmp _if_45_then
_if_44_then:
        ; move t.10.1, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; add t.10.1, t.10.1, 20
        lea rax, [rsp+40]
        mov bx, [rax]
        add bx, 20
        lea rax, [rsp+40]
        mov [rax], bx
        ; move t.9.1, t.10.1
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+42]
        mov [rax], bx
        ; sub t.9.1, t.9.1, 1
        lea rax, [rsp+42]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+42]
        mov [rax], bx
        ; move curr_r.4, t.9.1
        lea rax, [rsp+42]
        mov bx, [rax]
        lea rax, [rsp+44]
        mov [rax], bx
        ; mod curr_r.4, curr_r.4, 20
        lea rax, [rsp+44]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 20
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+44]
        mov [rcx], bx
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.4
        lea rax, [rsp+44]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_45_else:
        ; branch chr.1 notequals -8117: if_46_else, if_46_then
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, -8117
        jne _if_46_else
        jmp _if_46_then
_if_45_then:
        ; move t.11.1, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov [rax], bx
        ; add t.11.1, t.11.1, 1
        lea rax, [rsp+46]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+46]
        mov [rax], bx
        ; move curr_r.5, t.11.1
        lea rax, [rsp+46]
        mov bx, [rax]
        lea rax, [rsp+48]
        mov [rax], bx
        ; mod curr_r.5, curr_r.5, 20
        lea rax, [rsp+48]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 20
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+48]
        mov [rcx], bx
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.5
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_46_else:
        ; branch chr.1 notequals -8115: if_47_else, if_47_then
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, -8115
        jne _if_47_else
        jmp _if_47_then
_if_46_then:
        ; move t.13.1, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+50]
        mov [rax], bx
        ; add t.13.1, t.13.1, 40
        lea rax, [rsp+50]
        mov bx, [rax]
        add bx, 40
        lea rax, [rsp+50]
        mov [rax], bx
        ; move t.12.1, t.13.1
        lea rax, [rsp+50]
        mov bx, [rax]
        lea rax, [rsp+52]
        mov [rax], bx
        ; sub t.12.1, t.12.1, 1
        lea rax, [rsp+52]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+52]
        mov [rax], bx
        ; move curr_c.4, t.12.1
        lea rax, [rsp+52]
        mov bx, [rax]
        lea rax, [rsp+54]
        mov [rax], bx
        ; mod curr_c.4, curr_c.4, 40
        lea rax, [rsp+54]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 40
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+54]
        mov [rcx], bx
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.4
        lea rax, [rsp+54]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_47_else:
        ; branch chr.1 notequals 32: if_48_else, if_48_then
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 32
        jne _if_48_else
        jmp _if_48_then
_if_47_then:
        ; move t.14.1, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov [rax], bx
        ; add t.14.1, t.14.1, 1
        lea rax, [rsp+56]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+56]
        mov [rax], bx
        ; move curr_c.5, t.14.1
        lea rax, [rsp+56]
        mov bx, [rax]
        lea rax, [rsp+58]
        mov [rax], bx
        ; mod curr_c.5, curr_c.5, 40
        lea rax, [rsp+58]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 40
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+58]
        mov [rcx], bx
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.5
        lea rax, [rsp+58]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_48_else:
        ; branch chr.1 notequals 13: main.no_critical_edge_28, if_51_then
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 13
        jne _main.no_critical_edge_28
        jmp _if_51_then
_if_48_then:
        ; branch needsInitialize.2 notequals 0: main.no_critical_edge_31, if_49_then
        lea rax, [rsp+16]
        mov bl, [rax]
        cmp bl, 0
        jne _main.no_critical_edge_31
        jmp _if_49_then
_main.no_critical_edge_28:
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_51_then:
        ; branch needsInitialize.2 equals 0: main.no_critical_edge_29, if_52_then
        lea rax, [rsp+16]
        mov bl, [rax]
        cmp bl, 0
        je _main.no_critical_edge_29
        jmp _if_52_then
_main.no_critical_edge_31:
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_49_then:
        ; call cell.1 = getCell@i16@i16[curr_r.2, curr_c.2] -> u8
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+60]
        mov [rbx], al
        ; 255:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=255:17]])
        ; call t.15.1 = isOpen@u8[cell.1] -> bool
        lea rax, [rsp+60]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+61]
        mov [rbx], al
        ; branch t.15.1 notequals 0: main.no_critical_edge_32, if_50_then
        lea rax, [rsp+61]
        mov bl, [rax]
        cmp bl, 0
        jne _main.no_critical_edge_32
        jmp _if_50_then
_main.no_critical_edge_29:
        ; move needsInitialize.4, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+62]
        mov [rax], bl
        jmp _if_52_end
_if_52_then:
        ; const needsInitialize.5, 0
        mov al, 0
        lea rbx, [rsp+63]
        mov [rbx], al
        ; call initField@i16@i16[curr_r.2, curr_c.2]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _initField@i16@i16
        add rsp, 24
        ; move needsInitialize.4, needsInitialize.5
        lea rax, [rsp+63]
        mov bl, [rax]
        lea rax, [rsp+62]
        mov [rax], bl
        jmp _if_52_end
_main.no_critical_edge_32:
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_50_then:
        ; move cell.2, cell.1
        lea rax, [rsp+60]
        mov bl, [rax]
        lea rax, [rsp+64]
        mov [rax], bl
        ; xor cell.2, cell.2, 4
        lea rax, [rsp+64]
        mov bl, [rax]
        xor bl, 4
        lea rax, [rsp+64]
        mov [rax], bl
        ; call setCell@i16@i16@u8[curr_r.2, curr_c.2, cell.2]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+80]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
        ; move needsInitialize.2, needsInitialize.2
        lea rax, [rsp+16]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
        jmp _while_40
_if_52_end:
        ; call cell.3 = getCell@i16@i16[curr_r.2, curr_c.2] -> u8
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+65]
        mov [rbx], al
        ; 267:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=267:16]])
        ; call t.16.1 = isOpen@u8[cell.3] -> bool
        lea rax, [rsp+65]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+66]
        mov [rbx], al
        ; branch t.16.1 notequals 0: if_53_end, if_53_then
        lea rax, [rsp+66]
        mov bl, [rax]
        cmp bl, 0
        jne _if_53_end
        ; move t.17.1, cell.3
        lea rax, [rsp+65]
        mov bl, [rax]
        lea rax, [rsp+67]
        mov [rax], bl
        ; or t.17.1, t.17.1, 2
        lea rax, [rsp+67]
        mov bl, [rax]
        or bl, 2
        lea rax, [rsp+67]
        mov [rax], bl
        ; call setCell@i16@i16@u8[curr_r.2, curr_c.2, t.17.1]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+83]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
_if_53_end:
        ; 270:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=270:15]])
        ; call t.18.1 = isBomb@u8[cell.3] -> bool
        lea rax, [rsp+65]
        mov bl, [rax]
        push rbx
          call _isBomb@u8
        add rsp, 8
        lea rbx, [rsp+68]
        mov [rbx], al
        ; branch t.18.1 notequals 0: if_54_then, if_54_end
        lea rax, [rsp+68]
        mov bl, [rax]
        cmp bl, 0
        jne _if_54_then
        ; call maybeRevealAround@i16@i16[curr_r.2, curr_c.2]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _maybeRevealAround@i16@i16
        add rsp, 24
        ; move needsInitialize.2, needsInitialize.4
        lea rax, [rsp+62]
        mov bl, [rax]
        lea rax, [rsp+16]
        mov [rax], bl
        ; move curr_c.2, curr_c.2
        lea rax, [rsp+18]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; move curr_r.2, curr_r.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+20]
        mov [rax], bx
_while_40:
        ; call printField@i16@i16[curr_r.2, curr_c.2]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _printField@i16@i16
        add rsp, 24
        ; 223:3 if !needsInitialize
        ; branch needsInitialize.2 notequals 0: if_41_end, if_41_then
        lea rax, [rsp+16]
        mov bl, [rax]
        cmp bl, 0
        jne _if_41_end
        jmp _if_41_then
_if_42_then:
        ; const t.8.1, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call printString@@u8[t.8.1]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        jmp _main_ret
_if_54_then:
        ; call printField@i16@i16[curr_r.2, curr_c.2]
        lea rax, [rsp+20]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+26]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _printField@i16@i16
        add rsp, 24
        ; const t.19.1, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+72]
        mov [rbx], rax
        ; call printString@@u8[t.19.1]
        lea rax, [rsp+72]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
_main_ret:
        ; release space for local variables
        add rsp, 96
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
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
_getChar:
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
_setCursor@i16@i16:
        mov     rdi, rsp
        and     spl, 0xf0

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     dx, [rdi+18h]
        shl     rdx, 16
        mov     dx, [rdi+10h]
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
        string_1 db 'Left:', 0x00
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
