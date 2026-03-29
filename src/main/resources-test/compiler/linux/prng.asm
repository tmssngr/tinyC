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

        ; void initRandom@i32
        ;   rsp+32: arg salt
@initRandom@i32:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, edi
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r0}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; load tmp.__random__{r0}, [memVarAddr{r9}]
        mov eax, [r12]
        ; move r{r1}, tmp.__random__{r0}
        mov edi, eax
        ; const t.6{r2}, 524287
        mov esi, 524287
        ; move t.5{r3}, r{r1}
        mov edx, edi
        ; and t.5{r3}, t.5{r3}, t.6{r2}
        and edx, esi
        ; const t.7{r2}, 48271
        mov esi, 48271
        ; mul b{r3}, b{r3}, t.7{r2}
        movsxd rdx, edx
        movsxd rsi, esi
        imul  rdx, rsi
        ; const t.9{r4}, 15
        mov ecx, 15
        ; shiftright t.8{r1}, t.8{r1}, t.9{r4}
        sar edi, cl
        ; const t.10{r2}, 48271
        mov esi, 48271
        ; mul c{r1}, c{r1}, t.10{r2}
        movsxd rdi, edi
        movsxd rsi, esi
        imul  rdi, rsi
        ; const t.12{r2}, 65535
        mov esi, 65535
        ; move t.11{r5}, c{r1}
        mov r8d, edi
        ; and t.11{r5}, t.11{r5}, t.12{r2}
        and r8d, esi
        ; const t.13{r4}, 15
        mov ecx, 15
        ; move d{r2}, t.11{r5}
        mov esi, r8d
        ; shiftleft d{r2}, d{r2}, t.13{r4}
        sal esi, cl
        ; const t.16{r4}, 16
        mov ecx, 16
        ; shiftright t.15{r1}, t.15{r1}, t.16{r4}
        sar edi, cl
        ; add t.14{r1}, t.14{r1}, b{r3}
        add edi, edx
        ; add e{r1}, e{r1}, d{r2}
        add edi, esi
        ; const t.18{r2}, 2147483647
        mov esi, 2147483647
        ; move t.17{r3}, e{r1}
        mov edx, edi
        ; and t.17{r3}, t.17{r3}, t.18{r2}
        and edx, esi
        ; const t.20{r4}, 31
        mov ecx, 31
        ; shiftright t.19{r1}, t.19{r1}, t.20{r4}
        sar edi, cl
        ; move tmp.__random__{r0}, t.17{r3}
        mov eax, edx
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r1}
        add eax, edi
        ; 142:9 return __random__
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r0}
        mov [r12], eax
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; u8 randomU8
@randomU8:
        sub rsp, 8
        ; 146:10 return (u8)
        ; call t.1{r0} = random[] -> i32
        call @random
        ; cast t.0{r0}(u8), t.1{r0}(i32)
        add rsp, 8
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
        ; const tmp.__random__{r8}, 0
        mov ebx, 0
        ; end initialize global variables
        ; const t.2{r1}, 7439742
        mov edi, 7439742
        ; addrof memVarAddr{r9}, __random__
        lea r12, [var_0]
        ; store [memVarAddr{r9}], tmp.__random__{r8}
        mov [r12], ebx
        ; call initRandom@i32[t.2{r1}]
        call @initRandom@i32
        ; const i{r8}, 0
        mov bl, 0
        ; 5:2 for i < 50
        jmp @for_4
@for_4_body:
        ; call r{r0} = randomU8[] -> u8
        call @randomU8
        ; move r{r1}, r{r0}
        mov dil, al
        ; call printIntLf@u8[r{r1}]
        call @printIntLf@u8
        ; const t.5{r0}, 1
        mov al, 1
        ; add i{r8}, i{r8}, t.5{r0}
        add bl, al
@for_4:
        ; const t.4{r0}, 50
        mov al, 50
        ; lt t.3{r0}, i{r8}, t.4{r0}
        cmp bl, al
        setb al
        ; branch t.3{r0}, true, @for_4_body, @main_ret
        or al, al
        jnz @for_4_body
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
        ; variable 0: __random__ (i32/4)
        var_0 rb 4

