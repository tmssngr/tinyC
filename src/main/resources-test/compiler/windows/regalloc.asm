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

        ; u8 simple
_simple:
        sub rsp, 8
        ; const four.1{r1}, 4
        mov cl, 4
        ; const three.1{r2}, 3
        mov dl, 3
        ; move one.1{r0}, four.1{r1}
        mov al, cl
        ; sub one.1{r0}, one.1{r0}, three.1{r2}
        sub al, dl
        ; 5:9 return one
        add rsp, 8
        ret

        ; u8 registerHint@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
_registerHint@u8@u8:
        sub rsp, 8
        ; 9:11 return a + b
        ; move t.2.1{r0}, a{r1}
        mov al, cl
        ; add t.2.1{r0}, t.2.1{r0}, b{r2}
        add al, dl
        add rsp, 8
        ret

        ; u8 max@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
_max@u8@u8:
        sub rsp, 8
        ; branch a{r1} lt b{r2}: if_1_then, if_1_end
        cmp cl, dl
        jb _if_1_then
        ; 16:9 return a
        ; move a{r0}, a{r1}
        mov al, cl
        jmp _max@u8@u8_ret
_if_1_then:
        ; 14:10 return b
        ; move b{r0}, b{r2}
        mov al, dl
_max@u8@u8_ret:
        add rsp, 8
        ret

        ; i16 fibonacci@u8
        ;   rsp+16: arg i
_fibonacci@u8:
        sub rsp, 8
        ; const a.1{r2}, 0
        mov dx, 0
        ; const b.1{r3}, 1
        mov r8w, 1
        ; 22:2 while i > 0
        ; move a.2{r0}, a.1{r2}
        mov ax, dx
        ; move b.2{r2}, b.1{r3}
        mov dx, r8w
        jmp _while_2
_while_2_body:
        ; sub i.2{r1}, i.2{r1}, 1
        sub cl, 1
        ; move c.1{r3}, a.2{r0}
        mov r8w, ax
        ; add c.1{r3}, c.1{r3}, b.2{r2}
        add r8w, dx
        ; move a.2{r0}, a.3{r2}
        mov ax, dx
        ; move b.2{r2}, b.3{r3}
        mov dx, r8w
_while_2:
        ; branch i.1{r1} gt 0: while_2_body, while_2_break
        cmp cl, 0
        ja _while_2_body
        ; 28:9 return a
        add rsp, 8
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call one.1{r0} = simple[] -> u8
        call _simple
        ; move one.1{r6}, one.1{r0}
        mov bl, al
        ; const two.1{r7}, 2
        mov r12b, 2
        ; move one.1{r1}, one.1{r6}
        mov cl, bl
        ; move two.1{r2}, two.1{r7}
        mov dl, r12b
        ; call _ = registerHint@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _registerHint@u8@u8
        ; move one.1{r1}, one.1{r6}
        mov cl, bl
        ; move two.1{r2}, two.1{r7}
        mov dl, r12b
        ; call _ = max@u8@u8[one.1{r1}, two.1{r2}] -> u8
        call _max@u8@u8
        ; const arg.3.0{r1}, 5
        mov cl, 5
        ; call _ = fibonacci@u8[arg.3.0{r1}] -> i16
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
