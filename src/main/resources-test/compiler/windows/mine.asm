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
        ;   rsp+0: var length
_printString@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; call length = strlen@@u8[str] -> i64
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _strlen@@u8
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
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
_printChar@u8:
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
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1
_printUint@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printUint@i64[t.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printUint@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint@i64
        ;   rsp+104: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+64: var t.9
        ;   rsp+72: var t.10
        ;   rsp+80: var t.11
        ;   rsp+81: var t.12
_printUint@i64:
        ; reserve space for local variables
        sub rsp, 96
        ; const pos, 20
        mov al, 20
        lea rbx, [rsp+20]
        mov [rbx], al
        ; 28:2 while true
_while_1:
        ; sub pos, pos, 1
        lea rax, [rsp+20]
        mov bl, [rax]
        sub bl, 1
        lea rax, [rsp+20]
        mov [rax], bl
        ; move remainder, number
        lea rax, [rsp+104]
        mov rbx, [rax]
        lea rax, [rsp+24]
        mov [rax], rbx
        ; mod remainder, remainder, 10
        lea rax, [rsp+24]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+24]
        mov [rcx], rbx
        ; div number, number, 10
        lea rax, [rsp+104]
        mov rbx, [rax]
        mov rax, rbx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+104]
        mov [rcx], rbx
        ; cast t.5(u8), remainder(i64)
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+33]
        mov [rax], bl
        ; move digit, t.5
        lea rax, [rsp+33]
        mov bl, [rax]
        lea rax, [rsp+32]
        mov [rax], bl
        ; add digit, digit, 48
        lea rax, [rsp+32]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+32]
        mov [rax], bl
        ; cast t.7(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+48]
        mov [rax], rbx
        ; addrof t.6, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+40]
        mov [rbx], rax
        ; add t.6, t.6, t.7
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+48]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+40]
        mov [rax], rbx
        ; store [t.6], digit
        lea rax, [rsp+40]
        mov rbx, [rax]
        lea rax, [rsp+32]
        mov cl, [rax]
        mov [rbx], cl
        ; 34:3 if number == 0
        ; equals t.8, number, 0
        lea rax, [rsp+104]
        mov rbx, [rax]
        cmp rbx, 0
        sete bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; branch t.8, false, while_1, while_1_break
        lea rax, [rsp+56]
        mov bl, [rax]
        or bl, bl
        jz _while_1
        ; cast t.10(i64), pos(u8)
        lea rax, [rsp+20]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+72]
        mov [rax], rbx
        ; addrof t.9, [buffer]
        lea rax, [rsp+0]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; add t.9, t.9, t.10
        lea rax, [rsp+64]
        mov rbx, [rax]
        lea rax, [rsp+72]
        mov rcx, [rax]
        add rbx, rcx
        lea rax, [rsp+64]
        mov [rax], rbx
        ; const t.12, 20
        mov al, 20
        lea rbx, [rsp+81]
        mov [rbx], al
        ; move t.11, t.12
        lea rax, [rsp+81]
        mov bl, [rax]
        lea rax, [rsp+80]
        mov [rax], bl
        ; sub t.11, t.11, pos
        lea rax, [rsp+80]
        mov bl, [rax]
        lea rax, [rsp+20]
        mov cl, [rax]
        sub bl, cl
        lea rax, [rsp+80]
        mov [rax], bl
        ; call printStringLength@@u8@u8[t.9, t.11]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
        lea rax, [rsp+88]
        mov bl, [rax]
        push rbx
        sub rsp, 8
          call _printStringLength@@u8@u8
        add rsp, 24
        ; release space for local variables
        add rsp, 96
        ret

        ; i64 strlen@@u8
        ;   rsp+24: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
_strlen@@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; const length, 0
        mov rax, 0
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; 64:2 for *str != 0
        jmp _for_3
_for_3_body:
        ; add length, length, 1
        lea rax, [rsp+0]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+0]
        mov [rax], rbx
        ; add str, str, 1
        lea rax, [rsp+24]
        mov rbx, [rax]
        add rbx, 1
        lea rax, [rsp+24]
        mov [rax], rbx
_for_3:
        ; load t.3, [str]
        lea rax, [rsp+24]
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
        ; branch t.2, true, for_3_body, for_3_break
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz _for_3_body
        ; 67:9 return length
        ; ret length
        lea rax, [rsp+0]
        mov rbx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+40: arg str
        ;   rsp+32: arg length
        ;   rsp+0: var t.2
_printStringLength@@u8@u8:
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
          call _printStringLength@@u8@i64
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void initRandom@i32
        ;   rsp+8: arg salt
