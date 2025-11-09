format ELF64 executable 3
segment executable
entry _start

_start:
        call @main
        mov rax, 60         ; sys_exit
        xor rdi, rdi        ; exit code 0
        syscall

        ; void printChar
        ;   rsp+64: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; addrof t.1{r8}, chr
        lea rbx, [rsp+64]
        ; const t.2{r2}, 1
        mov rsi, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+64]
        mov [r11], dil
        ; move t.1{r1}, t.1{r8}
        mov rdi, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printUint
        ;   rsp+112: arg number
        ;   rsp+80: var buffer
@printUint:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; const pos{r8}, 20
        mov bl, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r8}
        dec bl
        ; const t.5{r9}, 10
        mov r12, 10
        ; move remainder{r4}, number{r1}
        mov rcx, rdi
        ; move remainder{r0}, remainder{r4}
        mov rax, rcx
        ; mod remainder{r3}, remainder{r0}, t.5{r9}
        cqo
        idiv r12
        ; move remainder{r4}, remainder{r3}
        mov rcx, rdx
        ; const t.6{r9}, 10
        mov r12, 10
        ; move number{r0}, number{r1}
        mov rax, rdi
        ; div number{r0}, number{r0}, t.6{r9}
        cqo
        idiv r12
        ; move number{r1}, number{r0}
        mov rdi, rax
        ; cast t.7{r9}(u8), remainder{r4}(i64)
        mov r12b, cl
        ; const t.8{r0}, 48
        mov al, 48
        ; add digit{r9}, digit{r9}, t.8{r0}
        add r12b, al
        ; cast t.10{r0}(i64), pos{r8}(u8)
        movzx rax, bl
        ; cast t.11{r0}(u8*), t.10{r0}(i64)
        ; addrof t.9{r3}, [buffer]
        lea rdx, [rsp+80]
        ; add t.9{r3}, t.9{r3}, t.11{r0}
        add rdx, rax
        ; store [t.9{r3}], digit{r9}
        mov [rdx], r12b
        ; 19:3 if number == 0
        ; equals t.12{r9}, number{r1}, 0
        cmp rdi, 0
        sete r12b
        ; branch t.12{r9}, false, @while_1
        or r12b, r12b
        jz @while_1
        ; cast t.14{r9}(i64), pos{r8}(u8)
        movzx r12, bl
        ; cast t.15{r9}(u8*), t.14{r9}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rdi, [rsp+80]
        ; add t.13{r1}, t.13{r1}, t.15{r9}
        add rdi, r12
        ; const t.18{r9}, 20
        mov r12b, 20
        ; sub t.17{r9}, t.17{r9}, pos{r8}
        sub r12b, bl
        ; cast t.16{r2}(i64), t.17{r9}(u8)
        movzx rsi, r12b
        ; call printStringLength[t.13{r1}, t.16{r2}]
        call @printStringLength
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 40
        ret

        ; void printIntLf
        ;   rsp+80: arg number
@printIntLf:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; move number{r8}, number{r1}
        mov rbx, rdi
        ; 27:2 if number < 0
        ; lt t.1{r9}, number{r8}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r9}, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov dil, 45
        ; call printChar[t.2{r1}]
        call @printChar
        ; neg number{r8}, number{r8}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r8}
        mov rdi, rbx
        ; call printUint[number{r1}]
        call @printUint
        ; const t.3{r1}, 10
        mov dil, 10
        ; call printChar[t.3{r1}]
        call @printChar
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void initRandom
        ;   rsp+16: arg salt
@initRandom:
        sub rsp, 8
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, edi
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; move tmp.__random__{r0}, __random__
        lea r11, [var_0]
        mov eax, [r11]
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
        ; move t.17{r0}, e{r1}
        mov eax, edi
        ; and t.17{r0}, t.17{r0}, t.18{r2}
        and eax, esi
        ; const t.20{r4}, 31
        mov ecx, 31
        ; shiftright t.19{r1}, t.19{r1}, t.20{r4}
        sar edi, cl
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r1}
        add eax, edi
        ; 118:9 return __random__
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; u8 randomU8
@randomU8:
        sub rsp, 8
        sub rsp, 32
        ; 122:10 return (u8)
        ; call t.1{r0} = random[] -> i32
        call @random
        ; cast t.0{r0}(u8), t.1{r0}(i32)
        add rsp, 32
        add rsp, 8
        ret

        ; void main
@main:
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.__random__{r8}, 0
        mov ebx, 0
        ; end initialize global variables
        ; const t.2{r1}, 7439742
        mov edi, 7439742
        ; move __random__, tmp.__random__{r8}
        lea r11, [var_0]
        mov [r11], ebx
        ; call initRandom[t.2{r1}]
        call @initRandom
        ; const i{r8}, 0
        mov bl, 0
        ; 5:2 for i < 50
        jmp @for_4
@for_4_body:
        ; call r{r0} = randomU8[] -> u8
        call @randomU8
        ; cast t.4{r1}(i64), r{r0}(u8)
        movzx rdi, al
        ; call printIntLf[t.4{r1}]
        call @printIntLf
        ; inc i{r8}
        inc bl
@for_4:
        ; lt t.3{r0}, i{r8}, 50
        cmp bl, 50
        setb al
        ; branch t.3{r0}, true, @for_4_body
        or al, al
        jnz @for_4_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        pop r10
        pop r9
        ret

        ; void printStringLength
@printStringLength:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

segment readable writable
        ; variable 0: __random__ (i32/4)
        var_0 rb 4

