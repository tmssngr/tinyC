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

        ; void printIntLf@bool
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printIntLf@bool:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(bool)
        lea rax, [rsp+24]
        mov bl, [rax]
        movzx rbx, bl
        lea rax, [rsp+0]
        mov [rax], rbx
        ; call printIntLf@i64[t.1.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printIntLf@i64
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printIntLf@i64
        ;   rsp+24: arg number
        ;   rsp+0: var number.1
        ;   rsp+8: var number.2
_printIntLf@i64:
        ; reserve space for local variables
        sub rsp, 16
        ; branch number lt 0: if_3_then, printIntLf@i64.no_critical_edge_4
        lea rax, [rsp+24]
        mov rbx, [rax]
        cmp rbx, 0
        jl _if_3_then
        ; move number.1, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        lea rax, [rsp+0]
        mov [rax], rbx
        jmp _if_3_end
_if_3_then:
        ; call printChar@u8[45]
        mov  rax, 45
        push rax
          call _printChar@u8
        add rsp, 8
        ; neg number.2, number
        lea rax, [rsp+24]
        mov rbx, [rax]
        neg rbx
        lea rax, [rsp+8]
        mov [rax], rbx
        ; move number.1, number.2
        lea rax, [rsp+8]
        mov rbx, [rax]
        lea rax, [rsp+0]
        mov [rax], rbx
_if_3_end:
        ; call printUint@i64[number.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printUint@i64
        add rsp, 8
        ; call printChar@u8[10]
        mov  rax, 10
        push rax
          call _printChar@u8
        add rsp, 8
        ; release space for local variables
        add rsp, 16
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
        jmp _for_4
_for_4_body:
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
_for_4:
        ; load t.2.1, [str.1]
        lea rax, [rsp+8]
        mov rbx, [rax]
        mov al, [rbx]
        lea rbx, [rsp+24]
        mov [rbx], al
        ; branch t.2.1 notequals 0: for_4_body, for_4_break
        lea rax, [rsp+24]
        mov bl, [rax]
        cmp bl, 0
        jne _for_4_body
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

        ; void main
        ;   rsp+0: var t.4.1
        ;   rsp+8: var a.1
        ;   rsp+10: var b.1
        ;   rsp+12: var t.5.1
        ;   rsp+13: var t.6.1
        ;   rsp+16: var t.7.1
        ;   rsp+24: var c.1
        ;   rsp+25: var d.1
        ;   rsp+26: var t.8.1
        ;   rsp+27: var t.9.1
        ;   rsp+32: var t.10.1
        ;   rsp+40: var t.11.1
        ;   rsp+41: var t.12.1
        ;   rsp+48: var t.13.1
        ;   rsp+56: var t.14.1
        ;   rsp+57: var t.15.1
        ;   rsp+64: var t.16.1
        ;   rsp+72: var t.17.1
        ;   rsp+73: var t.18.1
        ;   rsp+80: var t.19.1
        ;   rsp+88: var t.20.1
        ;   rsp+89: var t.21.1
        ;   rsp+96: var t.22.1
        ;   rsp+104: var t.23.1
        ;   rsp+105: var t.24.1
        ;   rsp+112: var t.25.1
        ;   rsp+120: var t.26.1
        ;   rsp+121: var t.27.1
        ;   rsp+128: var t.28.1
        ;   rsp+136: var t.29.1
        ;   rsp+137: var t.30.1
        ;   rsp+144: var t.31.1
        ;   rsp+152: var t.32.1
        ;   rsp+153: var t.33.1
_main:
        ; reserve space for local variables
        sub rsp, 160
        ; const t.4.1, [string-0]
        lea rax, [string_0]
        lea rbx, [rsp+0]
        mov [rbx], rax
        ; call printString@@u8[t.4.1]
        lea rax, [rsp+0]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const a.1, 1
        mov ax, 1
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; const b.1, 2
        mov ax, 2
        lea rbx, [rsp+10]
        mov [rbx], ax
        ; lt t.5.1, a.1, b.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+12]
        mov [rax], bl
        ; call printIntLf@bool[t.5.1]
        lea rax, [rsp+12]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; lt t.6.1, b.1, a.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setl bl
        lea rax, [rsp+13]
        mov [rax], bl
        ; call printIntLf@bool[t.6.1]
        lea rax, [rsp+13]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.7.1, [string-1]
        lea rax, [string_1]
        lea rbx, [rsp+16]
        mov [rbx], rax
        ; call printString@@u8[t.7.1]
        lea rax, [rsp+16]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; const c.1, 0
        mov al, 0
        lea rbx, [rsp+24]
        mov [rbx], al
        ; const d.1, 128
        mov al, 128
        lea rbx, [rsp+25]
        mov [rbx], al
        ; lt t.8.1, c.1, d.1
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+25]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+26]
        mov [rax], bl
        ; call printIntLf@bool[t.8.1]
        lea rax, [rsp+26]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; lt t.9.1, d.1, c.1
        lea rax, [rsp+25]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        cmp bl, cl
        setb bl
        lea rax, [rsp+27]
        mov [rax], bl
        ; call printIntLf@bool[t.9.1]
        lea rax, [rsp+27]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.10.1, [string-2]
        lea rax, [string_2]
        lea rbx, [rsp+32]
        mov [rbx], rax
        ; call printString@@u8[t.10.1]
        lea rax, [rsp+32]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; lteq t.11.1, a.1, b.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+40]
        mov [rax], bl
        ; call printIntLf@bool[t.11.1]
        lea rax, [rsp+40]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; lteq t.12.1, b.1, a.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setle bl
        lea rax, [rsp+41]
        mov [rax], bl
        ; call printIntLf@bool[t.12.1]
        lea rax, [rsp+41]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.13.1, [string-3]
        lea rax, [string_3]
        lea rbx, [rsp+48]
        mov [rbx], rax
        ; call printString@@u8[t.13.1]
        lea rax, [rsp+48]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; lteq t.14.1, c.1, d.1
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+25]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+56]
        mov [rax], bl
        ; call printIntLf@bool[t.14.1]
        lea rax, [rsp+56]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; lteq t.15.1, d.1, c.1
        lea rax, [rsp+25]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        cmp bl, cl
        setbe bl
        lea rax, [rsp+57]
        mov [rax], bl
        ; call printIntLf@bool[t.15.1]
        lea rax, [rsp+57]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.16.1, [string-4]
        lea rax, [string_4]
        lea rbx, [rsp+64]
        mov [rbx], rax
        ; call printString@@u8[t.16.1]
        lea rax, [rsp+64]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; equals t.17.1, a.1, b.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+72]
        mov [rax], bl
        ; call printIntLf@bool[t.17.1]
        lea rax, [rsp+72]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; equals t.18.1, b.1, a.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        sete bl
        lea rax, [rsp+73]
        mov [rax], bl
        ; call printIntLf@bool[t.18.1]
        lea rax, [rsp+73]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.19.1, [string-5]
        lea rax, [string_5]
        lea rbx, [rsp+80]
        mov [rbx], rax
        ; call printString@@u8[t.19.1]
        lea rax, [rsp+80]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; notequals t.20.1, a.1, b.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        setne bl
        lea rax, [rsp+88]
        mov [rax], bl
        ; call printIntLf@bool[t.20.1]
        lea rax, [rsp+88]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; notequals t.21.1, b.1, a.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setne bl
        lea rax, [rsp+89]
        mov [rax], bl
        ; call printIntLf@bool[t.21.1]
        lea rax, [rsp+89]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.22.1, [string-6]
        lea rax, [string_6]
        lea rbx, [rsp+96]
        mov [rbx], rax
        ; call printString@@u8[t.22.1]
        lea rax, [rsp+96]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; gteq t.23.1, a.1, b.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        setge bl
        lea rax, [rsp+104]
        mov [rax], bl
        ; call printIntLf@bool[t.23.1]
        lea rax, [rsp+104]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; gteq t.24.1, b.1, a.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setge bl
        lea rax, [rsp+105]
        mov [rax], bl
        ; call printIntLf@bool[t.24.1]
        lea rax, [rsp+105]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.25.1, [string-7]
        lea rax, [string_7]
        lea rbx, [rsp+112]
        mov [rbx], rax
        ; call printString@@u8[t.25.1]
        lea rax, [rsp+112]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; gteq t.26.1, c.1, d.1
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+25]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+120]
        mov [rax], bl
        ; call printIntLf@bool[t.26.1]
        lea rax, [rsp+120]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; gteq t.27.1, d.1, c.1
        lea rax, [rsp+25]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        cmp bl, cl
        setae bl
        lea rax, [rsp+121]
        mov [rax], bl
        ; call printIntLf@bool[t.27.1]
        lea rax, [rsp+121]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.28.1, [string-8]
        lea rax, [string_8]
        lea rbx, [rsp+128]
        mov [rbx], rax
        ; call printString@@u8[t.28.1]
        lea rax, [rsp+128]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; gt t.29.1, a.1, b.1
        lea rax, [rsp+8]
        mov bx, [rax]
        lea rax, [rsp+10]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+136]
        mov [rax], bl
        ; call printIntLf@bool[t.29.1]
        lea rax, [rsp+136]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; gt t.30.1, b.1, a.1
        lea rax, [rsp+10]
        mov bx, [rax]
        lea rax, [rsp+8]
        mov cx, [rax]
        cmp bx, cx
        setg bl
        lea rax, [rsp+137]
        mov [rax], bl
        ; call printIntLf@bool[t.30.1]
        lea rax, [rsp+137]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; const t.31.1, [string-9]
        lea rax, [string_9]
        lea rbx, [rsp+144]
        mov [rbx], rax
        ; call printString@@u8[t.31.1]
        lea rax, [rsp+144]
        mov rbx, [rax]
        push rbx
          call _printString@@u8
        add rsp, 8
        ; gt t.32.1, c.1, d.1
        lea rax, [rsp+24]
        mov bl, [rax]
        lea rax, [rsp+25]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+152]
        mov [rax], bl
        ; call printIntLf@bool[t.32.1]
        lea rax, [rsp+152]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; gt t.33.1, d.1, c.1
        lea rax, [rsp+25]
        mov bl, [rax]
        lea rax, [rsp+24]
        mov cl, [rax]
        cmp bl, cl
        seta bl
        lea rax, [rsp+153]
        mov [rax], bl
        ; call printIntLf@bool[t.33.1]
        lea rax, [rsp+153]
        mov bl, [rax]
        push rbx
          call _printIntLf@bool
        add rsp, 8
        ; release space for local variables
        add rsp, 160
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
