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

        ; void printIntLf@i16
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printIntLf@i16:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(i16)
        lea rax, [rsp+24]
        mov bx, [rax]
        movsx rbx, bx
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
        ;   rsp+0: var foo.1
        ;   rsp+2: var bar.1
        ;   rsp+4: var foo.2
        ;   rsp+6: var t.5.1
        ;   rsp+8: var foo.3
        ;   rsp+10: var bazz.1
        ;   rsp+12: var a.1
        ;   rsp+14: var b.1
        ;   rsp+16: var t.6.1
        ;   rsp+18: var t.7.1
        ;   rsp+20: var a.2
        ;   rsp+22: var b.2
        ;   rsp+24: var t.8.1
        ;   rsp+26: var a.3
        ;   rsp+28: var b.3
        ;   rsp+30: var t.9.1
        ;   rsp+32: var a.4
        ;   rsp+34: var t.10.1
_main:
        ; reserve space for local variables
        sub rsp, 48
        ; const foo.1, 22
        mov ax, 22
        lea rbx, [rsp+0]
        mov [rbx], ax
        ; move bar.1, foo.1
        lea rax, [rsp+0]
        mov bx, [rax]
        lea rax, [rsp+2]
        mov [rax], bx
        ; mul bar.1, bar.1, foo.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+0]
        mov cx, [rax]
        movsx rbx, bx
        movsx rcx, cx
        imul  rbx, rcx
        lea rax, [rsp+2]
        mov [rax], bx
        ; const foo.2, 1
        mov ax, 1
        lea rbx, [rsp+4]
        mov [rbx], ax
        ; move t.5.1, bar.1
        lea rax, [rsp+2]
        mov bx, [rax]
        lea rax, [rsp+6]
        mov [rax], bx
        ; add t.5.1, t.5.1, foo.2
        lea rax, [rsp+6]
        mov bx, [rax]
        lea rax, [rsp+4]
        mov cx, [rax]
        add bx, cx
        lea rax, [rsp+6]
        mov [rax], bx
        ; call printIntLf@i16[t.5.1]
        lea rax, [rsp+6]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const foo.3, 21
        mov ax, 21
        lea rbx, [rsp+8]
        mov [rbx], ax
        ; call printIntLf@i16[foo.3]
        lea rax, [rsp+8]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const bazz.1, 0
        mov ax, 0
        lea rbx, [rsp+10]
        mov [rbx], ax
        ; call printIntLf@i16[bazz.1]
        lea rax, [rsp+10]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const a.1, 1000
        mov ax, 1000
        lea rbx, [rsp+12]
        mov [rbx], ax
        ; const b.1, 10
        mov ax, 10
        lea rbx, [rsp+14]
        mov [rbx], ax
        ; move t.6.1, a.1
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+16]
        mov [rax], bx
        ; div t.6.1, t.6.1, b.1
        lea rax, [rsp+16]
        mov bx, [rax]
        lea rax, [rsp+14]
        mov cx, [rax]
        movsx rax, bx
        movsx rcx, cx
        cqo
        idiv rcx
        mov rbx, rax
        lea rdx, [rsp+16]
        mov [rdx], bx
        ; call printIntLf@i16[t.6.1]
        lea rax, [rsp+16]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; move t.7.1, a.1
        lea rax, [rsp+12]
        mov bx, [rax]
        lea rax, [rsp+18]
        mov [rax], bx
        ; and t.7.1, t.7.1, 255
        lea rax, [rsp+18]
        mov bx, [rax]
        and bx, 255
        lea rax, [rsp+18]
        mov [rax], bx
        ; call printIntLf@i16[t.7.1]
        lea rax, [rsp+18]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const a.2, 10
        mov ax, 10
        lea rbx, [rsp+20]
        mov [rbx], ax
        ; const b.2, 1
        mov ax, 1
        lea rbx, [rsp+22]
        mov [rbx], ax
        ; move t.8.1, a.2
        lea rax, [rsp+20]
        mov bx, [rax]
        lea rax, [rsp+24]
        mov [rax], bx
        ; shiftright t.8.1, t.8.1, b.2
        lea rax, [rsp+24]
        mov bx, [rax]
        lea rax, [rsp+22]
        mov cx, [rax]
        sar bx, cl
        lea rax, [rsp+24]
        mov [rax], bx
        ; call printIntLf@i16[t.8.1]
        lea rax, [rsp+24]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const a.3, 9
        mov ax, 9
        lea rbx, [rsp+26]
        mov [rbx], ax
        ; const b.3, 2
        mov ax, 2
        lea rbx, [rsp+28]
        mov [rbx], ax
        ; move t.9.1, a.3
        lea rax, [rsp+26]
        mov bx, [rax]
        lea rax, [rsp+30]
        mov [rax], bx
        ; shiftright t.9.1, t.9.1, b.3
        lea rax, [rsp+30]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov cx, [rax]
        sar bx, cl
        lea rax, [rsp+30]
        mov [rax], bx
        ; call printIntLf@i16[t.9.1]
        lea rax, [rsp+30]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; const a.4, 1
        mov ax, 1
        lea rbx, [rsp+32]
        mov [rbx], ax
        ; move t.10.1, a.4
        lea rax, [rsp+32]
        mov bx, [rax]
        lea rax, [rsp+34]
        mov [rax], bx
        ; shiftleft t.10.1, t.10.1, b.3
        lea rax, [rsp+34]
        mov bx, [rax]
        lea rax, [rsp+28]
        mov cx, [rax]
        sal bx, cl
        lea rax, [rsp+34]
        mov [rax], bx
        ; call printIntLf@i16[t.10.1]
        lea rax, [rsp+34]
        mov bx, [rax]
        push rbx
          call _printIntLf@i16
        add rsp, 8
        ; release space for local variables
        add rsp, 48
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
