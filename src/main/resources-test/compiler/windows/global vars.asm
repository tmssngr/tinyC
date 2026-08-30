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
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printChar@u8
        ;   rsp+48: arg chr
@printChar@u8:
        sub rsp, 8
        sub rsp, 32
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+48]
        ; const t.2{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
@printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r7}, 20
        mov r12b, 20
        ; 28:2 while true
@while_1:
        ; sub pos{r7}, pos{r7}, 1
        sub r12b, 1
        ; move remainder{r3}, number{r6}
        mov r8, rbx
        ; move remainder{r0}, remainder{r3}
        mov rax, r8
        ; mod remainder{r2}, remainder{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move remainder{r3}, remainder{r2}
        mov r8, rdx
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.5{r0}(u8), remainder{r3}(i64)
        mov al, r8b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r3}(i64), pos{r7}(u8)
        movzx r8, r12b
        ; addrof t.6{r4}, [buffer]
        lea r9, [rsp+60]
        ; add t.6{r4}, t.6{r4}, t.7{r3}
        add r9, r8
        ; store [t.6{r4}], digit{r0}
        mov [r9], al
        ; 34:3 if number == 0
        ; const t.9{r0}, 0
        mov rax, 0
        ; equals t.8{r0}, number{r6}, t.9{r0}
        cmp rbx, rax
        sete al
        ; branch t.8{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.11{r6}(i64), pos{r7}(u8)
        movzx rbx, r12b
        ; addrof t.10{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.10{r1}, t.10{r1}, t.11{r6}
        add rcx, rbx
        ; const t.13{r6}, 20
        mov bl, 20
        ; move t.12{r2}, t.13{r6}
        mov dl, bl
        ; sub t.12{r2}, t.12{r2}, pos{r7}
        sub dl, r12b
        ; call printStringLength@@u8@u8[t.10{r1}, t.12{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf@i16
        ;   rsp+48: arg number
@printIntLf@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+64: arg number
@printIntLf@i64:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; 54:2 if number < 0
        ; const t.2{r7}, 0
        mov r12, 0
        ; lt t.1{r7}, number{r6}, t.2{r7}
        cmp rbx, r12
        setl r12b
        ; branch t.1{r7}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const t.3{r1}, 45
        mov cl, 45
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const t.4{r1}, 10
        mov cl, 10
        ; call printChar@u8[t.4{r1}]
        call @printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
@printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.space{r6}, 32
        mov bx, 32
        ; const tmp.next{r1}, 63
        mov cx, 63
        ; addrof tmp.ptrToSpace{r7}, space
        lea r12, [var_0]
        ; end initialize global variables
        ; move space, tmp.space{r6}
        lea r11, [var_0]
        mov [r11], bx
        ; move next, tmp.next{r1}
        lea r11, [var_1]
        mov [r11], cx
        ; move ptrToSpace, tmp.ptrToSpace{r7}
        lea r11, [var_2]
        mov [r11], r12
        ; call printIntLf@i16[tmp.next{r1}]
        call @printIntLf@i16
        ; move tmp.ptrToSpace{r7}, ptrToSpace
        lea r11, [var_2]
        mov r12, [r11]
        ; add tmp.ptrToSpace{r7}, tmp.ptrToSpace{r7}, 2
        add r12, 2
        ; move ptrToSpace, tmp.ptrToSpace{r7}
        lea r11, [var_2]
        mov [r11], r12
        ; load t.0{r1}, [tmp.ptrToSpace{r7}]
        mov cx, [r12]
        ; call printIntLf@i16[t.0{r1}]
        call @printIntLf@i16
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
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
