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
        call init
        call _main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printChar@u8
        ;   rsp+48: arg chr
_printChar@u8:
        sub rsp, 8
        sub rsp, 32
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; addrof t.1.1{r1}, chr
        lea rcx, [rsp+48]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
_printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 28:2 while true
        ; move number.1{r7}, number{r1}
        mov r12, rcx
_while_1:
        ; sub pos.3{r6}, pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r3}, number.1{r7}
        mov r8, r12
        ; move remainder.1{r0}, remainder.1{r3}
        mov rax, r8
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move remainder.1{r3}, remainder.1{r2}
        mov r8, rdx
        ; move number.2{r0}, number.2{r7}
        mov rax, r12
        ; div number.2{r0}, number.2{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move number.2{r7}, number.2{r0}
        mov r12, rax
        ; cast t.5.1{r0}(u8), remainder.1{r3}(i64)
        mov al, r8b
        ; add digit.1{r0}, digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r6}(u8)
        movzx r8, bl
        ; addrof t.6.1{r4}, [buffer]
        lea r9, [rsp+60]
        ; add t.6.2{r4}, t.6.2{r4}, t.7.1{r3}
        add r9, r8
        ; store [t.6.2{r4}], digit.1{r0}
        mov [r9], al
        ; 34:3 if number == 0
        ; branch number.2{r7} notequals 0: while_1, while_1_break
        cmp r12, 0
        jne _while_1
        ; cast t.9.1{r7}(i64), pos.3{r6}(u8)
        movzx r12, bl
        ; addrof t.8.1{r0}, [buffer]
        lea rax, [rsp+60]
        ; move t.8.2{r1}, t.8.1{r0}
        mov rcx, rax
        ; add t.8.2{r1}, t.8.2{r1}, t.9.1{r7}
        add rcx, r12
        ; const t.11.1{r7}, 20
        mov r12b, 20
        ; move t.10.1{r2}, t.11.1{r7}
        mov dl, r12b
        ; sub t.10.1{r2}, t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf@i16
        ;   rsp+48: arg number
_printIntLf@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+48: arg number
_printIntLf@i64:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; branch number{r6} gteq 0: if_3_end, if_3_then
        cmp rbx, 0
        jge _if_3_end
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r6}, number{r6}
        neg rbx
_if_3_end:
        ; move number.1{r1}, number.1{r6}
        mov rcx, rbx
        ; call printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.space{r6}, 32
        mov bx, 32
        ; addrof a.space{r7}, space
        lea r12, [var_0]
        ; store [a.space{r7}], t.space{r6}
        mov [r12], bx
        ; const t.next{r6}, 63
        mov bx, 63
        ; addrof a.next{r7}, next
        lea r12, [var_1]
        ; store [a.next{r7}], t.next{r6}
        mov [r12], bx
        ; addrof t.ptrToSpace{r6}, space
        lea rbx, [var_0]
        ; addrof a.ptrToSpace{r7}, ptrToSpace
        lea r12, [var_2]
        ; store [a.ptrToSpace{r7}], t.ptrToSpace{r6}
        mov [r12], rbx
        ; end initialize global variables
        ; addrof a.next1{r6}, next
        lea rbx, [var_1]
        ; load t.next1{r1}, [a.next1{r6}]
        mov cx, [rbx]
        ; call printIntLf@i16[t.next1{r1}]
        call _printIntLf@i16
        ; addrof a.ptrToSpace1{r6}, ptrToSpace
        lea rbx, [var_2]
        ; load t.ptrToSpace1{r6}, [a.ptrToSpace1{r6}]
        mov rbx, [rbx]
        ; add t.ptrToSpace2{r6}, t.ptrToSpace2{r6}, 2
        add rbx, 2
        ; addrof a.ptrToSpace2{r7}, ptrToSpace
        lea r12, [var_2]
        ; store [a.ptrToSpace2{r7}], t.ptrToSpace2{r6}
        mov [r12], rbx
        ; addrof a.ptrToSpace3{r6}, ptrToSpace
        lea rbx, [var_2]
        ; load t.ptrToSpace3{r6}, [a.ptrToSpace3{r6}]
        mov rbx, [rbx]
        ; load t.0.1{r1}, [t.ptrToSpace3{r6}]
        mov cx, [rbx]
        ; call printIntLf@i16[t.0.1{r1}]
        call _printIntLf@i16
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

init:
        sub rsp, 28h
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
        add rsp, 28h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: space (i16/2)
        var_0 rb 2
        ; variable 1: next (i16/2)
        var_1 rb 2
        ; variable 2: ptrToSpace (i16*/8)
        var_2 rb 8

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