_initRandom@i32:
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
_random:
        ; reserve space for local variables
        sub rsp, 48
        ; move r, __random__
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+0]
        mov [rax], ebx
        ; move t.5, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+20]
        mov [rax], ebx
        ; and t.5, t.5, 524287
        lea rax, [rsp+20]
        mov ebx, [rax]
        and ebx, 524287
        lea rax, [rsp+20]
        mov [rax], ebx
        ; move b, t.5
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], ebx
        ; mul b, b, 48271
        lea rax, [rsp+4]
        mov ebx, [rax]
        movsxd rbx, ebx
        imul  rbx, 48271
        lea rax, [rsp+4]
        mov [rax], ebx
        ; move t.6, r
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+24]
        mov [rax], ebx
        ; shiftright t.6, t.6, 15
        lea rax, [rsp+24]
        mov ebx, [rax]
        sar ebx, 15
        lea rax, [rsp+24]
        mov [rax], ebx
        ; move c, t.6
        lea rax, [rsp+24]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mul c, c, 48271
        lea rax, [rsp+8]
        mov ebx, [rax]
        movsxd rbx, ebx
        imul  rbx, 48271
        lea rax, [rsp+8]
        mov [rax], ebx
        ; move t.7, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+28]
        mov [rax], ebx
        ; and t.7, t.7, 65535
        lea rax, [rsp+28]
        mov ebx, [rax]
        and ebx, 65535
        lea rax, [rsp+28]
        mov [rax], ebx
        ; move d, t.7
        lea rax, [rsp+28]
        mov ebx, [rax]
        lea rax, [rsp+12]
        mov [rax], ebx
        ; shiftleft d, d, 15
        lea rax, [rsp+12]
        mov ebx, [rax]
        sal ebx, 15
        lea rax, [rsp+12]
        mov [rax], ebx
        ; move t.9, c
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+36]
        mov [rax], ebx
        ; shiftright t.9, t.9, 16
        lea rax, [rsp+36]
        mov ebx, [rax]
        sar ebx, 16
        lea rax, [rsp+36]
        mov [rax], ebx
        ; move t.8, t.9
        lea rax, [rsp+36]
        mov ebx, [rax]
        lea rax, [rsp+32]
        mov [rax], ebx
        ; add t.8, t.8, b
        lea rax, [rsp+32]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [rsp+32]
        mov [rax], ebx
        ; move e, t.8
        lea rax, [rsp+32]
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
        ; move t.10, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+40]
        mov [rax], ebx
        ; and t.10, t.10, 2147483647
        lea rax, [rsp+40]
        mov ebx, [rax]
        and ebx, 2147483647
        lea rax, [rsp+40]
        mov [rax], ebx
        ; move t.11, e
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov [rax], ebx
        ; shiftright t.11, t.11, 31
        lea rax, [rsp+44]
        mov ebx, [rax]
        sar ebx, 31
        lea rax, [rsp+44]
        mov [rax], ebx
        ; move __random__, t.10
        lea rax, [rsp+40]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ; add __random__, __random__, t.11
        lea rax, [var_0]
        mov ebx, [rax]
        lea rax, [rsp+44]
        mov ecx, [rax]
        add ebx, ecx
        lea rax, [var_0]
        mov [rax], ebx
        ; 15:9 return __random__
        ; ret __random__
        lea rax, [var_0]
        mov ebx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 48
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
_rowColumnToCell@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 16:21 return row * 40 + column
        ; move t.3, row
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mul t.3, t.3, 40
        lea rax, [rsp+2]
        mov bx, [rax]
        movsx rbx, bx
        imul  rbx, 40
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
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var t.2
        ;   rsp+8: var t.3
        ;   rsp+16: var t.4
        ;   rsp+24: var t.5
_getCell@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; 20:15 return [...]
        ; call t.5 = rowColumnToCell@i16@i16[row, column] -> i16
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _rowColumnToCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+24]
        mov [rbx], ax
        ; cast t.4(i64), t.5(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+16]
        mov [rax], rbx
        ; addrof t.3, [field]
        lea rax, [var_1]
        lea rbx, [rsp+8]
        mov [rbx], rax
        ; add t.3, t.3, t.4
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+16]
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
        add rsp, 32
        ret

        ; bool isBomb@u8
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
_isBomb@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 24:27 return cell & 1 != 0
        ; move t.2, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        ; and t.2, t.2, 1
        lea rax, [rsp+1]
        mov bl, [rax]
        and bl, 1
        lea rax, [rsp+1]
        mov [rax], bl
        ; notequals t.1, t.2, 0
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
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
_isOpen@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 28:27 return cell & 2 != 0
        ; move t.2, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        ; and t.2, t.2, 2
        lea rax, [rsp+1]
        mov bl, [rax]
        and bl, 2
        lea rax, [rsp+1]
        mov [rax], bl
        ; notequals t.1, t.2, 0
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
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
_isFlag@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; 32:27 return cell & 4 != 0
        ; move t.2, cell
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        ; and t.2, t.2, 4
        lea rax, [rsp+1]
        mov bl, [rax]
        and bl, 4
        lea rax, [rsp+1]
        mov [rax], bl
        ; notequals t.1, t.2, 0
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
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
_checkCellBounds@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; gteq t.2, row, 0
        lea rax, [rsp+40]
        mov bx, [rax]
        cmp bx, 0
        setge bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.2, false, and_next_6, and_2nd_6
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz _and_next_6
        ; lt t.2, row, 20
        lea rax, [rsp+40]
        mov bx, [rax]
        cmp bx, 20
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
_and_next_6:
        ; branch t.2, false, and_next_5, and_2nd_5
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz _and_next_5
        ; gteq t.2, column, 0
        lea rax, [rsp+32]
        mov bx, [rax]
        cmp bx, 0
        setge bl
        lea rax, [rsp+0]
        mov [rax], bl
_and_next_5:
        ; branch t.2, false, and_next_4, and_2nd_4
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz _and_next_4
        ; lt t.2, column, 40
        lea rax, [rsp+32]
        mov bx, [rax]
        cmp bx, 40
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
_and_next_4:
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
_setCell@i16@i16@u8:
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
          call _rowColumnToCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+16]
        mov [rbx], ax
        ; cast t.4(i64), t.5(i16)
        lea rax, [rsp+16]
        mov bx, [rax]
        movsx rbx, bx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; addrof t.3, [field]
        lea rax, [var_1]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; add t.3, t.3, t.4
        lea rax, [rsp+0]
        mov rbx, [rax]
        lea rax, [rsp+8]
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
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var count
        ;   rsp+2: var dr
        ;   rsp+4: var r
        ;   rsp+6: var dc
        ;   rsp+8: var c
        ;   rsp+10: var cell
        ;   rsp+11: var t.8
        ;   rsp+12: var t.9
        ;   rsp+13: var t.10
        ;   rsp+14: var t.11
_getBombCountAround@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const count, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; const dr, -1
        mov ax, -1
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 46:2 for dr <= 1
        jmp _for_7
_for_7_body:
        ; move r, row
        lea rax, [rsp+40]
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
        ; 48:3 for dc <= 1
        jmp _for_8
