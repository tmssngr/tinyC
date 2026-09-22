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

        ; void printIntLf@u8
        ;   rsp+24: arg number
        ;   rsp+0: var t.1.1
_printIntLf@u8:
        ; reserve space for local variables
        sub rsp, 16
        ; cast t.1.1(i64), number(u8)
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
        ;   rsp+8: arg salt
_initRandom@i32:
        ; move __random__, salt
        lea rax, [rsp+8]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
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
_random:
        ; reserve space for local variables
        sub rsp, 48
        ; move r.1, __random__
        lea rax, [var_0]
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
        ; move __random__, t.10.1
        lea rax, [rsp+40]
        mov ebx, [rax]
        lea rax, [var_0]
        mov [rax], ebx
        ; add __random__, __random__, t.11.1
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

        ; u8 randomU8
        ;   rsp+0: var t.1.1
        ;   rsp+4: var t.0.1
_randomU8:
        ; reserve space for local variables
        sub rsp, 16
        ; 19:10 return (u8)
        ; call t.1.1 = random[] -> i32
        sub rsp, 8
          call _random
        add rsp, 8
        lea rbx, [rsp+0]
        mov [rbx], eax
        ; cast t.0.1(u8), t.1.1(i32)
        lea rax, [rsp+0]
        mov ebx, [rax]
        lea rax, [rsp+4]
        mov [rax], bl
        ; ret t.0.1
        lea rax, [rsp+4]
        mov bl, [rax]
        mov rax, rbx
        ; release space for local variables
        add rsp, 16
        ret

        ; void main
        ;   rsp+0: var i.1
        ;   rsp+1: var i.2
        ;   rsp+2: var r.1
        ;   rsp+3: var i.3
_main:
        ; reserve space for local variables
        sub rsp, 16
        ; begin initialize global variables
        ; const __random__, 0
        mov eax, 0
        lea rbx, [var_0]
        mov [rbx], eax
        ; end initialize global variables
        ; call initRandom@i32[7439742]
        mov  rax, 7439742
        push rax
          call _initRandom@i32
        add rsp, 8
        ; const i.1, 0
        mov al, 0
        lea rbx, [rsp+0]
        mov [rbx], al
        ; 6:2 for i < 50
        ; move i.2, i.1
        lea rax, [rsp+0]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
        jmp _for_4
_for_4_body:
        ; call r.1 = randomU8[] -> u8
        sub rsp, 8
          call _randomU8
        add rsp, 8
        lea rbx, [rsp+2]
        mov [rbx], al
        ; call printIntLf@u8[r.1]
        lea rax, [rsp+2]
        mov bl, [rax]
        push rbx
          call _printIntLf@u8
        add rsp, 8
        ; move i.3, i.2
        lea rax, [rsp+1]
        mov bl, [rax]
        lea rax, [rsp+3]
        mov [rax], bl
        ; add i.3, i.3, 1
        lea rax, [rsp+3]
        mov bl, [rax]
        add bl, 1
        lea rax, [rsp+3]
        mov [rax], bl
        ; move i.2, i.3
        lea rax, [rsp+3]
        mov bl, [rax]
        lea rax, [rsp+1]
        mov [rax], bl
_for_4:
        ; branch i.2 lt 50: for_4_body, main_ret
        lea rax, [rsp+1]
        mov bl, [rax]
        cmp bl, 50
        jb _for_4_body
        ; release space for local variables
        add rsp, 16
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
        ; variable 0: __random__ (i32/4)
        var_0 rb 4

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
