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

        ; void printString
        ;   rsp+48: arg str
@printString:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen[str{r1}] -> i64
        call @strlen
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength[str{r1}, length{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar
        ;   rsp+48: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; addrof t.1{r6}, chr
        lea rbx, [rsp+48]
        ; const t.2{r2}, 1
        mov rdx, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; move t.1{r1}, t.1{r6}
        mov rcx, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printUint
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
@printUint:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const pos{r6}, 20
        mov bl, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r6}
        dec bl
        ; const t.5{r7}, 10
        mov r12, 10
        ; move remainder{r3}, number{r1}
        mov r8, rcx
        ; move remainder{r0}, remainder{r3}
        mov rax, r8
        ; mod remainder{r2}, remainder{r0}, t.5{r7}
        cqo
        idiv r12
        ; move remainder{r3}, remainder{r2}
        mov r8, rdx
        ; const t.6{r7}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rcx
        ; div number{r0}, number{r0}, t.6{r7}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rcx, rax
        ; cast t.7{r7}(u8), remainder{r3}(i64)
        mov r12b, r8b
        ; const t.8{r0}, 48
        mov al, 48
        ; add digit{r7}, digit{r7}, t.8{r0}
        add r12b, al
        ; cast t.10{r0}(i64), pos{r6}(u8)
        movzx rax, bl
        ; cast t.11{r0}(u8*), t.10{r0}(i64)
        ; addrof t.9{r3}, [buffer]
        lea r8, [rsp+60]
        ; add t.9{r3}, t.9{r3}, t.11{r0}
        add r8, rax
        ; store [t.9{r3}], digit{r7}
        mov [r8], r12b
        ; 19:3 if number == 0
        ; equals t.12{r7}, number{r1}, 0
        cmp rcx, 0
        sete r12b
        ; branch t.12{r7}, false, @while_1
        or r12b, r12b
        jz @while_1
        ; cast t.14{r7}(i64), pos{r6}(u8)
        movzx r12, bl
        ; cast t.15{r7}(u8*), t.14{r7}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.13{r1}, t.13{r1}, t.15{r7}
        add rcx, r12
        ; const t.18{r7}, 20
        mov r12b, 20
        ; sub t.17{r7}, t.17{r7}, pos{r6}
        sub r12b, bl
        ; cast t.16{r2}(i64), t.17{r7}(u8)
        movzx rdx, r12b
        ; call printStringLength[t.13{r1}, t.16{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; void printIntLf
        ;   rsp+64: arg number
@printIntLf:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; 27:2 if number < 0
        ; lt t.1{r7}, number{r6}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r7}, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov cl, 45
        ; call printChar[t.2{r1}]
        call @printChar
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint[number{r1}]
        call @printUint
        ; const t.3{r1}, 10
        mov cl, 10
        ; call printChar[t.3{r1}]
        call @printChar
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; inc length{r0}
        inc rax
        ; cast t.5{r2}(i64), str{r1}(u8*)
        mov rdx, rcx
        ; const t.6{r3}, 1
        mov r8, 1
        ; move t.4{r1}, t.5{r2}
        mov rcx, rdx
        ; add t.4{r1}, t.4{r1}, t.6{r3}
        add rcx, r8
        ; cast str{r1}(u8*), t.4{r1}(i64)
@for_4:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp dl, 0
        setne dl
        ; branch t.2{r2}, true, @for_4_body
        or dl, dl
        jnz @for_4_body
        ; 40:9 return length
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
        ; call printString[tmp.text{r1}]
        call @printString
        ; call printLength[]
        call @printLength
        ; const t.2{r7}, 1
        mov r12, 1
        ; cast t.3{r7}(u8*), t.2{r7}(i64)
        ; move tmp.text{r6}, text
        lea r11, [var_0]
        mov rbx, [r11]
        ; move second{r1}, tmp.text{r6}
        mov rcx, rbx
        ; add second{r1}, second{r1}, t.3{r7}
        add rcx, r12
        ; call printString[second{r1}]
        call @printString
        ; move tmp.text{r6}, text
        lea r11, [var_0]
        mov rbx, [r11]
        ; load chr{r6}, [tmp.text{r6}]
        mov bl, [rbx]
        ; cast t.4{r1}(i64), chr{r6}(u8)
        movzx rcx, bl
        ; call printIntLf[t.4{r1}]
        call @printIntLf
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
        ; const length{r6}, 0
        mov bx, 0
        ; move tmp.text{r7}, text
        lea r11, [var_0]
        mov r12, [r11]
        ; 16:2 for *ptr != 0
        jmp @for_5
@for_5_body:
        ; inc length{r6}
        inc bx
        ; cast t.5{r0}(i64), ptr{r7}(u8*)
        mov rax, r12
        ; const t.6{r2}, 1
        mov rdx, 1
        ; move t.4{r7}, t.5{r0}
        mov r12, rax
        ; add t.4{r7}, t.4{r7}, t.6{r2}
        add r12, rdx
        ; cast ptr{r7}(u8*), t.4{r7}(i64)
@for_5:
        ; load t.3{r0}, [ptr{r7}]
        mov al, [r12]
        ; notequals t.2{r0}, t.3{r0}, 0
        cmp al, 0
        setne al
        ; branch t.2{r0}, true, @for_5_body
        or al, al
        jnz @for_5_body
        ; cast t.7{r1}(i64), length{r6}(i16)
        movzx rcx, bx
        ; call printIntLf[t.7{r1}]
        call @printIntLf
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
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