_for_8_body:
        ; move c, column
        lea rax, [rsp+32]
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
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; call t.10 = checkCellBounds@i16@i16[r, c] -> bool
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _checkCellBounds@i16@i16
        add rsp, 24
        lea rbx, [rsp+13]
        mov [rbx], al
        ; branch t.10, false, for_8_continue, if_9_then
        lea rax, [rsp+13]
        mov bl, [rax]
        or bl, bl
        jz _for_8_continue
        ; call cell = getCell@i16@i16[r, c] -> u8
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+10]
        mov [rbx], al
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; call t.11 = isBomb@u8[cell] -> bool
        lea rax, [rsp+10]
        mov bl, [rax]
        push rbx
          call _isBomb@u8
        add rsp, 8
        lea rbx, [rsp+14]
        mov [rbx], al
        ; branch t.11, false, for_8_continue, if_10_then
        lea rax, [rsp+14]
        mov bl, [rax]
        or bl, bl
        jz _for_8_continue
        ; add count, count, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
_for_8_continue:
        ; add dc, dc, 1
        lea rax, [rsp+6]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+6]
        mov [rax], bx
_for_8:
        ; lteq t.9, dc, 1
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 1
        setle bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.9, true, for_8_body, for_7_continue
        lea rax, [rsp+12]
        mov bl, [rax]
        or bl, bl
        jnz _for_8_body
        ; add dr, dr, 1
        lea rax, [rsp+2]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+2]
        mov [rax], bx
_for_7:
        ; lteq t.8, dr, 1
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 1
        setle bl
        lea rax, [rsp+11]
        mov [rax], bl
        ; branch t.8, true, for_7_body, for_7_break
        lea rax, [rsp+11]
        mov bl, [rax]
        or bl, bl
        jnz _for_7_body
        ; 58:9 return count
        ; ret count
        lea rax, [rsp+0]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
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
        ;   rsp+7: var t.10
_getSpacer@i16@i16@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 62:2 if rowCursor == row
        ; equals t.4, rowCursor, row
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+56]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.4, false, if_11_end, if_11_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz _if_11_end
        ; 63:3 if columnCursor == column
        ; equals t.5, columnCursor, column
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+48]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.5, true, if_12_then, if_12_end
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jnz _if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.8, column
        lea rax, [rsp+48]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; sub t.8, t.8, 1
        lea rax, [rsp+4]
        mov bx, [rax]
        sub bx, 1
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
        ; branch t.7, false, if_11_end, if_13_then
        lea rax, [rsp+3]
        mov bl, [rax]
        or bl, bl
        jz _if_11_end
        jmp _if_13_then
_if_12_then:
        ; 64:11 return 91
        ; const t.6, 91
        mov al, 91
        lea rbx, [rsp+2]
        mov [rbx], al
        ; ret t.6
        lea rax, [rsp+2]
        mov bl, [rax]
        mov rax, rbx
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_13_then:
        ; 67:11 return 93
        ; const t.9, 93
        mov al, 93
        lea rbx, [rsp+6]
        mov [rbx], al
        ; ret t.9
        lea rax, [rsp+6]
        mov bl, [rax]
        mov rax, rbx
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_11_end:
        ; 70:9 return 32
        ; const t.10, 32
        mov al, 32
        lea rbx, [rsp+7]
        mov [rbx], al
        ; ret t.10
        lea rax, [rsp+7]
        mov bl, [rax]
        mov rax, rbx
_getSpacer@i16@i16@i16@i16_ret:
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
_printCell@u8@i16@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const chr, 46
        mov al, 46
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; call t.5 = isOpen@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+2]
        mov [rbx], al
        ; branch t.5, true, if_14_then, if_14_else
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jnz _if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; call t.8 = isFlag@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _isFlag@u8
        add rsp, 8
        lea rbx, [rsp+5]
        mov [rbx], al
        ; branch t.8, false, if_14_end, if_17_then
        lea rax, [rsp+5]
        mov bl, [rax]
        or bl, bl
        jz _if_14_end
        jmp _if_17_then
_if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; call t.6 = isBomb@u8[cell] -> bool
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _isBomb@u8
        add rsp, 8
        lea rbx, [rsp+3]
        mov [rbx], al
        ; branch t.6, false, if_15_else, if_15_then
        lea rax, [rsp+3]
        mov bl, [rax]
        or bl, bl
        jz _if_15_else
        jmp _if_15_then
_if_17_then:
        ; const chr, 35
        mov al, 35
        lea rbx, [rsp+0]
        mov [rbx], al
        jmp _if_14_end
_if_15_else:
        ; call count = getBombCountAround@i16@i16[row, column] -> u8
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getBombCountAround@i16@i16
        add rsp, 24
        lea rbx, [rsp+1]
        mov [rbx], al
        ; 81:4 if count > 0
        ; gt t.7, count, 0
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 0
        seta bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.7, false, if_16_else, if_16_then
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jz _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr, 42
        mov al, 42
        lea rbx, [rsp+0]
        mov [rbx], al
        jmp _if_14_end
_if_16_else:
        ; const chr, 32
        mov al, 32
        lea rbx, [rsp+0]
        mov [rbx], al
        jmp _if_14_end
_if_16_then:
        ; move chr, count
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+0]
        mov [rax], bl
        ; add chr, chr, 48
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 48
        lea rax, [rsp+0]
        mov [rax], bl
_if_14_end:
        ; call printChar@u8[chr]
        lea rax, [rsp+0]
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
        ;   rsp+0: var row
        ;   rsp+2: var column
        ;   rsp+4: var spacer
        ;   rsp+5: var cell
        ;   rsp+6: var spacer
        ;   rsp+8: var t.7
        ;   rsp+10: var t.8
        ;   rsp+12: var t.9
        ;   rsp+13: var t.10
        ;   rsp+14: var t.11
        ;   rsp+16: var t.12
        ;   rsp+24: var t.13
