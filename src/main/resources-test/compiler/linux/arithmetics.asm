format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

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
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; end initialize global variables
        ; const foo{r9}, 22
        mov r12w, 22
        ; move bar{r0}, foo{r9}
        mov ax, r12w
        ; mul bar{r0}, bar{r0}, foo{r9}
        movsx rax, ax
        movsx r12, r12w
        imul  rax, r12
        ; const foo{r9}, 1
        mov r12w, 1
        ; move t.5{r1}, bar{r0}
        mov di, ax
        ; add t.5{r1}, t.5{r1}, foo{r9}
        add di, r12w
        ; call printIntLf@i16[t.5{r1}]
        call @printIntLf@i16
        ; const foo{r9}, 21
        mov r12w, 21
        ; move foo{r1}, foo{r9}
        mov di, r12w
        ; call printIntLf@i16[foo{r1}]
        call @printIntLf@i16
        ; move bazz{r1}, bazz{r8}
        mov di, bx
        ; call printIntLf@i16[bazz{r1}]
        call @printIntLf@i16
        ; const a{r8}, 1000
        mov bx, 1000
        ; const b{r9}, 10
        mov r12w, 10
        ; move t.6{r1}, a{r8}
        mov di, bx
        ; move t.6{r0}, t.6{r1}
        mov ax, di
        ; div t.6{r0}, t.6{r0}, b{r9}
        movsx rax, ax
        movsx r12, r12w
        cqo
        idiv r12
        ; move t.6{r1}, t.6{r0}
        mov di, ax
        ; call printIntLf@i16[t.6{r1}]
        call @printIntLf@i16
        ; const t.8{r9}, 255
        mov r12w, 255
        ; move t.7{r1}, a{r8}
        mov di, bx
        ; and t.7{r1}, t.7{r1}, t.8{r9}
        and di, r12w
        ; call printIntLf@i16[t.7{r1}]
        call @printIntLf@i16
        ; const a{r8}, 10
        mov bx, 10
        ; const b{r9}, 1
        mov r12w, 1
        ; move t.9{r1}, a{r8}
        mov di, bx
        ; move b{r4}, b{r9}
        mov cx, r12w
        ; shiftright t.9{r1}, t.9{r1}, b{r4}
        sar di, cl
        ; call printIntLf@i16[t.9{r1}]
        call @printIntLf@i16
        ; const a{r8}, 9
        mov bx, 9
        ; const b{r9}, 2
        mov r12w, 2
        ; move t.10{r1}, a{r8}
        mov di, bx
        ; move b{r4}, b{r9}
        mov cx, r12w
        ; shiftright t.10{r1}, t.10{r1}, b{r4}
        sar di, cl
        ; call printIntLf@i16[t.10{r1}]
        call @printIntLf@i16
        ; const a{r8}, 1
        mov bx, 1
        ; move t.11{r1}, a{r8}
        mov di, bx
        ; move b{r4}, b{r9}
        mov cx, r12w
        ; shiftleft t.11{r1}, t.11{r1}, b{r4}
        sal di, cl
        ; call printIntLf@i16[t.11{r1}]
        call @printIntLf@i16
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

