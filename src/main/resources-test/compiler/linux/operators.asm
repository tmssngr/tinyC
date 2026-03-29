format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printString@@u8
        ;   rsp+24: arg str
@printString@@u8:
        sub rsp, 16
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; move str{r8}, str{r1}
        mov rbx, rdi
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call @strlen@@u8
        ; move str{r1}, str{r8}
        mov rdi, rbx
        ; move length{r2}, length{r0}
        mov rsi, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call @printStringLength@@u8@i64
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 16
        ret

        ; void printChar@u8
        ;   rsp+32: arg chr
@printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, chr
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], chr{r1}
        mov [r12], dil
        ; addrof t.1{r1}, chr
        lea rdi, [rsp+32]
        ; const t.2{r2}, 1
        mov sil, 1
        ; call printStringLength@@u8@u8[t.1{r1}, t.2{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+24: arg number
        ;   rsp+40: var buffer
@printUint@i64:
        sub rsp, 48
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        ; const pos{r8}, 20
        mov bl, 20
        ; 21:2 while true
@while_1:
        ; const t.5{r4}, 1
        mov cl, 1
        ; sub pos{r8}, pos{r8}, t.5{r4}
        sub bl, cl
        ; const t.6{r4}, 10
        mov rcx, 10
        ; move remainder{r5}, number{r1}
        mov r8, rdi
        ; move remainder{r0}, remainder{r5}
        mov rax, r8
        ; mod remainder{r3}, remainder{r0}, t.6{r4}
        cqo
        idiv rcx
        ; move remainder{r5}, remainder{r3}
        mov r8, rdx
        ; const t.7{r4}, 10
        mov rcx, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.7{r4}
        cqo
        idiv rcx
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.8{r0}(u8), remainder{r5}(i64)
        mov al, r8b
        ; const t.9{r3}, 48
        mov dl, 48
        ; add digit{r0}, digit{r0}, t.9{r3}
        add al, dl
        ; cast t.11{r3}(i64), pos{r8}(u8)
        movzx rdx, bl
        ; addrof t.10{r4}, [buffer]
        lea rcx, [rsp+40]
        ; add t.10{r4}, t.10{r4}, t.11{r3}
        add rcx, rdx
        ; store [t.10{r4}], digit{r0}
        mov [rcx], al
        ; 27:3 if number == 0
        ; const t.13{r0}, 0
        mov rax, 0
        ; equals t.12{r0}, number{r1}, t.13{r0}
        cmp rdi, rax
        sete al
        ; branch t.12{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.15{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; addrof t.14{r1}, [buffer]
        lea rdi, [rsp+40]
        ; add t.14{r1}, t.14{r1}, t.15{r0}
        add rdi, rax
        ; const t.17{r0}, 20
        mov al, 20
        ; move t.16{r2}, t.17{r0}
        mov sil, al
        ; sub t.16{r2}, t.16{r2}, pos{r8}
        sub sil, bl
        ; call printStringLength@@u8@u8[t.14{r1}, t.16{r2}]
        call @printStringLength@@u8@u8
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        add rsp, 48
        ret

        ; void printIntLf@bool
        ;   rsp+0: arg number
@printIntLf@bool:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(bool)
        movzx rdi, dil
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@u8
        ;   rsp+0: arg number
@printIntLf@u8:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rdi, dil
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i16
        ;   rsp+0: arg number
@printIntLf@i16:
        sub rsp, 8
        ; cast t.1{r1}(i64), number{r1}(i16)
        movzx rdi, di
        ; call printIntLf@i64[t.1{r1}]
        call @printIntLf@i64
        add rsp, 8
        ret

        ; void printIntLf@i64
        ;   rsp+32: arg number
@printIntLf@i64:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; 47:2 if number < 0
        ; const t.2{r9}, 0
        mov r12, 0
        ; lt t.1{r9}, number{r8}, t.2{r9}
        cmp rbx, r12
        setl r12b
        ; branch t.1{r9}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const t.3{r1}, 45
        mov dil, 45
        ; call printChar@u8[t.3{r1}]
        call @printChar@u8
        ; neg number{r8}, number{r8}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const t.4{r1}, 10
        mov dil, 10
        ; call printChar@u8[t.4{r1}]
        call @printChar@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i64 strlen@@u8
        ;   rsp+0: arg str
@strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 57:2 for *str != 0
        jmp @for_4
@for_4_body:
        ; const t.5{r2}, 1
        mov rsi, 1
        ; add length{r0}, length{r0}, t.5{r2}
        add rax, rsi
        ; const t.6{r2}, 1
        mov rsi, 1
        ; add str{r1}, str{r1}, t.6{r2}
        add rdi, rsi
@for_4:
        ; load t.3{r2}, [str{r1}]
        mov sil, [rdi]
        ; const t.4{r3}, 0
        mov dl, 0
        ; notequals t.2{r2}, t.3{r2}, t.4{r3}
        cmp sil, dl
        setne sil
        ; branch t.2{r2}, true, @for_4_body, @for_4_break
        or sil, sil
        jnz @for_4_body
        ; 60:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+0: arg str
        ;   rsp+8: arg length
@printStringLength@@u8@u8:
        sub rsp, 24
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rsi, sil
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call @printStringLength@@u8@i64
        add rsp, 24
        ret

        ; void main
        ;   rsp+32: var b
        ;   rsp+34: var c
        ;   rsp+36: var d
        ;   rsp+38: var t
        ;   rsp+39: var f
        ;   rsp+40: var b1
@main:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.9{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.9{r1}]
        call @printString@@u8
        ; const a{r8}, 0
        mov bx, 0
        ; const b{r0}, 1
        mov ax, 1
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; const c{r0}, 2
        mov ax, 2
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; const d{r0}, 3
        mov ax, 3
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], d{r0}
        mov [r12], ax
        ; const t{r0}, 1
        mov al, 1
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
        ; const f{r0}, 0
        mov al, 0
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
        ; move t.10{r1}, a{r8}
        mov di, bx
        ; and t.10{r1}, t.10{r1}, a{r8}
        and di, bx
        ; call printIntLf@i16[t.10{r1}]
        call @printIntLf@i16
        ; move t.11{r1}, a{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; and t.11{r1}, t.11{r1}, b{r0}
        and di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.11{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.12{r1}, b{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; and t.12{r1}, t.12{r1}, a{r8}
        and di, bx
        ; call printIntLf@i16[t.12{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.13{r1}, b{r0}
        mov di, ax
        ; and t.13{r1}, t.13{r1}, b{r0}
        and di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.13{r1}]
        call @printIntLf@i16
        ; const t.14{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.14{r1}]
        call @printString@@u8
        ; move t.15{r1}, a{r8}
        mov di, bx
        ; or t.15{r1}, t.15{r1}, a{r8}
        or di, bx
        ; call printIntLf@i16[t.15{r1}]
        call @printIntLf@i16
        ; move t.16{r1}, a{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; or t.16{r1}, t.16{r1}, b{r0}
        or di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.16{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.17{r1}, b{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; or t.17{r1}, t.17{r1}, a{r8}
        or di, bx
        ; call printIntLf@i16[t.17{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.18{r1}, b{r0}
        mov di, ax
        ; or t.18{r1}, t.18{r1}, b{r0}
        or di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.18{r1}]
        call @printIntLf@i16
        ; const t.19{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.19{r1}]
        call @printString@@u8
        ; move t.20{r1}, a{r8}
        mov di, bx
        ; xor t.20{r1}, t.20{r1}, a{r8}
        xor di, bx
        ; call printIntLf@i16[t.20{r1}]
        call @printIntLf@i16
        ; move t.21{r1}, a{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; xor t.21{r1}, t.21{r1}, c{r0}
        xor di, ax
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.21{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; move t.22{r1}, b{r0}
        mov di, ax
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; xor t.22{r1}, t.22{r1}, a{r8}
        xor di, bx
        ; call printIntLf@i16[t.22{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r8}, [memVarAddr{r9}]
        mov bx, [r12]
        ; move t.23{r1}, b{r8}
        mov di, bx
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; xor t.23{r1}, t.23{r1}, c{r0}
        xor di, ax
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; call printIntLf@i16[t.23{r1}]
        call @printIntLf@i16
        ; const t.24{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.24{r1}]
        call @printString@@u8
        ; 26:15 logic and
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.25{r1}, f{r0}
        mov dil, al
        ; branch t.25{r1}, true, @and_2nd_5, @no_critical_edge_22
        or dil, dil
        jnz @and_2nd_5
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
        jmp @and_next_5
@and_2nd_5:
        ; move t.25{r1}, f{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
@and_next_5:
        ; call printIntLf@bool[t.25{r1}]
        call @printIntLf@bool
        ; 27:15 logic and
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.26{r1}, f{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
        ; branch t.26{r1}, false, @and_next_6, @and_2nd_6
        or dil, dil
        jz @and_next_6
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r1}
        mov [r12], dil
@and_next_6:
        ; call printIntLf@bool[t.26{r1}]
        call @printIntLf@bool
        ; 28:15 logic and
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.27{r1}, t{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
        ; branch t.27{r1}, false, @and_next_7, @and_2nd_7
        or dil, dil
        jz @and_next_7
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r1}
        mov [r12], dil
@and_next_7:
        ; call printIntLf@bool[t.27{r1}]
        call @printIntLf@bool
        ; 29:15 logic and
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.28{r1}, t{r0}
        mov dil, al
        ; branch t.28{r1}, true, @and_2nd_8, @no_critical_edge_25
        or dil, dil
        jnz @and_2nd_8
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
        jmp @and_next_8
@and_2nd_8:
        ; move t.28{r1}, t{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
@and_next_8:
        ; call printIntLf@bool[t.28{r1}]
        call @printIntLf@bool
        ; const t.29{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString@@u8[t.29{r1}]
        call @printString@@u8
        ; 31:15 logic or
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.30{r1}, f{r0}
        mov dil, al
        ; branch t.30{r1}, false, @or_2nd_9, @no_critical_edge_26
        or dil, dil
        jz @or_2nd_9
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
        jmp @or_next_9
@or_2nd_9:
        ; move t.30{r1}, f{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
@or_next_9:
        ; call printIntLf@bool[t.30{r1}]
        call @printIntLf@bool
        ; 32:15 logic or
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.31{r1}, f{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r0}
        mov [r12], al
        ; branch t.31{r1}, true, @or_next_10, @or_2nd_10
        or dil, dil
        jnz @or_next_10
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r1}
        mov [r12], dil
@or_next_10:
        ; call printIntLf@bool[t.31{r1}]
        call @printIntLf@bool
        ; 33:15 logic or
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.32{r1}, t{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
        ; branch t.32{r1}, true, @or_next_11, @or_2nd_11
        or dil, dil
        jnz @or_next_11
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; store [memVarAddr{r9}], f{r1}
        mov [r12], dil
@or_next_11:
        ; call printIntLf@bool[t.32{r1}]
        call @printIntLf@bool
        ; 34:15 logic or
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; move t.33{r1}, t{r0}
        mov dil, al
        ; branch t.33{r1}, false, @or_2nd_12, @no_critical_edge_29
        or dil, dil
        jz @or_2nd_12
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
        jmp @or_next_12
@or_2nd_12:
        ; move t.33{r1}, t{r0}
        mov dil, al
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; store [memVarAddr{r9}], t{r0}
        mov [r12], al
@or_next_12:
        ; call printIntLf@bool[t.33{r1}]
        call @printIntLf@bool
        ; const t.34{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString@@u8[t.34{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, f
        lea r12, [rsp+39]
        ; load f{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; notlog t.35{r1}, f{r0}
        or al, al
        sete dil
        ; call printIntLf@bool[t.35{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, t
        lea r12, [rsp+38]
        ; load t{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; notlog t.36{r1}, t{r0}
        or al, al
        sete dil
        ; call printIntLf@bool[t.36{r1}]
        call @printIntLf@bool
        ; const t.37{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString@@u8[t.37{r1}]
        call @printString@@u8
        ; const b10{r0}, 10
        mov al, 10
        ; const b6{r2}, 6
        mov sil, 6
        ; const b1{r3}, 1
        mov dl, 1
        ; and t.39{r0}, t.39{r0}, b6{r2}
        and al, sil
        ; move t.38{r1}, t.39{r0}
        mov dil, al
        ; or t.38{r1}, t.38{r1}, b1{r3}
        or dil, dl
        ; addrof memVarAddr{r9}, b1
        lea r12, [rsp+40]
        ; store [memVarAddr{r9}], b1{r3}
        mov [r12], dl
        ; call printIntLf@u8[t.38{r1}]
        call @printIntLf@u8
        ; 43:20 logic or
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.40{r1}, b{r8}, c{r0}
        cmp bx, ax
        sete dil
        ; branch t.40{r1}, false, @or_2nd_13, @no_critical_edge_30
        or dil, dil
        jz @or_2nd_13
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        jmp @or_next_13
@or_2nd_13:
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+36]
        ; load d{r1}, [memVarAddr{r9}]
        mov di, [r12]
        ; lt t.40{r1}, c{r0}, d{r1}
        cmp ax, di
        setl dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], ax
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], d{r1}
        mov [r12], di
@or_next_13:
        ; call printIntLf@bool[t.40{r1}]
        call @printIntLf@bool
        ; 44:20 logic and
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.41{r1}, b{r8}, c{r0}
        cmp bx, ax
        sete dil
        ; branch t.41{r1}, false, @and_next_14, @and_2nd_14
        or dil, dil
        jz @and_next_14
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+36]
        ; load d{r2}, [memVarAddr{r9}]
        mov si, [r12]
        ; lt t.41{r1}, c{r0}, d{r2}
        cmp ax, si
        setl dil
@and_next_14:
        ; call printIntLf@bool[t.41{r1}]
        call @printIntLf@bool
        ; const t.42{r1}, -1
        mov di, -1
        ; call printIntLf@i16[t.42{r1}]
        call @printIntLf@i16
        ; neg t.43{r1}, b{r8}
        mov rdi, rbx
        neg rdi
        ; call printIntLf@i16[t.43{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r9}, b1
        lea r12, [rsp+40]
        ; load b1{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; not t.44{r1}, b1{r8}
        mov rdi, rbx
        not rdi
        ; call printIntLf@u8[t.44{r1}]
        call @printIntLf@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 24
        ret

        ; void printStringLength@@u8@i64
@printStringLength@@u8@i64:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

segment readable
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