_printField@i16@i16:
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
          call _setCursor@i16@i16
        add rsp, 24
        ; const row, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 97:2 for row < 20
        jmp _for_18
_for_18_body:
        ; const t.10, 124
        mov al, 124
        lea rbx, [rsp+13]
        mov [rbx], al
        ; call printChar@u8[t.10]
        lea rax, [rsp+13]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; const column, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 99:3 for column < 40
        jmp _for_19
_for_19_body:
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
          call _getSpacer@i16@i16@i16@i16
        add rsp, 40
        lea rbx, [rsp+4]
        mov [rbx], al
        ; call printChar@u8[spacer]
        lea rax, [rsp+4]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; call cell = getCell@i16@i16[row, column] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
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
          call _printCell@u8@i16@i16
        add rsp, 24
        ; add column, column, 1
        lea rax, [rsp+2]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+2]
        mov [rax], bx
_for_19:
        ; lt t.11, column, 40
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 40
        setl bl
        lea rax, [rsp+14]
        mov [rax], bl
        ; branch t.11, true, for_19_body, for_19_break
        lea rax, [rsp+14]
        mov bl, [rax]
        or bl, bl
        jnz _for_19_body
        ; const t.12, 40
        mov ax, 40
        lea rbx, [rsp+16]
        mov [rbx], ax
        ; call spacer = getSpacer@i16@i16@i16@i16[row, t.12, rowCursor, columnCursor] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+24]
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
        lea rbx, [rsp+6]
        mov [rbx], al
        ; call printChar@u8[spacer]
        lea rax, [rsp+6]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; const t.13, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.13]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; add row, row, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+0]
        mov [rax], bx
_for_18:
        ; lt t.9, row, 20
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 20
        setl bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.9, true, for_18_body, printField@i16@i16_ret
        lea rax, [rsp+12]
        mov bl, [rax]
        or bl, bl
        jnz _for_18_body
        ; release space for local variables
        add rsp, 32
        ret

        ; void printSpaces@i16
        ;   rsp+24: arg i
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
_printSpaces@i16:
        ; reserve space for local variables
        sub rsp, 16
        jmp _for_20
_for_20_body:
        ; const t.2, 48
        mov al, 48
        lea rbx, [rsp+1]
        mov [rbx], al
        ; call printChar@u8[t.2]
        lea rax, [rsp+1]
        mov bl, [rax]
        push rbx
          call _printChar@u8
        add rsp, 8
        ; sub i, i, 1
        lea rax, [rsp+24]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+24]
        mov [rax], bx
_for_20:
        ; gt t.1, i, 0
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 0
        setg bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, true, for_20_body, printSpaces@i16_ret
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jnz _for_20_body
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getDigitCount@i16
        ;   rsp+24: arg value
        ;   rsp+0: var count
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
_getDigitCount@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; const count, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 119:2 if value < 0
        ; lt t.2, value, 0
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 0
        setl bl
        lea rax, [rsp+1]
        mov [rax], bl
        ; branch t.2, false, while_22, if_21_then
        lea rax, [rsp+1]
        mov bl, [rax]
        or bl, bl
        jz _while_22
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
_while_22:
        ; add count, count, 1
        lea rax, [rsp+0]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+0]
        mov [rax], bl
        ; div value, value, 10
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 10
        cqo
        idiv rcx
        mov rbx, rax
        lea rcx, [rsp+24]
        mov [rcx], bx
        ; 127:3 if value == 0
        ; equals t.3, value, 0
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 0
        sete bl
        lea rax, [rsp+2]
        mov [rax], bl
        ; branch t.3, false, while_22, while_22_break
        lea rax, [rsp+2]
        mov bl, [rax]
        or bl, bl
        jz _while_22
        ; 132:9 return count
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
        ;   rsp+9: var t.6
        ;   rsp+10: var t.7
_getHiddenCount:
        ; reserve space for local variables
        sub rsp, 16
        ; const count, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; const r, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 137:2 for r < 20
        jmp _for_24
_for_24_body:
        ; const c, 0
        mov ax, 0
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 138:3 for c < 40
        jmp _for_25
_for_25_body:
        ; call cell = getCell@i16@i16[r, c] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+12]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+6]
        mov [rbx], al
        ; 140:4 if cell & 6 == 0
        ; move t.7, cell
        lea rax, [rsp+6]
        mov bl, [rax]
        lea rax, [rsp+10]
        mov [rax], bl
        ; and t.7, t.7, 6
        lea rax, [rsp+10]
        mov bl, [rax]
        and bl, 6
        lea rax, [rsp+10]
        mov [rax], bl
        ; equals t.6, t.7, 0
        lea rax, [rsp+10]
        mov bl, [rax]
        cmp bl, 0
        sete bl
        lea rax, [rsp+9]
        mov [rax], bl
        ; branch t.6, false, for_25_continue, if_26_then
        lea rax, [rsp+9]
        mov bl, [rax]
        or bl, bl
        jz _for_25_continue
        ; add count, count, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+0]
        mov [rax], bx
_for_25_continue:
        ; add c, c, 1
        lea rax, [rsp+4]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+4]
        mov [rax], bx
_for_25:
        ; lt t.5, c, 40
        lea rax, [rsp+4]
        mov bx, [rax]
        cmp bx, 40
        setl bl
        lea rax, [rsp+8]
        mov [rax], bl
        ; branch t.5, true, for_25_body, for_24_continue
        lea rax, [rsp+8]
        mov bl, [rax]
        or bl, bl
        jnz _for_25_body
        ; add r, r, 1
        lea rax, [rsp+2]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+2]
        mov [rax], bx
