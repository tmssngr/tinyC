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
        ;   rsp+32: var t.1
        ;   rsp+33: var t.2
        ;   rsp+34: var t.3
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; begin initialize global variables
        ; const tmp.i{r8}, 0
        mov bl, 0
        ; end initialize global variables
        ; addrof memVarAddr{r9}, i
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.i{r8}
        mov [r12], bl
        ; call t.0{r0} = next[] -> u8
        call @next
        ; move t.0{r8}, t.0{r0}
        mov bl, al
        ; call t.1{r0} = next[] -> u8
        call @next
        ; addrof memVarAddr{r9}, t.1
        lea r12, [rsp+32]
        ; store [memVarAddr{r9}], t.1{r0}
        mov [r12], al
        ; call t.2{r0} = next[] -> u8
        call @next
        ; addrof memVarAddr{r9}, t.2
        lea r12, [rsp+33]
        ; store [memVarAddr{r9}], t.2{r0}
        mov [r12], al
        ; call t.3{r0} = next[] -> u8
        call @next
        ; addrof memVarAddr{r9}, t.3
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], t.3{r0}
        mov [r12], al
        ; call t.4{r0} = next[] -> u8
        call @next
        ; move t.0{r1}, t.0{r8}
        mov dil, bl
        ; addrof memVarAddr{r9}, t.1
        lea r12, [rsp+32]
        ; load t.1{r2}, [memVarAddr{r9}]
        mov sil, [r12]
        ; addrof memVarAddr{r9}, t.2
        lea r12, [rsp+33]
        ; load t.2{r3}, [memVarAddr{r9}]
        mov dl, [r12]
        ; addrof memVarAddr{r9}, t.3
        lea r12, [rsp+34]
        ; load t.3{r4}, [memVarAddr{r9}]
        mov cl, [r12]
        ; move t.4{r5}, t.4{r0}
        mov r8b, al
        ; call doPrint@u8@u8@u8@u8@u8[t.0{r1}, t.1{r2}, t.2{r3}, t.3{r4}, t.4{r5}]
        call @doPrint@u8@u8@u8@u8@u8
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; u8 next
@next:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; const t.0{r1}, 1
        mov dil, 1
        ; addrof memVarAddr{r9}, i
        lea r12, [var_0]
        ; load tmp.i{r0}, [memVarAddr{r9}]
        mov al, [r12]
        ; add tmp.i{r0}, tmp.i{r0}, t.0{r1}
        add al, dil
        ; 11:9 return i
        ; addrof memVarAddr{r9}, i
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.i{r0}
        mov [r12], al
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void doPrint@u8@u8@u8@u8@u8
        ;   rsp+32: arg a
        ;   rsp+33: arg b
        ;   rsp+34: arg c
        ;   rsp+35: arg d
        ;   rsp+36: arg e
@doPrint@u8@u8@u8@u8@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move b{r8}, b{r2}
        mov bl, sil
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; store [memVarAddr{r9}], c{r3}
        mov [r12], dl
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; store [memVarAddr{r9}], d{r4}
        mov [r12], cl
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+36]
        ; store [memVarAddr{r9}], e{r5}
        mov [r12], r8b
        ; call printIntLf@u8[a{r1}]
        call @printIntLf@u8
        ; move b{r1}, b{r8}
        mov dil, bl
        ; call printIntLf@u8[b{r1}]
        call @printIntLf@u8
        ; addrof memVarAddr{r9}, c
        lea r12, [rsp+34]
        ; load c{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[c{r1}]
        call @printIntLf@u8
        ; addrof memVarAddr{r9}, d
        lea r12, [rsp+35]
        ; load d{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[d{r1}]
        call @printIntLf@u8
        ; addrof memVarAddr{r9}, e
        lea r12, [rsp+36]
        ; load e{r1}, [memVarAddr{r9}]
        mov dil, [r12]
        ; call printIntLf@u8[e{r1}]
        call @printIntLf@u8
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

segment readable writable
        ; variable 0: i (u8/1)
        var_0 rb 1

