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

        ; u8 simple
@simple:
        sub rsp, 8
        ; const four{r1}, 4
        mov cl, 4
        ; const three{r2}, 3
        mov dl, 3
        ; move one{r0}, four{r1}
        mov al, cl
        ; sub one{r0}, one{r0}, three{r2}
        sub al, dl
        ; 5:9 return one
        add rsp, 8
        ret

        ; u8 registerHint@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
@registerHint@u8@u8:
        sub rsp, 8
        ; 9:11 return a + b
        ; move t.2{r0}, a{r1}
        mov al, cl
        ; add t.2{r0}, t.2{r0}, b{r2}
        add al, dl
        add rsp, 8
        ret

        ; u8 max@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
@max@u8@u8:
        sub rsp, 8
        ; 13:2 if a < b
        ; lt t.2{r3}, a{r1}, b{r2}
        cmp cl, dl
        setb r8b
        ; branch t.2{r3}, true, @if_1_then
        or r8b, r8b
        jnz @if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        mov al, cl
        jmp @max@u8@u8_ret
@if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        mov al, dl
@max@u8@u8_ret:
        add rsp, 8
        ret

        ; i16 fibonacci@u8
        ;   rsp+16: arg i
@fibonacci@u8:
        sub rsp, 8
        ; const a{r0}, 0
        mov ax, 0
        ; const b{r2}, 1
        mov dx, 1
        ; 22:2 while i > 0
        jmp @while_2
@while_2_body:
        ; dec i{r1}
        dec cl
        ; move c{r3}, a{r0}
        mov r8w, ax
        ; add c{r3}, c{r3}, b{r2}
        add r8w, dx
        ; move a{r0}, b{r2}
        mov ax, dx
        ; move b{r2}, c{r3}
        mov dx, r8w
@while_2:
        ; gt t.4{r3}, i{r1}, 0
        cmp cl, 0
        seta r8b
        ; branch t.4{r3}, true, @while_2_body
        or r8b, r8b
        jnz @while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call one{r0} = simple[] -> u8
        call @simple
        ; move one{r6}, one{r0}
        mov bl, al
        ; const two{r7}, 2
        mov r12b, 2
        ; move one{r1}, one{r6}
        mov cl, bl
        ; move two{r2}, two{r7}
        mov dl, r12b
        ; call _ = registerHint@u8@u8[one{r1}, two{r2}] -> u8
        call @registerHint@u8@u8
        ; move one{r1}, one{r6}
        mov cl, bl
        ; move two{r2}, two{r7}
        mov dl, r12b
        ; call _ = max@u8@u8[one{r1}, two{r2}] -> u8
        call @max@u8@u8
        ; const t.4{r1}, 5
        mov cl, 5
        ; call _ = fibonacci@u8[t.4{r1}] -> i16
        call @fibonacci@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
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
