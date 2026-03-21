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

        ; i16 printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ;   rsp+64: arg a
        ;   rsp+72: arg b
        ;   rsp+80: arg c
        ;   rsp+88: arg d
        ;   rsp+96: arg e
        ;   rsp+104: arg f
        ;   rsp+112: arg g
        ;   rsp+120: arg h
@printAndSum@i16@i16@i16@i16@i16@i16@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, h
        lea r12, [rsp+120]
        ; load h{r6}, [memVarAddr{r7}]
        mov bx, [r12]
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], b{r2}
        mov [r12], dx
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], c{r3}
        mov [r12], r8w
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], d{r4}
        mov [r12], r9w
        ; addrof memVarAddr{r7}, a
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], a{r1}
        mov [r12], cx
        ; call printIntLf@i16[a{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+72]
        ; load b{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+72]
        ; store [memVarAddr{r7}], b{r1}
        mov [r12], cx
        ; call printIntLf@i16[b{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+80]
        ; load c{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], c{r1}
        mov [r12], cx
        ; call printIntLf@i16[c{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+88]
        ; load d{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+88]
        ; store [memVarAddr{r7}], d{r1}
        mov [r12], cx
        ; call printIntLf@i16[d{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, e
        lea r12, [rsp+96]
        ; load e{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, e
        lea r12, [rsp+96]
        ; store [memVarAddr{r7}], e{r1}
        mov [r12], cx
        ; call printIntLf@i16[e{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+104]
        ; load f{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+104]
        ; store [memVarAddr{r7}], f{r1}
        mov [r12], cx
        ; call printIntLf@i16[f{r1}]
        call @printIntLf@i16
        ; addrof memVarAddr{r7}, g
        lea r12, [rsp+112]
        ; load g{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, g
        lea r12, [rsp+112]
        ; store [memVarAddr{r7}], g{r1}
        mov [r12], cx
        ; call printIntLf@i16[g{r1}]
        call @printIntLf@i16
        ; move h{r1}, h{r6}
        mov cx, bx
        ; call printIntLf@i16[h{r1}]
        call @printIntLf@i16
        ; 17:35 return a + b + c + d + e + f + g + h
        ; addrof memVarAddr{r7}, a
        lea r12, [rsp+64]
        ; load a{r1}, [memVarAddr{r7}]
        mov cx, [r12]
        ; addrof memVarAddr{r7}, b
        lea r12, [rsp+72]
        ; load b{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add t.14{r1}, t.14{r1}, b{r2}
        add cx, dx
        ; addrof memVarAddr{r7}, c
        lea r12, [rsp+80]
        ; load c{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add t.13{r1}, t.13{r1}, c{r2}
        add cx, dx
        ; addrof memVarAddr{r7}, d
        lea r12, [rsp+88]
        ; load d{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add t.12{r1}, t.12{r1}, d{r2}
        add cx, dx
        ; addrof memVarAddr{r7}, e
        lea r12, [rsp+96]
        ; load e{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add t.11{r1}, t.11{r1}, e{r2}
        add cx, dx
        ; addrof memVarAddr{r7}, f
        lea r12, [rsp+104]
        ; load f{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add t.10{r1}, t.10{r1}, f{r2}
        add cx, dx
        ; addrof memVarAddr{r7}, g
        lea r12, [rsp+112]
        ; load g{r2}, [memVarAddr{r7}]
        mov dx, [r12]
        ; add t.9{r1}, t.9{r1}, g{r2}
        add cx, dx
        ; move t.8{r0}, t.9{r1}
        mov ax, cx
        ; add t.8{r0}, t.8{r0}, h{r6}
        add ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
        ;   rsp+80: var t.4
        ;   rsp+32: var arg.0.4
        ;   rsp+40: var arg.0.5
        ;   rsp+48: var arg.0.6
        ;   rsp+56: var arg.0.7
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 64
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.1{r1}, 1
        mov cx, 1
        ; const t.2{r2}, 2
        mov dx, 2
        ; const t.3{r3}, 3
        mov r8w, 3
        ; const t.4{r4}, 4
        mov r9w, 4
        ; const t.5{r6}, 5
        mov bx, 5
        ; const t.6{r0}, 6
        mov ax, 6
        ; const t.7{r5}, 7
        mov r10w, 7
        ; addrof memVarAddr{r7}, t.4
        lea r12, [rsp+80]
        ; store [memVarAddr{r7}], t.4{r4}
        mov [r12], r9w
        ; const t.8{r4}, 8
        mov r9w, 8
        ; addrof memVarAddr{r7}, arg.0.4
        lea r12, [rsp+32]
        ; store [memVarAddr{r7}], t.5{r6}
        mov [r12], bx
        ; addrof memVarAddr{r7}, arg.0.5
        lea r12, [rsp+40]
        ; store [memVarAddr{r7}], t.6{r0}
        mov [r12], ax
        ; addrof memVarAddr{r7}, arg.0.6
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], t.7{r5}
        mov [r12], r10w
        ; addrof memVarAddr{r7}, arg.0.7
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], t.8{r4}
        mov [r12], r9w
        ; addrof memVarAddr{r7}, t.4
        lea r12, [rsp+80]
        ; load t.4{r4}, [memVarAddr{r7}]
        mov r9w, [r12]
        ; call sum{r0} = printAndSum@i16@i16@i16@i16@i16@i16@i16@i16[t.1{r1}, t.2{r2}, t.3{r3}, t.4{r4}, arg.0.4, arg.0.5, arg.0.6, arg.0.7] -> i16
        call @printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ; move sum{r1}, sum{r0}
        mov cx, ax
        ; call printIntLf@i16[sum{r1}]
        call @printIntLf@i16
        add rsp, 64
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
