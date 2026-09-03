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
        ;   rsp+64: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+64]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call @printStringLength@@u8@u8
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
        ; 69:2 for *str != 0
        jmp @for_1
@for_1_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rcx, 1
@for_1:
        ; load t.3{r2}, [str{r1}]
        mov dl, [rcx]
        ; notequals t.2{r2}, t.3{r2}, 0
        cmp dl, 0
        setne dl
        ; branch t.2{r2}, true, @for_1_body, @for_1_break
        or dl, dl
        jnz @for_1_body
        ; 72:9 return length
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

        ; void printNibble@u8
        ;   rsp+48: arg x
@printNibble@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; and x{r1}, x{r1}, 15
        and cl, 15
        ; 5:2 if x > 9
        ; gt t.1{r6}, x{r1}, 9
        cmp cl, 9
        seta bl
        ; branch t.1{r6}, false, @if_2_end, @if_2_then
        or bl, bl
        jz @if_2_end
        ; add x{r1}, x{r1}, 7
        add cl, 7
@if_2_end:
        ; add x{r1}, x{r1}, 48
        add cl, 48
        ; call printChar@u8[x{r1}]
        call @printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printHex2@u8
        ;   rsp+48: arg x
@printHex2@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move x{r6}, x{r1}
        mov bl, cl
        ; move t.1{r1}, x{r6}
        mov cl, bl
        ; shiftright t.1{r1}, t.1{r1}, 4
        shr cl, 4
        ; call printNibble@u8[t.1{r1}]
        call @printNibble@u8
        ; move x{r1}, x{r6}
        mov cl, bl
        ; call printNibble@u8[x{r1}]
        call @printNibble@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const t.2{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.2{r1}]
        call @printString@@u8
        ; const i{r6}, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; move t.5{r7}, i{r6}
        mov r12b, bl
        ; and t.5{r7}, t.5{r7}, 7
        and r12b, 7
        ; equals t.4{r7}, t.5{r7}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.4{r7}, false, @if_4_end, @if_4_then
        or r12b, r12b
        jz @if_4_end
        ; const arg.1.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.1.0{r1}]
        call @printChar@u8
@if_4_end:
        ; move i{r1}, i{r6}
        mov cl, bl
        ; call printNibble@u8[i{r1}]
        call @printNibble@u8
        ; add i{r6}, i{r6}, 1
        add bl, 1
@for_3:
        ; lt t.3{r7}, i{r6}, 16
        cmp bl, 16
        setb r12b
        ; branch t.3{r7}, true, @for_3_body, @for_3_break
        or r12b, r12b
        jnz @for_3_body
        ; const arg.3.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.3.0{r1}]
        call @printChar@u8
        ; const i{r6}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; move t.8{r7}, i{r6}
        mov r12b, bl
        ; and t.8{r7}, t.8{r7}, 15
        and r12b, 15
        ; equals t.7{r7}, t.8{r7}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.7{r7}, false, @if_6_end, @if_6_then
        or r12b, r12b
        jz @if_6_end
        ; move i{r1}, i{r6}
        mov cl, bl
        ; call printHex2@u8[i{r1}]
        call @printHex2@u8
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; move t.10{r7}, i{r6}
        mov r12b, bl
        ; and t.10{r7}, t.10{r7}, 7
        and r12b, 7
        ; equals t.9{r7}, t.10{r7}, 0
        cmp r12b, 0
        sete r12b
        ; branch t.9{r7}, false, @if_7_end, @if_7_then
        or r12b, r12b
        jz @if_7_end
        ; const arg.5.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.5.0{r1}]
        call @printChar@u8
@if_7_end:
        ; move i{r1}, i{r6}
        mov cl, bl
        ; call printChar@u8[i{r1}]
        call @printChar@u8
        ; 35:3 if i & 15 == 15
        ; move t.12{r7}, i{r6}
        mov r12b, bl
        ; and t.12{r7}, t.12{r7}, 15
        and r12b, 15
        ; equals t.11{r7}, t.12{r7}, 15
        cmp r12b, 15
        sete r12b
        ; branch t.11{r7}, false, @for_5_continue, @if_8_then
        or r12b, r12b
        jz @for_5_continue
        ; const arg.7.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.7.0{r1}]
        call @printChar@u8
@for_5_continue:
        ; add i{r6}, i{r6}, 1
        add bl, 1
@for_5:
        ; lt t.6{r0}, i{r6}, 128
        cmp bl, 128
        setb al
        ; branch t.6{r0}, true, @for_5_body, @main_ret
        or al, al
        jnz @for_5_body
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

section '.data' data readable
        string_0 db ' x', 0x00

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
