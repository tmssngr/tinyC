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
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; addrof t.1{r6}, chr
        lea rbx, [rsp+48]
        ; const t.2{r2}, 1
        mov dl, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; move t.1{r1}, t.1{r6}
        mov rcx, rbx
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
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
        ; 31:3 if number == 0
        ; equals t.12{r7}, number{r1}, 0
        cmp rcx, 0
        sete r12b
        ; branch t.12{r7}, false, @while_1, @while_1_break
        or r12b, r12b
        jz @while_1
        ; cast t.14{r7}(i64), pos{r6}(u8)
        movzx r12, bl
        ; cast t.15{r7}(u8*), t.14{r7}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.13{r1}, t.13{r1}, t.15{r7}
        add rcx, r12
        ; const t.17{r7}, 20
        mov r12b, 20
        ; move t.16{r2}, t.17{r7}
        mov dl, r12b
        ; sub t.16{r2}, t.16{r2}, pos{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.13{r1}, t.16{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
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
        ; lt t.1{r7}, number{r6}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r7}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov cl, 45
        ; call printChar@u8[t.2{r1}]
        call @printChar@u8
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const t.3{r1}, 10
        mov cl, 10
        ; call printChar@u8[t.3{r1}]
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
        ; call printString@@u8[t.9{r1}]
        call @printString@@u8
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
        ; move t.10{r1}, a{r6}
        mov cx, bx
        ; and t.10{r1}, t.10{r1}, a{r6}
        and cx, bx
        ; call printIntLf@i16[t.10{r1}]
        call @printIntLf@i16
        ; move t.11{r1}, a{r6}
        mov cx, bx
        ; and t.11{r1}, t.11{r1}, b{r7}
        and cx, r12w
        ; call printIntLf@i16[t.11{r1}]
        call @printIntLf@i16
        ; move t.12{r1}, b{r7}
        mov cx, r12w
        ; and t.12{r1}, t.12{r1}, a{r6}
        and cx, bx
        ; call printIntLf@i16[t.12{r1}]
        call @printIntLf@i16
        ; move t.13{r1}, b{r7}
        mov cx, r12w
        ; and t.13{r1}, t.13{r1}, b{r7}
        and cx, r12w
        ; call printIntLf@i16[t.13{r1}]
        call @printIntLf@i16
        ; const t.14{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.14{r1}]
        call @printString@@u8
        ; move t.15{r1}, a{r6}
        mov cx, bx
        ; or t.15{r1}, t.15{r1}, a{r6}
        or cx, bx
        ; call printIntLf@i16[t.15{r1}]
        call @printIntLf@i16
        ; move t.16{r1}, a{r6}
        mov cx, bx
        ; or t.16{r1}, t.16{r1}, b{r7}
        or cx, r12w
        ; call printIntLf@i16[t.16{r1}]
        call @printIntLf@i16
        ; move t.17{r1}, b{r7}
        mov cx, r12w
        ; or t.17{r1}, t.17{r1}, a{r6}
        or cx, bx
        ; call printIntLf@i16[t.17{r1}]
        call @printIntLf@i16
        ; move t.18{r1}, b{r7}
        mov cx, r12w
        ; or t.18{r1}, t.18{r1}, b{r7}
        or cx, r12w
        ; call printIntLf@i16[t.18{r1}]
        call @printIntLf@i16
        ; const t.19{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.19{r1}]
        call @printString@@u8
        ; move t.20{r1}, a{r6}
        mov cx, bx
        ; xor t.20{r1}, t.20{r1}, a{r6}
        xor cx, bx
        ; call printIntLf@i16[t.20{r1}]
        call @printIntLf@i16
        ; move t.21{r1}, a{r6}
        mov cx, bx
        ; move c{r0}, c
        lea r11, [rsp+48]
        mov ax, [r11]
        ; xor t.21{r1}, t.21{r1}, c{r0}
        xor cx, ax
        ; move c, c{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; call printIntLf@i16[t.21{r1}]
        call @printIntLf@i16
        ; move t.22{r1}, b{r7}
        mov cx, r12w
        ; xor t.22{r1}, t.22{r1}, a{r6}
        xor cx, bx
        ; call printIntLf@i16[t.22{r1}]
        call @printIntLf@i16
        ; move t.23{r1}, b{r7}
        mov cx, r12w
        ; move c{r6}, c
        lea r11, [rsp+48]
        mov bx, [r11]
        ; xor t.23{r1}, t.23{r1}, c{r6}
        xor cx, bx
        ; call printIntLf@i16[t.23{r1}]
        call @printIntLf@i16
        ; const t.24{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.24{r1}]
        call @printString@@u8
        ; 26:15 logic and
        ; move f{r0}, f
        lea r11, [rsp+53]
        mov al, [r11]
        ; move t.25{r1}, f{r0}
        mov cl, al
        ; branch t.25{r1}, true, @and_2nd_5, @no_critical_edge_22
        or cl, cl
        jnz @and_2nd_5
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
        jmp @and_next_5
@and_2nd_5:
        ; move t.25{r1}, f{r0}
        mov cl, al
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
@and_next_5:
        ; call printIntLf@bool[t.25{r1}]
        call @printIntLf@bool
        ; 27:15 logic and
        ; move f{r0}, f
        lea r11, [rsp+53]
        mov al, [r11]
        ; move t.26{r1}, f{r0}
        mov cl, al
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; branch t.26{r1}, false, @and_next_6, @and_2nd_6
        or cl, cl
        jz @and_next_6
        ; move t{r1}, t
        lea r11, [rsp+52]
        mov cl, [r11]
        ; move t, t{r1}
        lea r11, [rsp+52]
        mov [r11], cl
@and_next_6:
        ; call printIntLf@bool[t.26{r1}]
        call @printIntLf@bool
        ; 28:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.27{r1}, t{r0}
        mov cl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; branch t.27{r1}, false, @and_next_7, @and_2nd_7
        or cl, cl
        jz @and_next_7
        ; move f{r1}, f
        lea r11, [rsp+53]
        mov cl, [r11]
        ; move f, f{r1}
        lea r11, [rsp+53]
        mov [r11], cl
@and_next_7:
        ; call printIntLf@bool[t.27{r1}]
        call @printIntLf@bool
        ; 29:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.28{r1}, t{r0}
        mov cl, al
        ; branch t.28{r1}, true, @and_2nd_8, @no_critical_edge_25
        or cl, cl
        jnz @and_2nd_8
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        jmp @and_next_8
@and_2nd_8:
        ; move t.28{r1}, t{r0}
        mov cl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
@and_next_8:
        ; call printIntLf@bool[t.28{r1}]
        call @printIntLf@bool
        ; const t.29{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.29{r1}]
        call @printString@@u8
        ; 31:15 logic or
        ; move f{r0}, f
        lea r11, [rsp+53]
        mov al, [r11]
        ; move t.30{r1}, f{r0}
        mov cl, al
        ; branch t.30{r1}, false, @or_2nd_9, @no_critical_edge_26
        or cl, cl
        jz @or_2nd_9
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
        jmp @or_next_9
@or_2nd_9:
        ; move t.30{r1}, f{r0}
        mov cl, al
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
@or_next_9:
        ; call printIntLf@bool[t.30{r1}]
        call @printIntLf@bool
        ; 32:15 logic or
        ; move f{r0}, f
        lea r11, [rsp+53]
        mov al, [r11]
        ; move t.31{r1}, f{r0}
        mov cl, al
        ; move f, f{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; branch t.31{r1}, true, @or_next_10, @or_2nd_10
        or cl, cl
        jnz @or_next_10
        ; move t{r1}, t
        lea r11, [rsp+52]
        mov cl, [r11]
        ; move t, t{r1}
        lea r11, [rsp+52]
        mov [r11], cl
@or_next_10:
        ; call printIntLf@bool[t.31{r1}]
        call @printIntLf@bool
        ; 33:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.32{r1}, t{r0}
        mov cl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; branch t.32{r1}, true, @or_next_11, @or_2nd_11
        or cl, cl
        jnz @or_next_11
        ; move f{r1}, f
        lea r11, [rsp+53]
        mov cl, [r11]
        ; move f, f{r1}
        lea r11, [rsp+53]
        mov [r11], cl
@or_next_11:
        ; call printIntLf@bool[t.32{r1}]
        call @printIntLf@bool
        ; 34:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; move t.33{r1}, t{r0}
        mov cl, al
        ; branch t.33{r1}, false, @or_2nd_12, @no_critical_edge_29
        or cl, cl
        jz @or_2nd_12
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
        jmp @or_next_12
@or_2nd_12:
        ; move t.33{r1}, t{r0}
        mov cl, al
        ; move t, t{r0}
        lea r11, [rsp+52]
        mov [r11], al
@or_next_12:
        ; call printIntLf@bool[t.33{r1}]
        call @printIntLf@bool
        ; const t.34{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.34{r1}]
        call @printString@@u8
        ; move f{r0}, f
        lea r11, [rsp+53]
        mov al, [r11]
        ; notlog t.35{r1}, f{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.35{r1}]
        call @printIntLf@bool
        ; move t{r0}, t
        lea r11, [rsp+52]
        mov al, [r11]
        ; notlog t.36{r1}, t{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.36{r1}]
        call @printIntLf@bool
        ; const t.37{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString@@u8[t.37{r1}]
        call @printString@@u8
        ; const b10{r0}, 10
        mov al, 10
        ; const b6{r2}, 6
        mov dl, 6
        ; const b1{r3}, 1
        mov r8b, 1
        ; and t.39{r0}, t.39{r0}, b6{r2}
        and al, dl
        ; move t.38{r1}, t.39{r0}
        mov cl, al
        ; or t.38{r1}, t.38{r1}, b1{r3}
        or cl, r8b
        ; move b1, b1{r3}
        lea r11, [rsp+54]
        mov [r11], r8b
        ; call printIntLf@u8[t.38{r1}]
        call @printIntLf@u8
        ; 43:20 logic or
        ; equals t.40{r1}, b{r7}, c{r6}
        cmp r12w, bx
        sete cl
        ; branch t.40{r1}, true, @or_next_13, @or_2nd_13
        or cl, cl
        jnz @or_next_13
        ; move d{r1}, d
        lea r11, [rsp+50]
        mov cx, [r11]
        ; lt t.40{r1}, c{r6}, d{r1}
        cmp bx, cx
        setl cl
        ; move d, d{r1}
        lea r11, [rsp+50]
        mov [r11], cx
@or_next_13:
        ; call printIntLf@bool[t.40{r1}]
        call @printIntLf@bool
        ; 44:20 logic and
        ; equals t.41{r1}, b{r7}, c{r6}
        cmp r12w, bx
        sete cl
        ; branch t.41{r1}, false, @and_next_14, @and_2nd_14
        or cl, cl
        jz @and_next_14
        ; move d{r1}, d
        lea r11, [rsp+50]
        mov cx, [r11]
        ; lt t.41{r1}, c{r6}, d{r1}
        cmp bx, cx
        setl cl
@and_next_14:
        ; call printIntLf@bool[t.41{r1}]
        call @printIntLf@bool
        ; const t.42{r1}, -1
        mov cx, -1
        ; call printIntLf@i16[t.42{r1}]
        call @printIntLf@i16
        ; neg t.43{r1}, b{r7}
        mov rcx, r12
        neg rcx
        ; call printIntLf@i16[t.43{r1}]
        call @printIntLf@i16
        ; move b1{r6}, b1
        lea r11, [rsp+54]
        mov bl, [r11]
        ; not t.44{r1}, b1{r6}
        mov rcx, rbx
        not rcx
        ; call printIntLf@u8[t.44{r1}]
        call @printIntLf@u8
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