_for_24:
        ; lt t.4, r, 20
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 20
        setl bl
        lea rax, [rsp+7]
        mov [rax], bl
        ; branch t.4, true, for_24_body, for_24_break
        lea rax, [rsp+7]
        mov bl, [rax]
        or bl, bl
        jnz _for_24_body
        ; 145:9 return count
        ; ret count
        lea rax, [rsp+0]
        mov bx, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
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
_printLeft:
        ; reserve space for local variables
        sub rsp, 32
        ; call count = getHiddenCount[] -> i16
        sub rsp, 8
          call _getHiddenCount
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; call t.3 = getDigitCount@i16[count] -> u8
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call _getDigitCount@i16
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
          call _getDigitCount@i16
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
          call _printString@@u8
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
          call _printSpaces@i16
        add rsp, 8
        ; call printUint@i16[count]
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
          call _printUint@i16
        add rsp, 8
        ; 156:15 return count == 0
        ; equals t.8, count, 0
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 0
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
_abs@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; 160:2 if a < 0
        ; lt t.1, a, 0
        lea rax, [rsp+24]
        mov bx, [rax]
        cmp bx, 0
        setl bl
        lea rax, [rsp+0]
        mov [rax], bl
        ; branch t.1, true, if_27_then, if_27_end
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jnz _if_27_then
        ; 163:9 return a
        ; ret a
        lea rax, [rsp+24]
        mov bx, [rax]
        mov rax, rbx
        jmp _abs@i16_ret
_if_27_then:
        ; 161:10 return -a
        ; neg t.2, a
        lea rax, [rsp+24]
        mov bx, [rax]
        neg rbx
        lea rax, [rsp+2]
        mov [rax], bx
        ; ret t.2
        lea rax, [rsp+2]
        mov bx, [rax]
        mov rax, rbx
_abs@i16_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void clearField
        ;   rsp+0: var r
        ;   rsp+2: var c
        ;   rsp+4: var t.2
        ;   rsp+5: var t.3
        ;   rsp+6: var t.4
_clearField:
        ; reserve space for local variables
        sub rsp, 16
        ; const r, 0
        mov ax, 0
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 167:2 for r < 20
        jmp _for_28
_for_28_body:
        ; const c, 0
        mov ax, 0
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; 168:3 for c < 40
        jmp _for_29
_for_29_body:
        ; const t.4, 0
        mov al, 0
        lea rbx, [rsp+6]
        mov [rbx], al
        ; call setCell@i16@i16@u8[r, c, t.4]
        lea rax, [rsp+0]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+22]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
        ; add c, c, 1
        lea rax, [rsp+2]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+2]
        mov [rax], bx
_for_29:
        ; lt t.3, c, 40
        lea rax, [rsp+2]
        mov bx, [rax]
        cmp bx, 40
        setl bl
        lea rax, [rsp+5]
        mov [rax], bl
        ; branch t.3, true, for_29_body, for_28_continue
        lea rax, [rsp+5]
        mov bl, [rax]
        or bl, bl
        jnz _for_29_body
        ; add r, r, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+0]
        mov [rax], bx
_for_28:
        ; lt t.2, r, 20
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 20
        setl bl
        lea rax, [rsp+4]
        mov [rax], bl
        ; branch t.2, true, for_28_body, clearField_ret
        lea rax, [rsp+4]
        mov bl, [rax]
        or bl, bl
        jnz _for_28_body
        ; release space for local variables
        add rsp, 16
        ret

        ; void initField@i16@i16
        ;   rsp+72: arg curr_r
        ;   rsp+64: arg curr_c
        ;   rsp+0: var bombs
        ;   rsp+2: var row
        ;   rsp+4: var column
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
        ;   rsp+12: var t.7
        ;   rsp+16: var t.8
        ;   rsp+20: var t.9
        ;   rsp+24: var t.10
        ;   rsp+26: var t.11
        ;   rsp+28: var t.12
        ;   rsp+30: var t.13
        ;   rsp+32: var t.14
        ;   rsp+34: var t.15
_initField@i16@i16:
        ; reserve space for local variables
        sub rsp, 48
        ; const bombs, 40
        mov ax, 40
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 175:2 for bombs > 0
        jmp _for_30
_for_30_body:
        ; call t.7 = random[] -> i32
        sub rsp, 8
          call _random
        add rsp, 8
        lea rbx, [rsp+12]
        mov [rbx], eax
        ; move t.6, t.7
        lea rax, [rsp+12]
        mov ebx, [rax]
        lea rax, [rsp+8]
        mov [rax], ebx
        ; mod t.6, t.6, 20
        lea rax, [rsp+8]
        mov ebx, [rax]
        movsxd rax, ebx
        mov rcx, 20
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+8]
        mov [rcx], ebx
        ; cast row(i16), t.6(i32)
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; call t.9 = random[] -> i32
        sub rsp, 8
          call _random
        add rsp, 8
        lea rbx, [rsp+20]
        mov [rbx], eax
        ; move t.8, t.9
        lea rax, [rsp+20]
        mov ebx, [rax]
        lea rax, [rsp+16]
        mov [rax], ebx
        ; mod t.8, t.8, 40
        lea rax, [rsp+16]
        mov ebx, [rax]
        movsxd rax, ebx
        mov rcx, 40
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+16]
        mov [rcx], ebx
        ; cast column(i16), t.8(i32)
        lea rax, [rsp+16]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; 179:4 logic or
        ; move t.12, row
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov [rax], bx
        ; sub t.12, t.12, curr_r
        lea rax, [rsp+28]
        mov bx, [rax]
        lea rax, [rsp+72]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+28]
        mov [rax], bx
        ; call t.11 = abs@i16[t.12] -> i16
        lea rax, [rsp+28]
        mov bx, [rax]
        push rbx
          call _abs@i16
        add rsp, 8
        lea rbx, [rsp+26]
        mov [rbx], ax
        ; gt t.10, t.11, 1
        lea rax, [rsp+26]
        mov bx, [rax]
        cmp bx, 1
        setg bl
        lea rax, [rsp+24]
        mov [rax], bl
        ; branch t.10, true, or_next_32, or_2nd_32
        lea rax, [rsp+24]
        mov bl, [rax]
        or bl, bl
        jnz _or_next_32
        ; move t.14, column
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+32]
        mov [rax], bx
        ; sub t.14, t.14, curr_c
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+64]
        mov cx, [rax]
        sub bx, cx
        lea rax, [rsp+32]
        mov [rax], bx
        ; call t.13 = abs@i16[t.14] -> i16
        lea rax, [rsp+32]
        mov bx, [rax]
        push rbx
          call _abs@i16
        add rsp, 8
        lea rbx, [rsp+30]
        mov [rbx], ax
        ; gt t.10, t.13, 1
        lea rax, [rsp+30]
        mov bx, [rax]
        cmp bx, 1
        setg bl
        lea rax, [rsp+24]
        mov [rax], bl
