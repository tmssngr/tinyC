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
        ;   rsp+64: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof spillHelper{r7}, chr
        lea r12, [rsp+64]
        ; store [spillHelper{r7}], chr{r1}
        mov [r12], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+64]
        ; const t.2{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
@printUint@i64:
        sub rsp, 32
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const pos{r6}, 20
        mov bl, 20
        ; 25:2 while true
@while_1:
        ; const t.5{r3}, 1
        mov r8b, 1
        ; sub pos{r6}, pos{r6}, t.5{r3}
        sub bl, r8b
        ; const t.6{r3}, 10
        mov r8, 10
        ; move remainder{r4}, number{r1}
        mov r9, rcx
        ; move remainder{r0}, remainder{r4}
        mov rax, r9
        ; mod remainder{r2}, remainder{r0}, t.6{r3}
        cqo
        idiv r8
        ; move remainder{r4}, remainder{r2}
        mov r9, rdx
        ; const t.7{r3}, 10
        mov r8, 10
        ; move number{r0}, number{r1}
        mov rax, rcx
        ; div number{r0}, number{r0}, t.7{r3}
        cqo
        idiv r8
        ; move number{r1}, number{r0}
        mov rcx, rax
        ; cast t.8{r0}(u8), remainder{r4}(i64)
        mov al, r9b
        ; const t.9{r3}, 48
        mov r8b, 48
        ; add digit{r0}, digit{r0}, t.9{r3}
        add al, r8b
        ; cast t.11{r3}(i64), pos{r6}(u8)
        movzx r8, bl
        ; cast t.12{r3}(u8*), t.11{r3}(i64)
        ; addrof t.10{r4}, [buffer]
        lea r9, [rsp+40]
        ; add t.10{r4}, t.10{r4}, t.12{r3}
        add r9, r8
        ; store [t.10{r4}], digit{r0}
        mov [r9], al
        ; 31:3 if number == 0
        ; const t.14{r0}, 0
        mov rax, 0
        ; equals t.13{r0}, number{r1}, t.14{r0}
        cmp rcx, rax
        sete al
        ; branch t.13{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.16{r0}(i64), pos{r6}(u8)
        movzx rax, bl
        ; cast t.17{r0}(u8*), t.16{r0}(i64)
        ; addrof t.15{r1}, [buffer]
        lea rcx, [rsp+40]
        ; add t.15{r1}, t.15{r1}, t.17{r0}
        add rcx, rax
        ; const t.19{r0}, 20
        mov al, 20
        ; move t.18{r2}, t.19{r0}
        mov dl, al
        ; sub t.18{r2}, t.18{r2}, pos{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.15{r1}, t.18{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
        ret

        ; void printIntLf@i16
        ;   rsp+48: arg number
@printIntLf@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(i16)
        movzx rcx, cx
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
        ; 51:2 if number < 0
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
        ; end initialize global variables
        ; const a{r6}, 0
        mov bx, 0
        ; const b{r7}, 1
        mov r12w, 1
        ; 6:2 while b < 1000
        jmp @while_4
@while_4_body:
        ; add b{r7}, b{r7}, a{r6}
        add r12w, bx
        ; move t.4{r0}, b{r7}
        mov ax, r12w
        ; sub t.4{r0}, t.4{r0}, a{r6}
        sub ax, bx
        ; move a{r6}, t.4{r0}
        mov bx, ax
        ; move a{r1}, a{r6}
        mov cx, bx
        ; call printIntLf@i16[a{r1}]
        call @printIntLf@i16
@while_4:
        ; const t.3{r0}, 1000
        mov ax, 1000
        ; lt t.2{r0}, b{r7}, t.3{r0}
        cmp r12w, ax
        setl al
        ; branch t.2{r0}, true, @while_4_body, @main_ret
        or al, al
        jnz @while_4_body
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
