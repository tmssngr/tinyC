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
        ;   rsp+16: var c
        ;   rsp+18: var d
        ;   rsp+20: var t
        ;   rsp+21: var f
        ;   rsp+22: var b1
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.9{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString[t.9{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const a{r6}, 0
        mov bx, 0
        ; const b{r7}, 1
        mov r12w, 1
        ; const c{r0}, 2
        mov ax, 2
        ; const d{r2}, 3
        mov dx, 3
        ; const t{r3}, 1
        mov r8b, 1
        ; const f{r4}, 0
        mov r9b, 0
        ; move t.11{r5}, a{r6}
        mov r10w, bx
        ; and t.11{r5}, t.11{r5}, a{r6}
        and r10w, bx
        ; cast t.10{r1}(i64), t.11{r5}(i16)
        movzx rcx, r10w
        ; move c, c{r0}
        lea r11, [rsp+16]
        mov [r11], ax
        ; move d, d{r2}
        lea r11, [rsp+18]
        mov [r11], dx
        ; move t, t{r3}
        lea r11, [rsp+20]
        mov [r11], r8b
        ; move f, f{r4}
        lea r11, [rsp+21]
        mov [r11], r9b
        ; call printIntLf[t.10{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.13{r0}, a{r6}
        mov ax, bx
        ; and t.13{r0}, t.13{r0}, b{r7}
        and ax, r12w
        ; cast t.12{r1}(i64), t.13{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.12{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.15{r0}, b{r7}
        mov ax, r12w
        ; and t.15{r0}, t.15{r0}, a{r6}
        and ax, bx
        ; cast t.14{r1}(i64), t.15{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.14{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.17{r0}, b{r7}
        mov ax, r12w
        ; and t.17{r0}, t.17{r0}, b{r7}
        and ax, r12w
        ; cast t.16{r1}(i64), t.17{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.16{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.18{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString[t.18{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move t.20{r0}, a{r6}
        mov ax, bx
        ; or t.20{r0}, t.20{r0}, a{r6}
        or ax, bx
        ; cast t.19{r1}(i64), t.20{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.19{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.22{r0}, a{r6}
        mov ax, bx
        ; or t.22{r0}, t.22{r0}, b{r7}
        or ax, r12w
        ; cast t.21{r1}(i64), t.22{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.21{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.24{r0}, b{r7}
        mov ax, r12w
        ; or t.24{r0}, t.24{r0}, a{r6}
        or ax, bx
        ; cast t.23{r1}(i64), t.24{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.23{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.26{r0}, b{r7}
        mov ax, r12w
        ; or t.26{r0}, t.26{r0}, b{r7}
        or ax, r12w
        ; cast t.25{r1}(i64), t.26{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.25{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.27{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString[t.27{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move t.29{r0}, a{r6}
        mov ax, bx
        ; xor t.29{r0}, t.29{r0}, a{r6}
        xor ax, bx
        ; cast t.28{r1}(i64), t.29{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.28{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.31{r0}, a{r6}
        mov ax, bx
        ; move c{r2}, c
        lea r11, [rsp+16]
        mov dx, [r11]
        ; xor t.31{r0}, t.31{r0}, c{r2}
        xor ax, dx
        ; cast t.30{r1}(i64), t.31{r0}(i16)
        movzx rcx, ax
        ; move c, c{r2}
        lea r11, [rsp+16]
        mov [r11], dx
        ; call printIntLf[t.30{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.33{r0}, b{r7}
        mov ax, r12w
        ; xor t.33{r0}, t.33{r0}, a{r6}
        xor ax, bx
        ; cast t.32{r1}(i64), t.33{r0}(i16)
        movzx rcx, ax
        ; call printIntLf[t.32{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t.35{r6}, b{r7}
        mov bx, r12w
        ; move c{r0}, c
        lea r11, [rsp+16]
        mov ax, [r11]
        ; xor t.35{r6}, t.35{r6}, c{r0}
        xor bx, ax
        ; cast t.34{r1}(i64), t.35{r6}(i16)
        movzx rcx, bx
        ; move c{r6}, c{r0}
        mov bx, ax
        ; call printIntLf[t.34{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.36{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString[t.36{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; 26:15 logic and
        ; move f{r0}, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move t.38{r2}, f{r0}
        mov dl, al
        ; branch t.38{r2}, false, @and_next_5
        or dl, dl
        jz @and_next_5
        ; move t.38{r2}, f{r0}
        mov dl, al
@and_next_5:
        ; cast t.37{r1}(i64), t.38{r2}(bool)
        movzx rcx, dl
        ; move f, f{r0}
        lea r11, [rsp+21]
        mov [r11], al
        ; call printIntLf[t.37{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 27:15 logic and
        ; move f{r0}, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move t.40{r2}, f{r0}
        mov dl, al
        ; branch t.40{r2}, true, @and_2nd_6
        or dl, dl
        jnz @and_2nd_6
        ; move t{r3}, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        jmp @and_next_6
@and_2nd_6:
        ; move t{r3}, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        ; move t.40{r2}, t{r3}
        mov dl, r8b
@and_next_6:
        ; cast t.39{r1}(i64), t.40{r2}(bool)
        movzx rcx, dl
        ; move t, t{r3}
        lea r11, [rsp+20]
        mov [r11], r8b
        ; move f, f{r0}
        lea r11, [rsp+21]
        mov [r11], al
        ; call printIntLf[t.39{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 28:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move t.42{r2}, t{r0}
        mov dl, al
        ; branch t.42{r2}, true, @and_2nd_7
        or dl, dl
        jnz @and_2nd_7
        ; move f{r3}, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        jmp @and_next_7
@and_2nd_7:
        ; move f{r3}, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        ; move t.42{r2}, f{r3}
        mov dl, r8b
@and_next_7:
        ; cast t.41{r1}(i64), t.42{r2}(bool)
        movzx rcx, dl
        ; move t, t{r0}
        lea r11, [rsp+20]
        mov [r11], al
        ; move f, f{r3}
        lea r11, [rsp+21]
        mov [r11], r8b
        ; call printIntLf[t.41{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 29:15 logic and
        ; move t{r0}, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move t.44{r2}, t{r0}
        mov dl, al
        ; branch t.44{r2}, false, @and_next_8
        or dl, dl
        jz @and_next_8
        ; move t.44{r2}, t{r0}
        mov dl, al
@and_next_8:
        ; cast t.43{r1}(i64), t.44{r2}(bool)
        movzx rcx, dl
        ; move t, t{r0}
        lea r11, [rsp+20]
        mov [r11], al
        ; call printIntLf[t.43{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.45{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString[t.45{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; 31:15 logic or
        ; move f{r0}, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move t.47{r2}, f{r0}
        mov dl, al
        ; branch t.47{r2}, true, @or_next_9
        or dl, dl
        jnz @or_next_9
        ; move t.47{r2}, f{r0}
        mov dl, al
@or_next_9:
        ; cast t.46{r1}(i64), t.47{r2}(bool)
        movzx rcx, dl
        ; move f, f{r0}
        lea r11, [rsp+21]
        mov [r11], al
        ; call printIntLf[t.46{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 32:15 logic or
        ; move f{r0}, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; move t.49{r2}, f{r0}
        mov dl, al
        ; branch t.49{r2}, false, @or_2nd_10
        or dl, dl
        jz @or_2nd_10
        ; move t{r3}, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        jmp @or_next_10
@or_2nd_10:
        ; move t{r3}, t
        lea r11, [rsp+20]
        mov r8b, [r11]
        ; move t.49{r2}, t{r3}
        mov dl, r8b
@or_next_10:
        ; cast t.48{r1}(i64), t.49{r2}(bool)
        movzx rcx, dl
        ; move t, t{r3}
        lea r11, [rsp+20]
        mov [r11], r8b
        ; move f, f{r0}
        lea r11, [rsp+21]
        mov [r11], al
        ; call printIntLf[t.48{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 33:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move t.51{r2}, t{r0}
        mov dl, al
        ; branch t.51{r2}, false, @or_2nd_11
        or dl, dl
        jz @or_2nd_11
        ; move f{r3}, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        jmp @or_next_11
@or_2nd_11:
        ; move f{r3}, f
        lea r11, [rsp+21]
        mov r8b, [r11]
        ; move t.51{r2}, f{r3}
        mov dl, r8b
@or_next_11:
        ; cast t.50{r1}(i64), t.51{r2}(bool)
        movzx rcx, dl
        ; move t, t{r0}
        lea r11, [rsp+20]
        mov [r11], al
        ; move f, f{r3}
        lea r11, [rsp+21]
        mov [r11], r8b
        ; call printIntLf[t.50{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 34:15 logic or
        ; move t{r0}, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; move t.53{r2}, t{r0}
        mov dl, al
        ; branch t.53{r2}, true, @or_next_12
        or dl, dl
        jnz @or_next_12
        ; move t.53{r2}, t{r0}
        mov dl, al
@or_next_12:
        ; cast t.52{r1}(i64), t.53{r2}(bool)
        movzx rcx, dl
        ; move t, t{r0}
        lea r11, [rsp+20]
        mov [r11], al
        ; call printIntLf[t.52{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.54{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString[t.54{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move f{r0}, f
        lea r11, [rsp+21]
        mov al, [r11]
        ; notlog t.56{r0}, f{r0}
        or al, al
        sete al
        ; cast t.55{r1}(i64), t.56{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.55{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move t{r0}, t
        lea r11, [rsp+20]
        mov al, [r11]
        ; notlog t.58{r0}, t{r0}
        or al, al
        sete al
        ; cast t.57{r1}(i64), t.58{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.57{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.59{r1}, [string-6]
        lea rcx, [string_6]
        ; call printString[t.59{r1}]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const b10{r0}, 10
        mov al, 10
        ; const b6{r2}, 6
        mov dl, 6
        ; const b1{r3}, 1
        mov r8b, 1
        ; and t.62{r0}, t.62{r0}, b6{r2}
        and al, dl
        ; or t.61{r0}, t.61{r0}, b1{r3}
        or al, r8b
        ; cast t.60{r1}(i64), t.61{r0}(u8)
        movzx rcx, al
        ; move b1, b1{r3}
        lea r11, [rsp+22]
        mov [r11], r8b
        ; call printIntLf[t.60{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 43:20 logic or
        ; equals t.64{r0}, b{r7}, c{r6}
        cmp r12w, bx
        sete al
        ; branch t.64{r0}, false, @or_2nd_13
        or al, al
        jz @or_2nd_13
        ; move d{r2}, d
        lea r11, [rsp+18]
        mov dx, [r11]
        jmp @or_next_13
@or_2nd_13:
        ; move d{r2}, d
        lea r11, [rsp+18]
        mov dx, [r11]
        ; lt t.64{r0}, c{r6}, d{r2}
        cmp bx, dx
        setl al
@or_next_13:
        ; cast t.63{r1}(i64), t.64{r0}(bool)
        movzx rcx, al
        ; move d, d{r2}
        lea r11, [rsp+18]
        mov [r11], dx
        ; call printIntLf[t.63{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; 44:20 logic and
        ; equals t.66{r0}, b{r7}, c{r6}
        cmp r12w, bx
        sete al
        ; branch t.66{r0}, false, @and_next_14
        or al, al
        jz @and_next_14
        ; move d{r2}, d
        lea r11, [rsp+18]
        mov dx, [r11]
        ; lt t.66{r0}, c{r6}, d{r2}
        cmp bx, dx
        setl al
@and_next_14:
        ; cast t.65{r1}(i64), t.66{r0}(bool)
        movzx rcx, al
        ; call printIntLf[t.65{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; const t.68{r6}, -1
        mov bx, -1
        ; cast t.67{r1}(i64), t.68{r6}(i16)
        movzx rcx, bx
        ; call printIntLf[t.67{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; neg t.70{r6}, b{r7}
        mov rbx, r12
        neg rbx
        ; cast t.69{r1}(i64), t.70{r6}(i16)
        movzx rcx, bx
        ; call printIntLf[t.69{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; move b1{r6}, b1
        lea r11, [rsp+22]
        mov bl, [r11]
        ; not t.72{r6}, b1{r6}
        not rbx
        ; cast t.71{r1}(i64), t.72{r6}(u8)
        movzx rcx, bl
        ; call printIntLf[t.71{r1}]
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