_or_next_32:
        ; branch t.10, false, for_30_continue, if_31_then
        lea rax, [rsp+24]
        mov bl, [rax]
        or bl, bl
        jz _for_30_continue
        ; const t.15, 1
        mov al, 1
        lea rbx, [rsp+34]
        mov [rbx], al
        ; call setCell@i16@i16@u8[row, column, t.15]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+12]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+50]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
_for_30_continue:
        ; sub bombs, bombs, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+0]
        mov [rax], bx
_for_30:
        ; gt t.5, bombs, 0
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 0
        setg bl
        lea rax, [rsp+6]
        mov [rax], bl
        ; branch t.5, true, for_30_body, initField@i16@i16_ret
        lea rax, [rsp+6]
        mov bl, [rax]
        or bl, bl
        jnz _for_30_body
        ; release space for local variables
        add rsp, 48
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
        ;   rsp+13: var t.11
        ;   rsp+14: var t.12
        ;   rsp+15: var t.13
        ;   rsp+16: var t.14
        ;   rsp+17: var t.15
_maybeRevealAround@i16@i16:
        ; reserve space for local variables
        sub rsp, 32
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; call t.8 = getBombCountAround@i16@i16[row, column] -> u8
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+56]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getBombCountAround@i16@i16
        add rsp, 24
        lea rbx, [rsp+10]
        mov [rbx], al
        ; notequals t.7, t.8, 0
        lea rax, [rsp+10]
        mov bl, [rax]
        cmp bl, 0
        setne bl
        lea rax, [rsp+9]
        mov [rax], bl
        ; branch t.7, true, maybeRevealAround@i16@i16_ret, if_33_end
        lea rax, [rsp+9]
        mov bl, [rax]
        or bl, bl
        jnz _maybeRevealAround@i16@i16_ret
        ; const dr, -1
        mov ax, -1
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; 190:2 for dr <= 1
        jmp _for_34
_for_34_body:
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
        ; 192:3 for dc <= 1
        jmp _for_35
_for_35_body:
        ; 193:4 if dr == 0 && dc == 0
        ; 193:16 logic and
        ; equals t.11, dr, 0
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 0
        sete bl
        lea rax, [rsp+13]
        mov [rax], bl
        ; branch t.11, false, and_next_37, and_2nd_37
        lea rax, [rsp+13]
        mov bl, [rax]
        or bl, bl
        jz _and_next_37
        ; equals t.11, dc, 0
        lea rax, [rsp+4]
        mov bx, [rax]
        cmp bx, 0
        sete bl
        lea rax, [rsp+13]
        mov [rax], bl
_and_next_37:
        ; branch t.11, true, for_35_continue, if_36_end
        lea rax, [rsp+13]
        mov bl, [rax]
        or bl, bl
        jnz _for_35_continue
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
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; call t.13 = checkCellBounds@i16@i16[r, c] -> bool
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _checkCellBounds@i16@i16
        add rsp, 24
        lea rbx, [rsp+15]
        mov [rbx], al
        ; notlog t.12, t.13
        lea rax, [rsp+15]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+14]
        mov [rax], bl
        ; branch t.12, true, for_35_continue, if_38_end
        lea rax, [rsp+14]
        mov bl, [rax]
        or bl, bl
        jnz _for_35_continue
        ; call cell = getCell@i16@i16[r, c] -> u8
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+8]
        mov [rbx], al
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; call t.14 = isOpen@u8[cell] -> bool
        lea rax, [rsp+8]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+16]
        mov [rbx], al
        ; branch t.14, true, for_35_continue, if_39_end
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jnz _for_35_continue
        ; move t.15, cell
        lea rax, [rsp+8]
        mov bl, [rax]
        lea rax, [rsp+17]
        mov [rax], bl
        ; or t.15, t.15, 2
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, 2
        lea rax, [rsp+17]
        mov [rax], bl
        ; call setCell@i16@i16@u8[r, c, t.15]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+33]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
        ; call maybeRevealAround@i16@i16[r, c]
        lea rax, [rsp+2]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+14]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _maybeRevealAround@i16@i16
        add rsp, 24
_for_35_continue:
        ; add dc, dc, 1
        lea rax, [rsp+4]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+4]
        mov [rax], bx
_for_35:
        ; lteq t.10, dc, 1
        lea rax, [rsp+4]
        mov bx, [rax]
        cmp bx, 1
        setle bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; branch t.10, true, for_35_body, for_34_continue
        lea rax, [rsp+12]
        mov bl, [rax]
        or bl, bl
        jnz _for_35_body
        ; add dr, dr, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+0]
        mov [rax], bx
_for_34:
        ; lteq t.9, dr, 1
        lea rax, [rsp+0]
        mov bx, [rax]
        cmp bx, 1
        setle bl
        lea rax, [rsp+11]
        mov [rax], bl
        ; branch t.9, true, for_34_body, maybeRevealAround@i16@i16_ret
        lea rax, [rsp+11]
        mov bl, [rax]
        or bl, bl
        jnz _for_34_body
