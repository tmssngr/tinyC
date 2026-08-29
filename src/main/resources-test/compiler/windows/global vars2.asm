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

        ; void printString@@u8
        ;   rsp+48: arg str
@printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call @strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call @printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 61:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; const t.5{r2}, 1
        mov rdx, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rdx
        ; const t.6{r2}, 1
        mov rdx, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rcx, rdx
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; const t.4{r3}, 0
        mov r8b, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp dl, r8b
        setne dl
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or dl, dl
        jnz @for_1_body
        ; 64:9 return length
        add rsp, 8
        ret

        ; u8 next
@next:
        sub rsp, 8
        ; move tmp.global{r1}, global
        lea r11, [var_0]
        mov cl, [r11]
        ; move copy{r0}, tmp.global{r1}
        mov al, cl
        ; const t.1{r2}, 1
        mov dl, 1
        ; add tmp.global{r1}, tmp.global{r1}, t.1{r2}
        add cl, dl
        ; 8:9 return copy
        ; move global, tmp.global{r1}
        lea r11, [var_0]
        mov [r11], cl
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
        ; const tmp.global{r6}, 0
        mov bl, 0
        ; end initialize global variables
        ; 12:2 while true
        jmp @while_2
@if_3_end:
        ; 19:3 if n < 2
        ; const t.5{r0}, 2
        mov al, 2
        ; lt t.4{r7}, n{r7}, t.5{r0}
        cmp r12b, al
        setb r12b
        ; branch t.4{r7}, false, @while_2, @if_4_then
        or r12b, r12b
        jz @while_2
        ; const t.6{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.6{r1}]
        call @printString@@u8
@while_2:
        ; const t.1{r1}, [string-0]
        lea rcx, [string_0]
        ; move global, tmp.global{r6}
        lea r11, [var_0]
        mov [r11], bl
        ; call printString@@u8[t.1{r1}]
        call @printString@@u8
        ; call n{r0} = next[] -> u8
        call @next
        ; move n{r7}, n{r0}
        mov r12b, al
        ; 15:3 if n == 3
        ; const t.3{r0}, 3
        mov al, 3
        ; equals t.2{r0}, n{r7}, t.3{r0}
        cmp r12b, al
        sete al
        ; branch t.2{r0}, false, @if_3_end, @main_ret
        or al, al
        jz @if_3_end
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
        ; variable 0: global (u8/1)
        var_0 rb 1

section '.data' data readable
        string_0 db 'loop', 0x0a, 0x00
        string_1 db '<2', 0x0a, 0x00

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
