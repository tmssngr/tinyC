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

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_1
@for_1_body:
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
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp dl, 0
        setne dl
        ; branch t.2{r2}, true, @for_1_body
        or dl, dl
        jnz @for_1_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void printBoard
@printBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; const t.1{r1}, 124
        mov cl, 124
        ; call printChar[t.1{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const i{r6}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp @for_2
@for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.6{r7}(i64), i{r6}(u8)
        movzx r12, bl
        ; cast t.7{r7}(u8*), t.6{r7}(i64)
        ; addrof t.5{r0}, [board]
        lea rax, [var_0]
        ; add t.5{r0}, t.5{r0}, t.7{r7}
        add rax, r12
        ; load t.4{r7}, [t.5{r0}]
        mov r12b, [rax]
        ; equals t.3{r7}, t.4{r7}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.3{r7}, true, @if_3_then
        or r12b, r12b
        jnz @if_3_then
        ; const t.9{r1}, 42
        mov cl, 42
        ; call printChar[t.9{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        jmp @for_2_continue
@if_3_then:
        ; const t.8{r1}, 32
        mov cl, 32
        ; call printChar[t.8{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@for_2_continue:
        ; inc i{r6}
        inc bl
@for_2:
        ; lt t.2{r7}, i{r6}, 30
        cmp bl, 30
        setb r12b
        ; branch t.2{r7}, true, @for_2_body
        or r12b, r12b
        jnz @for_2_body
        ; const t.10{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString[t.10{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const i{r6}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp @for_4
@for_4_body:
        ; const t.5{r7}, 0
        mov r12b, 0
        ; cast t.7{r0}(i64), i{r6}(u8)
        movzx rax, bl
        ; cast t.8{r0}(u8*), t.7{r0}(i64)
        ; addrof t.6{r1}, [board]
        lea rcx, [var_0]
        ; add t.6{r1}, t.6{r1}, t.8{r0}
        add rcx, rax
        ; store [t.6{r1}], t.5{r7}
        mov [rcx], r12b
        ; inc i{r6}
        inc bl
@for_4:
        ; lt t.4{r7}, i{r6}, 30
        cmp bl, 30
        setb r12b
        ; branch t.4{r7}, true, @for_4_body
        or r12b, r12b
        jnz @for_4_body
        ; const t.9{r6}, 1
        mov bl, 1
        ; const t.12{r7}, 29
        mov r12b, 29
        ; cast t.11{r7}(i64), t.12{r7}(u8)
        movzx r12, r12b
        ; cast t.13{r7}(u8*), t.11{r7}(i64)
        ; addrof t.10{r0}, [board]
        lea rax, [var_0]
        ; add t.10{r0}, t.10{r0}, t.13{r7}
        add rax, r12
        ; store [t.10{r0}], t.9{r6}
        mov [rax], bl
        ; call printBoard[]
        sub rsp, 20h; shadow space
        call @printBoard
        add rsp, 20h
        ; const i{r6}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp @for_5
@for_5_body:
        ; const t.18{r7}, 0
        mov r12, 0
        ; cast t.19{r7}(u8*), t.18{r7}(i64)
        ; addrof t.17{r0}, [board]
        lea rax, [var_0]
        ; add t.17{r0}, t.17{r0}, t.19{r7}
        add rax, r12
        ; load t.16{r7}, [t.17{r0}]
        mov r12b, [rax]
        ; const t.20{r1}, 1
        mov cl, 1
        ; shiftleft t.15{r7}, t.15{r7}, t.20{r1}
        shl r12b, cl
        ; const t.23{r0}, 1
        mov rax, 1
        ; cast t.24{r0}(u8*), t.23{r0}(i64)
        ; addrof t.22{r2}, [board]
        lea rdx, [var_0]
        ; add t.22{r2}, t.22{r2}, t.24{r0}
        add rdx, rax
        ; load t.21{r0}, [t.22{r2}]
        mov al, [rdx]
        ; or pattern{r7}, pattern{r7}, t.21{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp @for_6
@for_6_body:
        ; const t.28{r1}, 1
        mov cl, 1
        ; move t.27{r2}, pattern{r7}
        mov dl, r12b
        ; shiftleft t.27{r2}, t.27{r2}, t.28{r1}
        shl dl, cl
        ; const t.29{r3}, 7
        mov r8b, 7
        ; move t.26{r7}, t.27{r2}
        mov r12b, dl
        ; and t.26{r7}, t.26{r7}, t.29{r3}
        and r12b, r8b
        ; const t.34{r2}, 1
        mov dl, 1
        ; move t.33{r3}, j{r0}
        mov r8b, al
        ; add t.33{r3}, t.33{r3}, t.34{r2}
        add r8b, dl
        ; cast t.32{r2}(i64), t.33{r3}(u8)
        movzx rdx, r8b
        ; cast t.35{r2}(u8*), t.32{r2}(i64)
        ; addrof t.31{r3}, [board]
        lea r8, [var_0]
        ; add t.31{r3}, t.31{r3}, t.35{r2}
        add r8, rdx
        ; load t.30{r2}, [t.31{r3}]
        mov dl, [r8]
        ; or pattern{r7}, pattern{r7}, t.30{r2}
        or r12b, dl
        ; const t.38{r2}, 110
        mov dl, 110
        ; move pattern{r1}, pattern{r7}
        mov cl, r12b
        ; shiftright t.37{r2}, t.37{r2}, pattern{r1}
        shr dl, cl
        ; const t.39{r1}, 1
        mov cl, 1
        ; and t.36{r2}, t.36{r2}, t.39{r1}
        and dl, cl
        ; cast t.41{r1}(i64), j{r0}(u8)
        movzx rcx, al
        ; cast t.42{r1}(u8*), t.41{r1}(i64)
        ; addrof t.40{r3}, [board]
        lea r8, [var_0]
        ; add t.40{r3}, t.40{r3}, t.42{r1}
        add r8, rcx
        ; store [t.40{r3}], t.36{r2}
        mov [r8], dl
        ; inc j{r0}
        inc al
@for_6:
        ; lt t.25{r1}, j{r0}, 29
        cmp al, 29
        setb cl
        ; branch t.25{r1}, true, @for_6_body
        or cl, cl
        jnz @for_6_body
        ; call printBoard[]
        sub rsp, 20h; shadow space
        call @printBoard
        add rsp, 20h
        ; inc i{r6}
        inc bl
@for_5:
        ; lt t.14{r0}, i{r6}, 28
        cmp bl, 28
        setb al
        ; branch t.14{r0}, true, @for_5_body
        or al, al
        jnz @for_5_body
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
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

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
