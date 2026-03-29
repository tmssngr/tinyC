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
        ;   rsp+35: var d
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.4{r1}, [string-0]
        lea rdi, [string_0]
        ; call printString@@u8[t.4{r1}]
        call @printString@@u8
        ; const a{r8}, 1
        mov bx, 1
        ; const b{r0}, 2
        mov ax, 2
        ; lt t.5{r1}, a{r8}, b{r0}
        cmp bx, ax
        setl dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.5{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; lt t.6{r1}, b{r0}, a{r8}
        cmp ax, bx
        setl dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.6{r1}]
        call @printIntLf@bool
        ; const t.7{r1}, [string-1]
        lea rdi, [string_1]
        ; call printString@@u8[t.7{r1}]
        call @printString@@u8
        ; const c{r0}, 0
        mov al, 0
        ; const d{r2}, 128
        mov sil, 128
        ; lt t.8{r1}, c{r0}, d{r2}
        cmp al, sil
        setb dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r2}
        mov [r12], sil
        ; call printIntLf@bool[t.8{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; lt t.9{r1}, d{r0}, c{r2}
        cmp al, sil
        setb dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.9{r1}]
        call @printIntLf@bool
        ; const t.10{r1}, [string-2]
        lea rdi, [string_2]
        ; call printString@@u8[t.10{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; lteq t.11{r1}, a{r8}, b{r0}
        cmp bx, ax
        setle dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.11{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; lteq t.12{r1}, b{r0}, a{r8}
        cmp ax, bx
        setle dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.12{r1}]
        call @printIntLf@bool
        ; const t.13{r1}, [string-3]
        lea rdi, [string_3]
        ; call printString@@u8[t.13{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; lteq t.14{r1}, c{r0}, d{r2}
        cmp al, sil
        setbe dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r2}
        mov [r12], sil
        ; call printIntLf@bool[t.14{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; lteq t.15{r1}, d{r0}, c{r2}
        cmp al, sil
        setbe dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.15{r1}]
        call @printIntLf@bool
        ; const t.16{r1}, [string-4]
        lea rdi, [string_4]
        ; call printString@@u8[t.16{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.17{r1}, a{r8}, b{r0}
        cmp bx, ax
        sete dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.17{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; equals t.18{r1}, b{r0}, a{r8}
        cmp ax, bx
        sete dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.18{r1}]
        call @printIntLf@bool
        ; const t.19{r1}, [string-5]
        lea rdi, [string_5]
        ; call printString@@u8[t.19{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; notequals t.20{r1}, a{r8}, b{r0}
        cmp bx, ax
        setne dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.20{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; notequals t.21{r1}, b{r0}, a{r8}
        cmp ax, bx
        setne dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.21{r1}]
        call @printIntLf@bool
        ; const t.22{r1}, [string-6]
        lea rdi, [string_6]
        ; call printString@@u8[t.22{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gteq t.23{r1}, a{r8}, b{r0}
        cmp bx, ax
        setge dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.23{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gteq t.24{r1}, b{r0}, a{r8}
        cmp ax, bx
        setge dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.24{r1}]
        call @printIntLf@bool
        ; const t.25{r1}, [string-7]
        lea rdi, [string_7]
        ; call printString@@u8[t.25{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; gteq t.26{r1}, c{r0}, d{r2}
        cmp al, sil
        setae dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r0}
        mov [r12], al
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r2}
        mov [r12], sil
        ; call printIntLf@bool[t.26{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; gteq t.27{r1}, d{r0}, c{r2}
        cmp al, sil
        setae dil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r2}
        mov [r12], sil
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.27{r1}]
        call @printIntLf@bool
        ; const t.28{r1}, [string-8]
        lea rdi, [string_8]
        ; call printString@@u8[t.28{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gt t.29{r1}, a{r8}, b{r0}
        cmp bx, ax
        setg dil
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], b{r0}
        mov [r12], ax
        ; call printIntLf@bool[t.29{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, b
        lea r12, [rsp+32]
        ; load b{r0}, [memVarAddr{r9}]
        mov ax, [r12]
        ; gt t.30{r1}, b{r0}, a{r8}
        cmp ax, bx
        setg dil
        ; call printIntLf@bool[t.30{r1}]
        call @printIntLf@bool
        ; const t.31{r1}, [string-9]
        lea rdi, [string_9]
        ; call printString@@u8[t.31{r1}]
        call @printString@@u8
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r8}, [memVarAddr{r9}]
        mov bl, [r12]
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; gt t.32{r1}, c{r8}, d{r0}
        cmp bl, al
        seta dil
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r0}
        mov [r12], al
        ; call printIntLf@bool[t.32{r1}]
        call @printIntLf@bool
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; gt t.33{r1}, d{r0}, c{r8}
        cmp al, bl
        seta dil
        ; call printIntLf@bool[t.33{r1}]
        call @printIntLf@bool
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
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

