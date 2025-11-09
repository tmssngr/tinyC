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

        ; void main
        ;   rsp+64: var pos
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push r9
        push r10
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.2{r8}, 1
        mov bl, 1
        ; 9:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=9:2].x
        ; addrof t.3{r9}, pos
        lea r12, [rsp+64]
        ; store [t.3{r9}], t.2{r8}
        mov [r12], bl
        ; 10:14 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:10].x
        ; addrof t.6{r8}, pos
        lea rbx, [rsp+64]
        ; load t.5{r8}, [t.6{r8}]
        mov bl, [rbx]
        ; const t.7{r9}, 1
        mov r12b, 1
        ; add t.4{r8}, t.4{r8}, t.7{r9}
        add bl, r12b
        ; 10:6 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=10:2].y
        ; addrof t.8{r9}, pos
        lea r12, [rsp+64]
        ; inc t.8{r9}
        inc r12
        ; store [t.8{r9}], t.4{r8}
        mov [r12], bl
        ; 11:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=11:13].x
        ; addrof t.11{r8}, pos
        lea rbx, [rsp+64]
        ; load t.10{r8}, [t.11{r8}]
        mov bl, [rbx]
        ; cast t.9{r1}(i64), t.10{r8}(u8)
        movzx rdi, bl
        ; call printIntLf[t.9{r1}]
        call @printIntLf
        ; 12:17 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=12:13].y
        ; addrof t.14{r8}, pos
        lea rbx, [rsp+64]
        ; inc t.14{r8}
        inc rbx
        ; load t.13{r8}, [t.14{r8}]
        mov bl, [rbx]
        ; cast t.12{r1}(i64), t.13{r8}(u8)
        movzx rdi, bl
        ; call printIntLf[t.12{r1}]
        call @printIntLf
        ; 13:15 ExprVarAccess[varName=pos, index=0, scope=function, type=Pos, varIsArray=false, location=13:11].x
        ; addrof x{r8}, pos
        lea rbx, [rsp+64]
        ; load t.16{r8}, [x{r8}]
        mov bl, [rbx]
        ; cast t.15{r1}(i64), t.16{r8}(u8)
        movzx rdi, bl
        ; call printIntLf[t.15{r1}]
        call @printIntLf
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        pop r10
        pop r9
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
        mov rdx, rsi
        mov rsi, rdi
        mov rdi, 1
        mov rax, 1
        syscall
        ret