_maybeRevealAround@i16@i16_ret:
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
        ;   rsp+33: var t.11
        ;   rsp+34: var t.12
        ;   rsp+36: var t.13
        ;   rsp+38: var t.14
        ;   rsp+40: var t.15
        ;   rsp+42: var t.16
        ;   rsp+44: var t.17
        ;   rsp+46: var t.18
        ;   rsp+48: var t.19
        ;   rsp+50: var t.20
        ;   rsp+52: var t.21
        ;   rsp+53: var t.22
        ;   rsp+54: var t.23
        ;   rsp+55: var t.24
        ;   rsp+56: var t.25
        ;   rsp+57: var t.26
        ;   rsp+58: var t.27
        ;   rsp+59: var t.28
        ;   rsp+60: var t.29
        ;   rsp+64: var t.30
_main:
        ; reserve space for local variables
        sub rsp, 80
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
          call _initRandom@i32
        add rsp, 8
        ; const needsInitialize, 1
        mov al, 1
        lea rbx, [rsp+0]
        mov [rbx], al
        ; call clearField[]
        sub rsp, 8
          call _clearField
        add rsp, 8
        ; const curr_c, 20
        mov ax, 20
        lea rbx, [rsp+2]
        mov [rbx], ax
        ; const curr_r, 10
        mov ax, 10
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; 219:2 while true
        jmp _while_40
_if_41_then:
        ; 222:4 if printLeft([])
        ; call t.8 = printLeft[] -> bool
        sub rsp, 8
          call _printLeft
        add rsp, 8
        lea rbx, [rsp+17]
        mov [rbx], al
        ; branch t.8, true, if_42_then, if_41_end
        lea rax, [rsp+17]
        mov bl, [rax]
        or bl, bl
        jnz _if_42_then
_if_41_end:
        ; call chr = getChar[] -> i16
        sub rsp, 8
          call _getChar
        add rsp, 8
        lea rbx, [rsp+6]
        mov [rbx], ax
        ; 229:3 if chr == 27
        ; equals t.10, chr, 27
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 27
        sete bl
        lea rax, [rsp+32]
        mov [rax], bl
        ; branch t.10, true, main_ret, if_43_end
        lea rax, [rsp+32]
        mov bl, [rax]
        or bl, bl
        jnz _main_ret
        ; 234:3 if chr == -8120
        ; equals t.11, chr, -8120
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, -8120
        sete bl
        lea rax, [rsp+33]
        mov [rax], bl
        ; branch t.11, true, if_44_then, if_44_else
        lea rax, [rsp+33]
        mov bl, [rax]
        or bl, bl
        jnz _if_44_then
        ; 238:8 if chr == -8112
        ; equals t.14, chr, -8112
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, -8112
        sete bl
        lea rax, [rsp+38]
        mov [rax], bl
        ; branch t.14, false, if_45_else, if_45_then
        lea rax, [rsp+38]
        mov bl, [rax]
        or bl, bl
        jz _if_45_else
        jmp _if_45_then
_if_44_then:
        ; move t.13, curr_r
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+36]
        mov [rax], bx
        ; add t.13, t.13, 20
        lea rax, [rsp+36]
        mov bx, [rax]
        add bx, 20
        lea rax, [rsp+36]
        mov [rax], bx
        ; move t.12, t.13
        lea rax, [rsp+36]
        mov bx, [rax]
        lea rax, [rsp+34]
        mov [rax], bx
        ; sub t.12, t.12, 1
        lea rax, [rsp+34]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+34]
        mov [rax], bx
        ; move curr_r, t.12
        lea rax, [rsp+34]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; mod curr_r, curr_r, 20
        lea rax, [rsp+4]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 20
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+4]
        mov [rcx], bx
        jmp _while_40
_if_45_else:
        ; 242:8 if chr == -8117
        ; equals t.16, chr, -8117
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, -8117
        sete bl
        lea rax, [rsp+42]
        mov [rax], bl
        ; branch t.16, false, if_46_else, if_46_then
        lea rax, [rsp+42]
        mov bl, [rax]
        or bl, bl
        jz _if_46_else
        jmp _if_46_then
_if_45_then:
        ; move t.15, curr_r
        lea rax, [rsp+4]
        mov bx, [rax]
        lea rax, [rsp+40]
        mov [rax], bx
        ; add t.15, t.15, 1
        lea rax, [rsp+40]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+40]
        mov [rax], bx
        ; move curr_r, t.15
        lea rax, [rsp+40]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov [rax], bx
        ; mod curr_r, curr_r, 20
        lea rax, [rsp+4]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 20
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+4]
        mov [rcx], bx
        jmp _while_40
_if_46_else:
        ; 246:8 if chr == -8115
        ; equals t.19, chr, -8115
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, -8115
        sete bl
        lea rax, [rsp+48]
        mov [rax], bl
        ; branch t.19, false, if_47_else, if_47_then
        lea rax, [rsp+48]
        mov bl, [rax]
        or bl, bl
        jz _if_47_else
        jmp _if_47_then
_if_46_then:
        ; move t.18, curr_c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+46]
        mov [rax], bx
        ; add t.18, t.18, 40
        lea rax, [rsp+46]
        mov bx, [rax]
        add bx, 40
        lea rax, [rsp+46]
        mov [rax], bx
        ; move t.17, t.18
        lea rax, [rsp+46]
        mov bx, [rax]
        lea rax, [rsp+44]
        mov [rax], bx
        ; sub t.17, t.17, 1
        lea rax, [rsp+44]
        mov bx, [rax]
        sub bx, 1
        lea rax, [rsp+44]
        mov [rax], bx
        ; move curr_c, t.17
        lea rax, [rsp+44]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mod curr_c, curr_c, 40
        lea rax, [rsp+2]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 40
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+2]
        mov [rcx], bx
        jmp _while_40
