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
        ;   rsp+50: var d
        ;   rsp+52: var t
        ;   rsp+53: var f
        ;   rsp+54: var b1
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.9{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString[t.9{r1}]
        call @printString
        ; const a{r6}, 0
        mov bx, 0
        ; const b{r7}, 1
        mov r12w, 1
        ; const c{r0}, 2
        mov ax, 2
        ; move c, c{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const d{r0}, 3
        mov ax, 3
        ; move d, d{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; const t{r0}, 1
        mov al, 1
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; const f{r0}, 0
        mov al, 0
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; move t.11{r0}, a{r6}
        mov ax, bx
        ; and t.11{r0}, t.11{r0}, a{r6}
        and ax, bx
        ; cast t.10{r1}(i64), t.11{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.10{r1}]
        call @printIntLf
        ; move t.13{r0}, a{r6}
        mov ax, bx
        ; and t.13{r0}, t.13{r0}, b{r7}
        and ax, r12w
        ; cast t.12{r1}(i64), t.13{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.12{r1}]
        call @printIntLf
        ; move t.15{r0}, b{r7}
        mov ax, r12w
        ; and t.15{r0}, t.15{r0}, a{r6}
        and ax, bx
        ; cast t.14{r1}(i64), t.15{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.14{r1}]
        call @printIntLf
        ; move t.17{r0}, b{r7}
        mov ax, r12w
        ; and t.17{r0}, t.17{r0}, b{r7}
        and ax, r12w
        ; cast t.16{r1}(i64), t.17{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.16{r1}]
        call @printIntLf
        ; const t.18{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString[t.18{r1}]
        call @printString
        ; move t.20{r0}, a{r6}
        mov ax, bx
        ; or t.20{r0}, t.20{r0}, a{r6}
        or ax, bx
        ; cast t.19{r1}(i64), t.20{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.19{r1}]
        call @printIntLf
        ; move t.22{r0}, a{r6}
        mov ax, bx
        ; or t.22{r0}, t.22{r0}, b{r7}
        or ax, r12w
        ; cast t.21{r1}(i64), t.22{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.21{r1}]
        call @printIntLf
        ; move t.24{r0}, b{r7}
        mov ax, r12w
        ; or t.24{r0}, t.24{r0}, a{r6}
        or ax, bx
        ; cast t.23{r1}(i64), t.24{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.23{r1}]
        call @printIntLf
        ; move t.26{r0}, b{r7}
        mov ax, r12w
        ; or t.26{r0}, t.26{r0}, b{r7}
        or ax, r12w
        ; cast t.25{r1}(i64), t.26{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.25{r1}]
        call @printIntLf
        ; const t.27{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString[t.27{r1}]
        call @printString
        ; move t.29{r0}, a{r6}
        mov ax, bx
        ; xor t.29{r0}, t.29{r0}, a{r6}
        xor ax, bx
        ; cast t.28{r1}(i64), t.29{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.28{r1}]
        call @printIntLf
        ; move t.31{r0}, a{r6}
        mov ax, bx
        ; move c{r2}, c
        lea r11, [rsp+48]
        mov dx, [r11]
        ; xor t.31{r0}, t.31{r0}, c{r2}
        xor ax, dx
        ; move c, c{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; cast t.30{r1}(i64), t.31{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.30{r1}]
        call @printIntLf
        ; move t.33{r0}, b{r7}
        mov ax, r12w
        ; xor t.33{r0}, t.33{r0}, a{r6}
        xor ax, bx
        ; cast t.32{r1}(i64), t.33{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.32{r1}]
        call @printIntLf
        ; move t.35{r6}, b{r7}
        mov bx, r12w
        ; move c{r0}, c
        lea r11, [rsp+48]
        mov ax, [r11]
        ; xor t.35{r6}, t.35{r6}, c{r0}
        xor bx, ax
        ; move c, c{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; cast t.34{r1}(i64), t.35{r6}(i16)
        movzx rcx, bx
        ; call printIntLf[t.34{r1}]
        call @printIntLf
        ; const t.36{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString[t.36{r1}]
        call @printString
        ; 26:15 logic and
        ; move f{r6}, f
        lea r11, [rsp+53]
        mov bl, [r11]
        ; move t.38{r0}, f{r6}
        mov al, bl
        ; branch t.38{r0}, false, @and_next_5
        or al, al
        jz @and_next_5
        ; move t.38{r0}, f{r6}
        mov al, bl
@and_next_5:
        ; cast t.37{r1}(i64), t.38{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.37{r1}]
        call @printIntLf
        ; 27:15 logic and
        ; move t.40{r0}, f{r6}
        mov al, bl
        ; branch t.40{r0}, false, @and_next_6
        or al, al
        jz @and_next_6
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
@and_next_6:
        ; cast t.39{r1}(i64), t.40{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.39{r1}]
        call @printIntLf
        ; 28:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.42{r2}, t{r0}
        mov dl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; branch t.42{r2}, false, @and_next_7
        or dl, dl
        jz @and_next_7
        ; move t.42{r2}, f{r6}
        mov dl, bl
@and_next_7:
        ; cast t.41{r1}(i64), t.42{r2}(bool)
        movzx rcx, dl
        ; call printIntLf[t.41{r1}]
        call @printIntLf
        ; 29:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.44{r2}, t{r0}
        mov dl, al
        ; branch t.44{r2}, false, @and_next_8
        or dl, dl
        jz @and_next_8
        ; move t.44{r2}, t{r0}
        mov dl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
@and_next_8:
        ; cast t.43{r1}(i64), t.44{r2}(bool)
        movzx rcx, dl
        ; call printIntLf[t.43{r1}]
        call @printIntLf
        ; const t.45{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString[t.45{r1}]
        call @printString
        ; 31:15 logic or
        ; move t.47{r0}, f{r6}
        mov al, bl
        ; branch t.47{r0}, true, @or_next_9
        or al, al
        jnz @or_next_9
        ; move t.47{r0}, f{r6}
        mov al, bl
@or_next_9:
        ; cast t.46{r1}(i64), t.47{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.46{r1}]
        call @printIntLf
        ; 32:15 logic or
        ; move t.49{r0}, f{r6}
        mov al, bl
        ; branch t.49{r0}, true, @or_next_10
        or al, al
        jnz @or_next_10
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
@or_next_10:
        ; cast t.48{r1}(i64), t.49{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.48{r1}]
        call @printIntLf
        ; 33:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.51{r2}, t{r0}
        mov dl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; branch t.51{r2}, true, @or_next_11
        or dl, dl
        jnz @or_next_11
        ; move t.51{r2}, f{r6}
        mov dl, bl
@or_next_11:
        ; cast t.50{r1}(i64), t.51{r2}(bool)
        movzx rcx, dl
        ; call printIntLf[t.50{r1}]
        call @printIntLf
        ; 34:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.53{r2}, t{r0}
        mov dl, al
        ; branch t.53{r2}, true, @or_next_12
        or dl, dl
        jnz @or_next_12
        ; move t.53{r2}, t{r0}
        mov dl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
@or_next_12:
        ; cast t.52{r1}(i64), t.53{r2}(bool)
        movzx rcx, dl
        ; call printIntLf[t.52{r1}]
        call @printIntLf
        ; const t.54{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString[t.54{r1}]
        call @printString
        ; notlog t.56{r6}, f{r6}
        or bl, bl
        sete bl
        ; cast t.55{r1}(i64), t.56{r6}(bool)
        movzx rcx, bl
        ; call printIntLf[t.55{r1}]
        call @printIntLf
        ; move t{r6}, t
        lea r11, [rsp+52]
        mov bl, [r11]
        ; notlog t.58{r6}, t{r6}
        or bl, bl
        sete bl
        ; cast t.57{r1}(i64), t.58{r6}(bool)
        movzx rcx, bl
        ; call printIntLf[t.57{r1}]
        call @printIntLf
        ; const t.59{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString[t.59{r1}]
        call @printString
        ; const b10{r6}, 10
        mov bl, 10
        ; const b6{r0}, 6
        mov al, 6
        ; const b1{r2}, 1
        mov dl, 1
        ; and t.62{r6}, t.62{r6}, b6{r0}
        and bl, al
        ; or t.61{r6}, t.61{r6}, b1{r2}
        or bl, dl
        ; move b1, b1{r2}
        lea r11, [rsp+54]
        mov [r11], dl
        ; cast t.60{r1}(i64), t.61{r6}(u8)
        movzx rcx, bl
        ; call printIntLf[t.60{r1}]
        call @printIntLf
        ; 43:20 logic or
        ; move c{r6}, c
        lea r11, [rsp+48]
        mov bx, [r11]
        ; equals t.64{r0}, b{r7}, c{r6}
        cmp r12w, bx
        sete al
        ; branch t.64{r0}, true, @or_next_13
        or al, al
        jnz @or_next_13
        ; move d{r0}, d
        lea r11, [rsp+50]
        mov ax, [r11]
        ; lt t.64{r0}, c{r6}, d{r0}
        cmp bx, ax
        setl al
        ; move d, d{r0}
        lea r11, [rsp+50]
        mov [r11], ax
@or_next_13:
        ; cast t.63{r1}(i64), t.64{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.63{r1}]
        call @printIntLf
        ; 44:20 logic and
        ; equals t.66{r0}, b{r7}, c{r6}
        cmp r12w, bx
        sete al
        ; branch t.66{r0}, false, @and_next_14
        or al, al
        jz @and_next_14
        ; move d{r0}, d
        lea r11, [rsp+50]
        mov ax, [r11]
        ; lt t.66{r0}, c{r6}, d{r0}
        cmp bx, ax
        setl al
@and_next_14:
        ; cast t.65{r1}(i64), t.66{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.65{r1}]
        call @printIntLf
        ; const t.68{r6}, -1
        mov bx, -1
        ; cast t.67{r1}(i64), t.68{r6}(i16)
        movzx rcx, bx
        ; call printIntLf[t.67{r1}]
        call @printIntLf
        ; neg t.70{r6}, b{r7}
        mov rbx, r12
        neg rbx
        ; cast t.69{r1}(i64), t.70{r6}(i16)
        movzx rcx, bx
        ; call printIntLf[t.69{r1}]
        call @printIntLf
        ; move b1{r6}, b1
        lea r11, [rsp+54]
        mov bl, [r11]
        ; not t.72{r6}, b1{r6}
        not rbx
        ; cast t.71{r1}(i64), t.72{r6}(u8)
        movzx rcx, bl
        ; call printIntLf[t.71{r1}]
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
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

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
