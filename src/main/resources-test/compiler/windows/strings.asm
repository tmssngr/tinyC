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
        ; const pos{r6}, 20
        mov bl, 20
        ; 25:2 while true
@while_1:
        ; const t.5{r7}, 1
        mov r12b, 1
        ; sub pos{r6}, pos{r6}, t.5{r7}
        sub bl, r12b
        ; const t.6{r7}, 10
        mov r12, 10
        ; move remainder{r3}, number{r1}
        mov r8, rcx
        ; move remainder{r0}, remainder{r3}
        mov rax, r8
        ; mod remainder{r2}, remainder{r0}, t.6{r7}
        cqo
        idiv r12
        ; move remainder{r3}, remainder{r2}
        mov r8, rdx
        ; const t.7{r7}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rcx
        ; div number{r0}, number{r0}, t.7{r7}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rcx, rax
        ; cast t.8{r7}(u8), remainder{r3}(i64)
        mov r12b, r8b
        ; const t.9{r0}, 48
        mov al, 48
        ; add digit{r7}, digit{r7}, t.9{r0}
        add r12b, al
        ; cast t.11{r0}(i64), pos{r6}(u8)
        movzx rax, bl
        ; cast t.12{r0}(u8*), t.11{r0}(i64)
        ; addrof t.10{r3}, [buffer]
        lea r8, [rsp+60]
        ; add t.10{r3}, t.10{r3}, t.12{r0}
        add r8, rax
        ; store [t.10{r3}], digit{r7}
        mov [r8], r12b
        ; 31:3 if number == 0
        ; const t.14{r7}, 0
        mov r12, 0
        ; equals t.13{r7}, number{r1}, t.14{r7}
        cmp rcx, r12
        sete r12b
        ; branch t.13{r7}, false, @while_1, @while_1_break
        or r12b, r12b
        jz @while_1
        ; cast t.16{r7}(i64), pos{r6}(u8)
        movzx r12, bl
        ; cast t.17{r7}(u8*), t.16{r7}(i64)
        ; addrof t.15{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.15{r1}, t.15{r1}, t.17{r7}
        add rcx, r12
        ; const t.19{r7}, 20
        mov r12b, 20
        ; move t.18{r2}, t.19{r7}
        mov dl, r12b
        ; sub t.18{r2}, t.18{r2}, pos{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.15{r1}, t.18{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf@u8
        ;   rsp+48: arg number
@printIntLf@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 32
        add rsp, 8
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

        ; i64 strlen@@u8
        ;   rsp+16: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 61:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; const t.5{r2}, 1
        mov rdx, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rdx
        ; cast t.7{r1}(i64), str{r1}(u8*)
        ; const t.8{r2}, 1
        mov rdx, 1
        ; add t.6{r1}, t.6{r1}, t.8{r2}
        add rcx, rdx
        ; cast str{r1}(u8*), t.6{r1}(i64)
@for_4:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; const t.4{r3}, 0
        mov r8b, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp dl, r8b
        setne dl
        ; branch t.2{r2}, true, @for_4_body, @for_4_break
        or dl, dl
        jnz @for_4_body
        ; 64:9 return length
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
        ; const tmp.text{r6}, [string-0]
        lea rbx, [string_0]
        ; end initialize global variables
        ; move text, tmp.text{r6}
        lea r11, [var_0]
        mov [r11], rbx
        ; move tmp.text{r1}, tmp.text{r6}
        mov rcx, rbx
        ; call printString@@u8[tmp.text{r1}]
        call @printString@@u8
        ; call printLength[]
        call @printLength
        ; const t.2{r6}, 1
        mov rbx, 1
        ; cast t.3{r7}(u8*), t.2{r6}(i64)
        mov r12, rbx
        ; move tmp.text{r6}, text
        lea r11, [var_0]
        mov rbx, [r11]
        ; move second{r1}, tmp.text{r6}
        mov rcx, rbx
        ; add second{r1}, second{r1}, t.3{r7}
        add rcx, r12
        ; call printString@@u8[second{r1}]
        call @printString@@u8
        ; move tmp.text{r6}, text
        lea r11, [var_0]
        mov rbx, [r11]
        ; load chr{r1}, [tmp.text{r6}]
        mov cl, [rbx]
        ; call printIntLf@u8[chr{r1}]
        call @printIntLf@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printLength
@printLength:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const length{r1}, 0
        mov cx, 0
        ; move tmp.text{r6}, text
        lea r11, [var_0]
        mov rbx, [r11]
        ; 16:2 for *ptr != 0
        jmp @for_5
@for_5_body:
        ; const t.5{r7}, 1
        mov r12w, 1
        ; add length{r1}, length{r1}, t.5{r7}
        add cx, r12w
        ; cast t.7{r6}(i64), ptr{r6}(u8*)
        ; const t.8{r7}, 1
        mov r12, 1
        ; add t.6{r6}, t.6{r6}, t.8{r7}
        add rbx, r12
        ; cast ptr{r6}(u8*), t.6{r6}(i64)
@for_5:
        ; load t.3{r7}, [ptr{r6}]
        mov r12b, [rbx]
        ; const t.4{r0}, 0
        mov al, 0
        ; notequals t.2{r7}, t.3{r7}, t.4{r0}
        cmp r12b, al
        setne r12b
        ; branch t.2{r7}, true, @for_5_body, @for_5_break
        or r12b, r12b
        jnz @for_5_body
        ; call printIntLf@i16[length{r1}]
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
        ; variable 0: text (u8*/8)
        var_0 rb 8

section '.data' data readable
        string_0 db 'hello world', 0x0a, 0x00

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