_if_47_else:
        ; 250:8 if chr == 32
        ; equals t.21, chr, 32
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 32
        sete bl
        lea rax, [rsp+52]
        mov [rax], bl
        ; branch t.21, false, if_48_else, if_48_then
        lea rax, [rsp+52]
        mov bl, [rax]
        or bl, bl
        jz _if_48_else
        jmp _if_48_then
_if_47_then:
        ; move t.20, curr_c
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+50]
        mov [rax], bx
        ; add t.20, t.20, 1
        lea rax, [rsp+50]
        mov bx, [rax]
        add bx, 1
        lea rax, [rsp+50]
        mov [rax], bx
        ; move curr_c, t.20
        lea rax, [rsp+50]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mod curr_c, curr_c, 40
        lea rax, [rsp+2]
        mov bx, [rax]
        movsx rax, bx
        mov rcx, 40
        cqo
        idiv rcx
        mov rbx, rdx
        lea rcx, [rsp+2]
        mov [rcx], bx
        jmp _while_40
_if_48_else:
        ; 259:8 if chr == 13
        ; equals t.25, chr, 13
        lea rax, [rsp+6]
        mov bx, [rax]
        cmp bx, 13
        sete bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; branch t.25, false, while_40, if_51_then
        lea rax, [rsp+56]
        mov bl, [rax]
        or bl, bl
        jz _while_40
        jmp _if_51_then
_if_48_then:
        ; 251:4 if !needsInitialize
        ; notlog t.22, needsInitialize
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+53]
        mov [rax], bl
        ; branch t.22, false, while_40, if_49_then
        lea rax, [rsp+53]
        mov bl, [rax]
        or bl, bl
        jz _while_40
        jmp _if_49_then
_if_51_then:
        ; branch needsInitialize, false, if_52_end, if_52_then
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        jz _if_52_end
        jmp _if_52_then
_if_49_then:
        ; call cell = getCell@i16@i16[curr_r, curr_c] -> u8
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+8]
        mov [rbx], al
        ; 253:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=253:17]])
        ; call t.24 = isOpen@u8[cell] -> bool
        lea rax, [rsp+8]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+55]
        mov [rbx], al
        ; notlog t.23, t.24
        lea rax, [rsp+55]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+54]
        mov [rax], bl
        ; branch t.23, false, while_40, if_50_then
        lea rax, [rsp+54]
        mov bl, [rax]
        or bl, bl
        jz _while_40
        jmp _if_50_then
_if_52_then:
        ; const needsInitialize, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; call initField@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _initField@i16@i16
        add rsp, 24
        jmp _if_52_end
_if_50_then:
        ; xor cell, cell, 4
        lea rax, [rsp+8]
        mov bl, [rax]
        xor bl, 4
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
          call _setCell@i16@i16@u8
        add rsp, 24
        jmp _while_40
_if_52_end:
        ; call cell = getCell@i16@i16[curr_r, curr_c] -> u8
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _getCell@i16@i16
        add rsp, 24
        lea rbx, [rsp+9]
        mov [rbx], al
        ; 265:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=265:16]])
        ; call t.27 = isOpen@u8[cell] -> bool
        lea rax, [rsp+9]
        mov bl, [rax]
        push rbx
          call _isOpen@u8
        add rsp, 8
        lea rbx, [rsp+58]
        mov [rbx], al
        ; notlog t.26, t.27
        lea rax, [rsp+58]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+57]
        mov [rax], bl
        ; branch t.26, false, if_53_end, if_53_then
        lea rax, [rsp+57]
        mov bl, [rax]
        or bl, bl
        jz _if_53_end
        ; move t.28, cell
        lea rax, [rsp+9]
        mov bl, [rax]
        lea rax, [rsp+59]
        mov [rax], bl
        ; or t.28, t.28, 2
        lea rax, [rsp+59]
        mov bl, [rax]
        or bl, 2
        lea rax, [rsp+59]
        mov [rax], bl
        ; call setCell@i16@i16@u8[curr_r, curr_c, t.28]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+75]
        mov bl, [rax]
        push rbx
          call _setCell@i16@i16@u8
        add rsp, 24
_if_53_end:
        ; 268:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:15]])
        ; call t.29 = isBomb@u8[cell] -> bool
        lea rax, [rsp+9]
        mov bl, [rax]
        push rbx
          call _isBomb@u8
        add rsp, 8
        lea rbx, [rsp+60]
        mov [rbx], al
        ; branch t.29, true, if_54_then, if_54_end
        lea rax, [rsp+60]
        mov bl, [rax]
        or bl, bl
        jnz _if_54_then
        ; call maybeRevealAround@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _maybeRevealAround@i16@i16
        add rsp, 24
_while_40:
        ; call printField@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _printField@i16@i16
        add rsp, 24
        ; 221:3 if !needsInitialize
        ; notlog t.7, needsInitialize
        lea rax, [rsp+0]
        mov bl, [rax]
        or bl, bl
        sete bl
        lea rax, [rsp+16]
        mov [rax], bl
        ; branch t.7, false, if_41_end, if_41_then
        lea rax, [rsp+16]
        mov bl, [rax]
        or bl, bl
        jz _if_41_end
        jmp _if_41_then
_if_42_then:
        ; const t.9, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+24]
        mov [rbx], rax
        ; call printString@@u8[t.9]
        lea rax, [rsp+24]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        jmp _main_ret
_if_54_then:
        ; call printField@i16@i16[curr_r, curr_c]
        lea rax, [rsp+4]
        mov bx, [rax]
        push rbx
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
        sub rsp, 8
          call _printField@i16@i16
        add rsp, 24
        ; const t.30, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; call printString@@u8[t.30]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
_main_ret:
        ; release space for local variables
        add rsp, 80
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
