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

        ; void printNibble
        ;   rsp+16: arg x
@printNibble:
        ; save clobbered non-volatile registers
        push rbx
        ; const t.1{r6}, 15
        mov bl, 15
        ; and x{r1}, x{r1}, t.1{r6}
        and cl, bl
        ; 5:2 if x > 9
        ; gt t.2{r6}, x{r1}, 9
        cmp cl, 9
        seta bl
        ; branch t.2{r6}, false, @if_2_end
        or bl, bl
        jz @if_2_end
        ; add x{r1}, 7
        add cl, 7
@if_2_end:
        ; add x{r1}, 48
        add cl, 48
        ; call printChar[x{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printHex2
        ;   rsp+32: arg x
@printHex2:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move x{r6}, x{r1}
        mov bl, cl
        ; const t.2{r1}, 4
        mov cl, 4
        ; move t.1{r7}, x{r6}
        mov r12b, bl
        ; shiftright t.1{r7}, t.1{r7}, t.2{r1}
        shr r12b, cl
        ; move t.1{r1}, t.1{r7}
        mov cl, r12b
        ; call printNibble[t.1{r1}]
        sub rsp, 20h; shadow space
        call @printNibble
        add rsp, 20h
        ; move x{r1}, x{r6}
        mov cl, bl
        ; call printNibble[x{r1}]
        sub rsp, 20h; shadow space
        call @printNibble
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
        ; const t.2{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString[t.2{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const i{r6}, 0
        mov bl, 0
        ; 19:2 for i < 16
        jmp @for_3
@for_3_body:
        ; 20:3 if i & 7 == 0
        ; const t.6{r7}, 7
        mov r12b, 7
        ; move t.5{r0}, i{r6}
        mov al, bl
        ; and t.5{r0}, t.5{r0}, t.6{r7}
        and al, r12b
        ; equals t.4{r7}, t.5{r0}, 0
        cmp al, 0
        sete r12b
        ; branch t.4{r7}, false, @if_4_end
        or r12b, r12b
        jz @if_4_end
        ; const t.7{r1}, 32
        mov cl, 32
        ; call printChar[t.7{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@if_4_end:
        ; move i{r1}, i{r6}
        mov cl, bl
        ; call printNibble[i{r1}]
        sub rsp, 20h; shadow space
        call @printNibble
        add rsp, 20h
        ; inc i{r6}
        inc bl
@for_3:
        ; lt t.3{r7}, i{r6}, 16
        cmp bl, 16
        setb r12b
        ; branch t.3{r7}, true, @for_3_body
        or r12b, r12b
        jnz @for_3_body
        ; const t.8{r1}, 10
        mov cl, 10
        ; call printChar[t.8{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const i{r6}, 32
        mov bl, 32
        ; 27:2 for i < 128
        jmp @for_5
@for_5_body:
        ; 28:3 if i & 15 == 0
        ; const t.12{r7}, 15
        mov r12b, 15
        ; move t.11{r0}, i{r6}
        mov al, bl
        ; and t.11{r0}, t.11{r0}, t.12{r7}
        and al, r12b
        ; equals t.10{r7}, t.11{r0}, 0
        cmp al, 0
        sete r12b
        ; branch t.10{r7}, false, @if_6_end
        or r12b, r12b
        jz @if_6_end
        ; move i{r1}, i{r6}
        mov cl, bl
        ; call printHex2[i{r1}]
        sub rsp, 20h; shadow space
        call @printHex2
        add rsp, 20h
@if_6_end:
        ; 31:3 if i & 7 == 0
        ; const t.15{r7}, 7
        mov r12b, 7
        ; move t.14{r0}, i{r6}
        mov al, bl
        ; and t.14{r0}, t.14{r0}, t.15{r7}
        and al, r12b
        ; equals t.13{r7}, t.14{r0}, 0
        cmp al, 0
        sete r12b
        ; branch t.13{r7}, false, @if_7_end
        or r12b, r12b
        jz @if_7_end
        ; const t.16{r1}, 32
        mov cl, 32
        ; call printChar[t.16{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@if_7_end:
        ; move i{r1}, i{r6}
        mov cl, bl
        ; call printChar[i{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; 35:3 if i & 15 == 15
        ; const t.19{r7}, 15
        mov r12b, 15
        ; move t.18{r0}, i{r6}
        mov al, bl
        ; and t.18{r0}, t.18{r0}, t.19{r7}
        and al, r12b
        ; equals t.17{r7}, t.18{r0}, 15
        cmp al, 15
        sete r12b
        ; branch t.17{r7}, false, @for_5_continue
        or r12b, r12b
        jz @for_5_continue
        ; const t.20{r1}, 10
        mov cl, 10
        ; call printChar[t.20{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
@for_5_continue:
        ; inc i{r6}
        inc bl
@for_5:
        ; lt t.9{r0}, i{r6}, 128
        cmp bl, 128
        setb al
        ; branch t.9{r0}, true, @for_5_body
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
