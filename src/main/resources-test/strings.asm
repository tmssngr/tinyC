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
        ;   rsp+16: arg str
@printString:
        ; save clobbered non-volatile registers
        push rbx
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen[str{r1}] -> i64
        sub rsp, 20h; shadow space
        call @strlen
        add rsp, 20h
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength[str{r1}, length{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar
        ;   rsp+16: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push rbx
        ; addrof t.1{r6}, chr
        lea rbx, [rsp+16]
        ; const t.2{r2}, 1
        mov rdx, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+16]
        mov [r11], cl
        ; move t.1{r1}, t.1{r6}
        mov rcx, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printUint
        ;   rsp+48: arg number
        ;   rsp+20: var buffer
@printUint:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r7}, 20
        mov r12b, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r7}
        dec r12b
        ; const t.5{r3}, 10
        mov r8, 10
        ; move remainder{r4}, number{r6}
        mov r9, rbx
        ; move remainder{r0}, remainder{r4}
        mov rax, r9
        ; mod remainder{r2}, remainder{r0}, t.5{r3}
        cqo
        idiv r8
        ; move remainder{r4}, remainder{r2}
        mov r9, rdx
        ; const t.6{r3}, 10
        mov r8, 10
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, t.6{r3}
        cqo
        idiv r8
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.7{r0}(u8), remainder{r4}(i64)
        mov al, r9b
        ; const t.8{r3}, 48
        mov r8b, 48
        ; add digit{r0}, digit{r0}, t.8{r3}
        add al, r8b
        ; cast t.10{r3}(i64), pos{r7}(u8)
        movzx r8, r12b
        ; cast t.11{r3}(u8*), t.10{r3}(i64)
        ; addrof t.9{r4}, [buffer]
        lea r9, [rsp+20]
        ; add t.9{r4}, t.9{r4}, t.11{r3}
        add r9, r8
        ; store [t.9{r4}], digit{r0}
        mov [r9], al
        ; 19:3 if number == 0
        ; equals t.12{r0}, number{r6}, 0
        cmp rbx, 0
        sete al
        ; branch t.12{r0}, false, @while_1
        or al, al
        jz @while_1
        ; cast t.14{r6}(i64), pos{r7}(u8)
        movzx rbx, r12b
        ; cast t.15{r6}(u8*), t.14{r6}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rcx, [rsp+20]
        ; add t.13{r1}, t.13{r1}, t.15{r6}
        add rcx, rbx
        ; const t.18{r6}, 20
        mov bl, 20
        ; sub t.17{r6}, t.17{r6}, pos{r7}
        sub bl, r12b
        ; cast t.16{r2}(i64), t.17{r6}(u8)
        movzx rdx, bl
        ; call printStringLength[t.13{r1}, t.16{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void printIntLf
        ;   rsp+32: arg number
@printIntLf:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
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
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint[number{r1}]
        sub rsp, 20h; shadow space
        call @printUint
        add rsp, 20h
        ; const t.3{r1}, 10
        mov cl, 10
        ; call printChar[t.3{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
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
        ; add t.4{r2}, t.4{r2}, t.6{r3}
        add rdx, r8
        ; cast str{r1}(u8*), t.4{r2}(i64)
        mov rcx, rdx
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
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; call printLength[]
        sub rsp, 20h; shadow space
        call @printLength
        add rsp, 20h
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
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move tmp.text{r6}, text
        lea r11, [var_0]
        mov rbx, [r11]
        ; load chr{r6}, [tmp.text{r6}]
        mov bl, [rbx]
        ; cast t.4{r1}(i64), chr{r6}(u8)
        movzx rcx, bl
        ; call printIntLf[t.4{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
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
        ; add t.4{r0}, t.4{r0}, t.6{r2}
        add rax, rdx
        ; cast ptr{r7}(u8*), t.4{r0}(i64)
        mov r12, rax
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
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
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
