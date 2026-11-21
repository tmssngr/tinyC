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

        ; u8 _simple
_simple:
        sub rsp, 8
        ; const four.1{r0}, 4
        mov al, 4
        ; const three.1{r1}, 3
        mov cl, 3
        ; sub one.1{r0}, three.1{r1}
        sub al, cl
        ; 5:9 return one
        add rsp, 8
        ret

        ; u8 _registerHint@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
_registerHint@u8@u8:
        sub rsp, 8
        ; 9:11 return a + b
        ; move t.2.1{r0}, a{r1}
        mov al, cl
        ; add t.2.1{r0}, b{r2}
        add al, dl
        add rsp, 8
        ret

        ; u8 _max@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
_max@u8@u8:
        sub rsp, 8
        ; branch a{r1} lt b{r2}: if_1_then
        cmp cl, dl
        jb if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        mov al, cl
        jmp _max@u8@u8_ret
if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        mov al, dl
_max@u8@u8_ret:
        add rsp, 8
        ret

        ; i16 _fibonacci@u8
        ;   rsp+16: arg i
_fibonacci@u8:
        sub rsp, 8
        ; const a.1{r0}, 0
        mov ax, 0
        ; const b.1{r2}, 1
        mov dx, 1
        ; 22:2 while i > 0
        jmp while_2
while_2_body:
        ; sub i.2{r1}, 1
        sub cl, 1
        ; add c.1{r0}, b.2{r2}
        add ax, dx
        ; move b.3{r3}, c.1{r0}
        mov r8w, ax
        ; move a.2{r0}, a.3{r2}
        mov ax, dx
        ; move b.2{r2}, b.3{r3}
        mov dx, r8w
while_2:
        ; branch i.1{r1} gt 0: while_2_body
        cmp cl, 0
        ja while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void _main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call one.1{r0} = _simple[] -> u8
        call _simple
        ; move one.1{r6}, one.1{r0}
        mov bl, al
        ; const two.1{r7}, 2
        mov r12b, 2
        ; move one.1{r1}, one.1{r6}
        mov cl, bl
        ; move two.1{r2}, two.1{r7}
        mov dl, r12b
        ; call _ = _registerHint@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _registerHint@u8@u8
        ; move one.1{r1}, one.1{r6}
        mov cl, bl
        ; move two.1{r2}, two.1{r7}
        mov dl, r12b
        ; call _ = _max@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _max@u8@u8
        ; const arg.3.0{r1}, 5
        mov cl, 5
        ; call _ = _fibonacci@u8[arg.3.0{r1}] -> i16
        call _fibonacci@u8
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
