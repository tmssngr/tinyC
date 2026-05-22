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
        ;   rsp+52: var d
        ;   rsp+54: var t
        ;   rsp+55: var f
        ;   rsp+56: var b1
@main:
        sub rsp, 24
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
        ; const b{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; const c{r0}, 2
        mov ax, 2
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        ; const d{r0}, 3
        mov ax, 3
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], d{r0}
        mov [r12], ax
        ; const t{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
        ; const f{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
        ; move t.10{r1}, a{r6}
        mov cx, bx
        ; and t.10{r1}, t.10{r1}, a{r6}
        and cx, bx
        ; call printIntLf@i16[t.10{r1}]
        call @printIntLf@i16
        ; move t.11{r1}, a{r6}
        mov cx, bx
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; and t.11{r1}, t.11{r1}, b{r0}
        and cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.11{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.12{r1}, b{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; and t.12{r1}, t.12{r1}, a{r6}
        and cx, bx
        ; call printIntLf@i16[t.12{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.13{r1}, b{r0}
        mov cx, ax
        ; and t.13{r1}, t.13{r1}, b{r0}
        and cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
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
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; or t.16{r1}, t.16{r1}, b{r0}
        or cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.16{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.17{r1}, b{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; or t.17{r1}, t.17{r1}, a{r6}
        or cx, bx
        ; call printIntLf@i16[t.17{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.18{r1}, b{r0}
        mov cx, ax
        ; or t.18{r1}, t.18{r1}, b{r0}
        or cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
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
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; xor t.21{r1}, t.21{r1}, c{r0}
        xor cx, ax
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.21{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; move t.22{r1}, b{r0}
        mov cx, ax
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], b{r0}
        mov [r12], ax
        ; xor t.22{r1}, t.22{r1}, a{r6}
        xor cx, bx
        ; call printIntLf@i16[t.22{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+48]
        ; load b{r6}, [memVarAddr{r7}]
        mov bx, [r12]
        ; move t.23{r1}, b{r6}
        mov cx, bx
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; xor t.23{r1}, t.23{r1}, c{r0}
        xor cx, ax
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.23{r1}]
        call @printIntLf@i16
        ; const t.24{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.24{r1}]
        call @printString@@u8
        ; 26:15 logic and
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.25{r1}, f{r0}
        mov cl, al
        ; branch t.25{r1}, true, @and_2nd_5, @no_critical_edge_22
        or cl, cl
        jnz @and_2nd_5
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
        jmp @and_next_5
@and_2nd_5:
        ; move t.25{r1}, f{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
@and_next_5:
        ; call printIntLf@bool[t.25{r1}]
        call @printIntLf@bool
        ; 27:15 logic and
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.26{r1}, f{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
        ; branch t.26{r1}, false, @and_next_6, @and_2nd_6
        or cl, cl
        jz @and_next_6
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r1}
        mov [r12], cl
@and_next_6:
        ; call printIntLf@bool[t.26{r1}]
        call @printIntLf@bool
        ; 28:15 logic and
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.27{r1}, t{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
        ; branch t.27{r1}, false, @and_next_7, @and_2nd_7
        or cl, cl
        jz @and_next_7
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r1}
        mov [r12], cl
@and_next_7:
        ; call printIntLf@bool[t.27{r1}]
        call @printIntLf@bool
        ; 29:15 logic and
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.28{r1}, t{r0}
        mov cl, al
        ; branch t.28{r1}, true, @and_2nd_8, @no_critical_edge_25
        or cl, cl
        jnz @and_2nd_8
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
        jmp @and_next_8
@and_2nd_8:
        ; move t.28{r1}, t{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
@and_next_8:
        ; call printIntLf@bool[t.28{r1}]
        call @printIntLf@bool
        ; const t.29{r1}, [string-4]
        lea rcx, [string_4]
        ; call printString@@u8[t.29{r1}]
        call @printString@@u8
        ; 31:15 logic or
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.30{r1}, f{r0}
        mov cl, al
        ; branch t.30{r1}, false, @or_2nd_9, @no_critical_edge_26
        or cl, cl
        jz @or_2nd_9
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
        jmp @or_next_9
@or_2nd_9:
        ; move t.30{r1}, f{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
@or_next_9:
        ; call printIntLf@bool[t.30{r1}]
        call @printIntLf@bool
        ; 32:15 logic or
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.31{r1}, f{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r0}
        mov [r12], al
        ; branch t.31{r1}, true, @or_next_10, @or_2nd_10
        or cl, cl
        jnz @or_next_10
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r1}
        mov [r12], cl
@or_next_10:
        ; call printIntLf@bool[t.31{r1}]
        call @printIntLf@bool
        ; 33:15 logic or
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.32{r1}, t{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
        ; branch t.32{r1}, true, @or_next_11, @or_2nd_11
        or cl, cl
        jnz @or_next_11
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; store [memVarAddr{r7}], f{r1}
        mov [r12], cl
@or_next_11:
        ; call printIntLf@bool[t.32{r1}]
        call @printIntLf@bool
        ; 34:15 logic or
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; move t.33{r1}, t{r0}
        mov cl, al
        ; branch t.33{r1}, false, @or_2nd_12, @no_critical_edge_29
        or cl, cl
        jz @or_2nd_12
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
        jmp @or_next_12
@or_2nd_12:
        ; move t.33{r1}, t{r0}
        mov cl, al
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; store [memVarAddr{r7}], t{r0}
        mov [r12], al
@or_next_12:
        ; call printIntLf@bool[t.33{r1}]
        call @printIntLf@bool
        ; const t.34{r1}, [string-5]
        lea rcx, [string_5]
        ; call printString@@u8[t.34{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+55]
        ; load f{r0}, [memVarAddr{r7}]
        mov al, [r12]
        ; notlog t.35{r1}, f{r0}
        or al, al
        sete cl
        ; call printIntLf@bool[t.35{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r7}, t
        lea r12, [rsp+54]
        ; load t{r0}, [memVarAddr{r7}]
        mov al, [r12]
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
        ; addrof memVarAddr{r7}, b1
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], b1{r3}
        mov [r12], r8b
        ; call printIntLf@u8[t.38{r1}]
        call @printIntLf@u8
        ; 43:20 logic or
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; equals t.40{r1}, b{r6}, c{r0}
        cmp bx, ax
        sete cl
        ; branch t.40{r1}, false, @or_2nd_13, @no_critical_edge_30
        or cl, cl
        jz @or_2nd_13
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        jmp @or_next_13
@or_2nd_13:
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+52]
        ; load d{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; lt t.40{r1}, c{r0}, d{r1}
        cmp ax, cx
        setl cl
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; store [memVarAddr{r7}], c{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+52]
        ; store [memVarAddr{r7}], d{r1}
        mov [r12], cx
@or_next_13:
        ; call printIntLf@bool[t.40{r1}]
        call @printIntLf@bool
        ; 44:20 logic and
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+50]
        ; load c{r0}, [memVarAddr{r7}]
        mov ax, [r12]
        ; equals t.41{r1}, b{r6}, c{r0}
        cmp bx, ax
        sete cl
        ; branch t.41{r1}, false, @and_next_14, @and_2nd_14
        or cl, cl
        jz @and_next_14
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+52]
        ; load d{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; lt t.41{r1}, c{r0}, d{r2}
        cmp ax, dx
        setl cl
@and_next_14:
        ; call printIntLf@bool[t.41{r1}]
        call @printIntLf@bool
        ; const t.42{r1}, -1
        mov cx, -1
        ; call printIntLf@i16[t.42{r1}]
        call @printIntLf@i16
        ; neg t.43{r1}, b{r6}
        mov rcx, rbx
        neg rcx
        ; call printIntLf@i16[t.43{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b1
        lea r12, [rsp+56]
        ; load b1{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; not t.44{r1}, b1{r6}
        mov rcx, rbx
        not rcx
        ; call printIntLf@u8[t.44{r1}]
        call @printIntLf@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
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
