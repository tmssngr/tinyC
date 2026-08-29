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
        ; addrof t.10{r4}, [buffer]
        lea r9, [rsp+40]
        ; add t.10{r4}, t.10{r4}, t.11{r3}
        add r9, r8
        ; store [t.10{r4}], digit{r0}
        mov [r9], al
        ; 31:3 if number == 0
        ; const t.13{r0}, 0
        mov rax, 0
        ; equals t.12{r0}, number{r1}, t.13{r0}
        cmp rcx, rax
        sete al
        ; branch t.12{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.15{r0}(i64), pos{r6}(u8)
        movzx rax, bl
        ; addrof t.14{r1}, [buffer]
        lea rcx, [rsp+40]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rcx, rax
        ; const t.17{r0}, 20
        mov al, 20
        ; move t.16{r2}, t.17{r0}
        mov dl, al
        ; sub t.16{r2}, t.16{r2}, pos{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.14{r1}, t.16{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
        ret

        ; void printIntLf@bool
        ;   rsp+48: arg number
@printIntLf@bool:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(bool)
        movzx rcx, cl
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
        ; const t.6{r2}, 1
        mov rdx, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rcx, rdx
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
        ;   rsp+48: var b
        ;   rsp+50: var c
        ;   rsp+51: var d
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
        ; call printString@@u8[t.4{r1}]
        call @printString@@u8
        ; const a{r6}, 1
        mov bx, 1
        ; const b{r0}, 2
        mov ax, 2
        ; lt t.5{r1}, a{r6}, b{r0}
        cmp bx, ax
        setl cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.5{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; lt t.6{r1}, b{r0}, a{r6}
        cmp ax, bx
        setl cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.6{r1}]
        call @printIntLf@bool
        ; const t.7{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.7{r1}]
        call @printString@@u8
        ; const c{r0}, 0
        mov al, 0
        ; const d{r2}, 128
        mov dl, 128
        ; lt t.8{r1}, c{r0}, d{r2}
        cmp al, dl
        setb cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r2}
        mov [r12], dl
        ; call printIntLf@bool[t.8{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; lt t.9{r1}, d{r0}, c{r2}
        cmp al, dl
        setb cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.9{r1}]
        call @printIntLf@bool
        ; const t.10{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.10{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; lteq t.11{r1}, a{r6}, b{r0}
        cmp bx, ax
        setle cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.11{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; lteq t.12{r1}, b{r0}, a{r6}
        cmp ax, bx
        setle cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.12{r1}]
        call @printIntLf@bool
        ; const t.13{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.13{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; lteq t.14{r1}, c{r0}, d{r2}
        cmp al, dl
        setbe cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r2}
        mov [r12], dl
        ; call printIntLf@bool[t.14{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; lteq t.15{r1}, d{r0}, c{r2}
        cmp al, dl
        setbe cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.15{r1}]
        call @printIntLf@bool
        ; const t.16{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.16{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; equals t.17{r1}, a{r6}, b{r0}
        cmp bx, ax
        sete cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.17{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; equals t.18{r1}, b{r0}, a{r6}
        cmp ax, bx
        sete cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.18{r1}]
        call @printIntLf@bool
        ; const t.19{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.19{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; notequals t.20{r1}, a{r6}, b{r0}
        cmp bx, ax
        setne cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.20{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; notequals t.21{r1}, b{r0}, a{r6}
        cmp ax, bx
        setne cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.21{r1}]
        call @printIntLf@bool
        ; const t.22{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString@@u8[t.22{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; gteq t.23{r1}, a{r6}, b{r0}
        cmp bx, ax
        setge cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.23{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; gteq t.24{r1}, b{r0}, a{r6}
        cmp ax, bx
        setge cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.24{r1}]
        call @printIntLf@bool
        ; const t.25{r1}, [string-7]
        lea rcx, [string_7]
        ; call printString@@u8[t.25{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; gteq t.26{r1}, c{r0}, d{r2}
        cmp al, dl
        setae cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r2}
        mov [r12], dl
        ; call printIntLf@bool[t.26{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r2}, [memVarAddr{r7}]
        mov dl, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; gteq t.27{r1}, d{r0}, c{r2}
        cmp al, dl
        setae cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r2}
        mov [r12], dl
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.27{r1}]
        call @printIntLf@bool
        ; const t.28{r1}, [string-8]
        lea rcx, [string_8]
        ; call printString@@u8[t.28{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; gt t.29{r1}, a{r6}, b{r0}
        cmp bx, ax
        setg cl
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.29{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; gt t.30{r1}, b{r0}, a{r6}
        cmp ax, bx
        setg cl
        ; call printIntLf@bool[t.30{r1}]
        call @printIntLf@bool
        ; const t.31{r1}, [string-9]
        lea rcx, [string_9]
        ; call printString@@u8[t.31{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; gt t.32{r1}, c{r6}, d{r0}
        cmp bl, al
        seta cl
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; store [memVarAddr{r7}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.32{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+51]
        ; load d{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; gt t.33{r1}, d{r0}, c{r6}
        cmp al, bl
        seta cl
        ; call printIntLf@bool[t.33{r1}]
        call @printIntLf@bool
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
