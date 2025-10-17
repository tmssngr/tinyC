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
        ;   rsp+48: var c
        ;   rsp+49: var d
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.4{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString[t.4{r1}]
        call @printString
        ; const a{r6}, 1
        mov bx, 1
        ; const b{r7}, 2
        mov r12w, 2
        ; lt t.6{r0}, a{r6}, b{r7}
        cmp bx, r12w
        setl al
        ; cast t.5{r1}(i64), t.6{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.5{r1}]
        call @printIntLf
        ; lt t.8{r0}, b{r7}, a{r6}
        cmp r12w, bx
        setl al
        ; cast t.7{r1}(i64), t.8{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.7{r1}]
        call @printIntLf
        ; const t.9{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString[t.9{r1}]
        call @printString
        ; const c{r0}, 0
        mov al, 0
        ; const d{r2}, 128
        mov dl, 128
        ; lt t.11{r3}, c{r0}, d{r2}
        cmp al, dl
        setb r8b
        ; move c, c{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move d, d{r2}
        lea r11, [rsp+49]
        mov [r11], dl
        ; cast t.10{r1}(i64), t.11{r3}(bool)
        movzx rcx, r8b
        ; call printIntLf[t.10{r1}]
        call @printIntLf
        ; move c{r2}, c
        lea r11, [rsp+48]
        mov dl, [r11]
        ; move d{r0}, d
        lea r11, [rsp+49]
        mov al, [r11]
        ; lt t.13{r3}, d{r0}, c{r2}
        cmp al, dl
        setb r8b
        ; move c, c{r2}
        lea r11, [rsp+48]
        mov [r11], dl
        ; move d, d{r0}
        lea r11, [rsp+49]
        mov [r11], al
        ; cast t.12{r1}(i64), t.13{r3}(bool)
        movzx rcx, r8b
        ; call printIntLf[t.12{r1}]
        call @printIntLf
        ; const t.14{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString[t.14{r1}]
        call @printString
        ; lteq t.16{r0}, a{r6}, b{r7}
        cmp bx, r12w
        setle al
        ; cast t.15{r1}(i64), t.16{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.15{r1}]
        call @printIntLf
        ; lteq t.18{r0}, b{r7}, a{r6}
        cmp r12w, bx
        setle al
        ; cast t.17{r1}(i64), t.18{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.17{r1}]
        call @printIntLf
        ; const t.19{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString[t.19{r1}]
        call @printString
        ; move c{r0}, c
        lea r11, [rsp+48]
        mov al, [r11]
        ; move d{r2}, d
        lea r11, [rsp+49]
        mov dl, [r11]
        ; lteq t.21{r3}, c{r0}, d{r2}
        cmp al, dl
        setbe r8b
        ; move c, c{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move d, d{r2}
        lea r11, [rsp+49]
        mov [r11], dl
        ; cast t.20{r1}(i64), t.21{r3}(bool)
        movzx rcx, r8b
        ; call printIntLf[t.20{r1}]
        call @printIntLf
        ; move c{r2}, c
        lea r11, [rsp+48]
        mov dl, [r11]
        ; move d{r0}, d
        lea r11, [rsp+49]
        mov al, [r11]
        ; lteq t.23{r3}, d{r0}, c{r2}
        cmp al, dl
        setbe r8b
        ; move c, c{r2}
        lea r11, [rsp+48]
        mov [r11], dl
        ; move d, d{r0}
        lea r11, [rsp+49]
        mov [r11], al
        ; cast t.22{r1}(i64), t.23{r3}(bool)
        movzx rcx, r8b
        ; call printIntLf[t.22{r1}]
        call @printIntLf
        ; const t.24{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString[t.24{r1}]
        call @printString
        ; equals t.26{r0}, a{r6}, b{r7}
        cmp bx, r12w
        sete al
        ; cast t.25{r1}(i64), t.26{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.25{r1}]
        call @printIntLf
        ; equals t.28{r0}, b{r7}, a{r6}
        cmp r12w, bx
        sete al
        ; cast t.27{r1}(i64), t.28{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.27{r1}]
        call @printIntLf
        ; const t.29{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString[t.29{r1}]
        call @printString
        ; notequals t.31{r0}, a{r6}, b{r7}
        cmp bx, r12w
        setne al
        ; cast t.30{r1}(i64), t.31{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.30{r1}]
        call @printIntLf
        ; notequals t.33{r0}, b{r7}, a{r6}
        cmp r12w, bx
        setne al
        ; cast t.32{r1}(i64), t.33{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.32{r1}]
        call @printIntLf
        ; const t.34{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString[t.34{r1}]
        call @printString
        ; gteq t.36{r0}, a{r6}, b{r7}
        cmp bx, r12w
        setge al
        ; cast t.35{r1}(i64), t.36{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.35{r1}]
        call @printIntLf
        ; gteq t.38{r0}, b{r7}, a{r6}
        cmp r12w, bx
        setge al
        ; cast t.37{r1}(i64), t.38{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.37{r1}]
        call @printIntLf
        ; const t.39{r1}, [string-7]
        lea rcx, [string_7]
        ; call printString[t.39{r1}]
        call @printString
        ; move c{r0}, c
        lea r11, [rsp+48]
        mov al, [r11]
        ; move d{r2}, d
        lea r11, [rsp+49]
        mov dl, [r11]
        ; gteq t.41{r3}, c{r0}, d{r2}
        cmp al, dl
        setae r8b
        ; move c, c{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move d, d{r2}
        lea r11, [rsp+49]
        mov [r11], dl
        ; cast t.40{r1}(i64), t.41{r3}(bool)
        movzx rcx, r8b
        ; call printIntLf[t.40{r1}]
        call @printIntLf
        ; move c{r2}, c
        lea r11, [rsp+48]
        mov dl, [r11]
        ; move d{r0}, d
        lea r11, [rsp+49]
        mov al, [r11]
        ; gteq t.43{r3}, d{r0}, c{r2}
        cmp al, dl
        setae r8b
        ; move c, c{r2}
        lea r11, [rsp+48]
        mov [r11], dl
        ; move d, d{r0}
        lea r11, [rsp+49]
        mov [r11], al
        ; cast t.42{r1}(i64), t.43{r3}(bool)
        movzx rcx, r8b
        ; call printIntLf[t.42{r1}]
        call @printIntLf
        ; const t.44{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString[t.44{r1}]
        call @printString
        ; gt t.46{r0}, a{r6}, b{r7}
        cmp bx, r12w
        setg al
        ; cast t.45{r1}(i64), t.46{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.45{r1}]
        call @printIntLf
        ; gt t.48{r6}, b{r7}, a{r6}
        cmp r12w, bx
        setg bl
        ; cast t.47{r1}(i64), t.48{r6}(bool)
        movzx rcx, bl
        ; call printIntLf[t.47{r1}]
        call @printIntLf
        ; const t.49{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString[t.49{r1}]
        call @printString
        ; move c{r6}, c
        lea r11, [rsp+48]
        mov bl, [r11]
        ; move d{r7}, d
        lea r11, [rsp+49]
        mov r12b, [r11]
        ; gt t.51{r0}, c{r6}, d{r7}
        cmp bl, r12b
        seta al
        ; cast t.50{r1}(i64), t.51{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.50{r1}]
        call @printIntLf
        ; gt t.53{r6}, d{r7}, c{r6}
        cmp r12b, bl
        seta bl
        ; cast t.52{r1}(i64), t.53{r6}(bool)
        movzx rcx, bl
        ; call printIntLf[t.52{r1}]
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

section '.data' data readable
        string_0 db '< (signed)', 0x0a, 0x00
        string_1 db '< (unsigned)', 0x0a, 0x00
        string_2 db '<= (signed)', 0x0a, 0x00
        string_3 db '<= (unsigned)', 0x0a, 0x00
        string_4 db '==', 0x0a, 0x00
        string_5 db '!=', 0x0a, 0x00
        string_6 db '>= (signed)', 0x0a, 0x00
        string_7 db '>= (unsigned)', 0x0a, 0x00
        string_8 db '> (signed)', 0x0a, 0x00
        string_9 db '> (unsigned)', 0x0a, 0x00

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
