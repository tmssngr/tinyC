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
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
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
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r3}, 20
        mov r8b, 20
        ; 28:2 while true
@while_1:
        ; sub pos{r3}, pos{r3}, 1
        sub r8b, 1
        ; move remainder{r4}, number{r6}
        mov r9, rbx
        ; move remainder{r0}, remainder{r4}
        mov rax, r9
        ; mod remainder{r2}, remainder{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder{r4}, remainder{r2}
        mov r9, rdx
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.5{r0}(u8), remainder{r4}(i64)
        mov al, r9b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r4}(i64), pos{r3}(u8)
        movzx r9, r8b
        ; addrof t.6{r5}, [buffer]
        lea r10, [rsp+40]
        ; add t.6{r5}, t.6{r5}, t.7{r4}
        add r10, r9
        ; store [t.6{r5}], digit{r0}
        mov [r10], al
        ; 34:3 if number == 0
        ; equals t.8{r0}, number{r6}, 0
        cmp rbx, 0
        sete al
        ; branch t.8{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.10{r6}(i64), pos{r3}(u8)
        movzx rbx, r8b
        ; addrof t.9{r1}, [buffer]
        lea rcx, [rsp+40]
        ; add t.9{r1}, t.9{r1}, t.10{r6}
        add rcx, rbx
        ; const t.12{r6}, 20
        mov bl, 20
        ; move t.11{r2}, t.12{r6}
        mov dl, bl
        ; sub t.11{r2}, t.11{r2}, pos{r3}
        sub dl, r8b
        ; call printStringLength@@u8@u8[t.9{r1}, t.11{r2}]
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
        movsx rcx, cx
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
        ; 54:2 if number < 0
        ; lt t.1{r7}, number{r6}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r7}, false, @if_3_end, @if_3_then
        or r12b, r12b
        jz @if_3_end
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call printChar@u8[arg.0.0{r1}]
        call @printChar@u8
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint@i64[number{r1}]
        call @printUint@i64
        ; const arg.2.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.2.0{r1}]
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
        ; const argLit.0.4{r0}, 5
        mov ax, 5
        ; addrof memVarAddr{r7}, arg.0.4
        lea r12, [rsp+32]
        ; store [memVarAddr{r7}], argLit.0.4{r0}
        mov [r12], ax
        ; const argLit.0.5{r0}, 6
        mov ax, 6
        ; addrof memVarAddr{r7}, arg.0.5
        lea r12, [rsp+40]
        ; store [memVarAddr{r7}], argLit.0.5{r0}
        mov [r12], ax
        ; const argLit.0.6{r0}, 7
        mov ax, 7
        ; addrof memVarAddr{r7}, arg.0.6
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], argLit.0.6{r0}
        mov [r12], ax
        ; const argLit.0.7{r0}, 8
        mov ax, 8
        ; addrof memVarAddr{r7}, arg.0.7
        lea r12, [rsp+56]
        ; store [memVarAddr{r7}], argLit.0.7{r0}
        mov [r12], ax
        ; const arg.0.0{r1}, 1
        mov cx, 1
        ; const arg.0.1{r2}, 2
        mov dx, 2
        ; const arg.0.2{r3}, 3
        mov r8w, 3
        ; const arg.0.3{r4}, 4
        mov r9w, 4
        ; call sum{r0} = printAndSum@i16@i16@i16@i16@i16@i16@i16@i16[arg.0.0{r1}, arg.0.1{r2}, arg.0.2{r3}, arg.0.3{r4}, arg.0.4, arg.0.5, arg.0.6, arg.0.7] -> i16
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
