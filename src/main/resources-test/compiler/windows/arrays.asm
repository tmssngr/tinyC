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
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r3}, 20
        mov r8b, 20
        ; 33:2 while true
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
        ; 39:3 if number == 0
        ; const t.9{r0}, 0
        mov rax, 0
        ; equals t.8{r0}, number{r6}, t.9{r0}
        cmp rbx, rax
        sete al
        ; branch t.8{r0}, false, @while_1, @while_1_break
        or al, al
        jz @while_1
        ; cast t.11{r6}(i64), pos{r3}(u8)
        movzx rbx, r8b
        ; addrof t.10{r1}, [buffer]
        lea rcx, [rsp+40]
        ; add t.10{r1}, t.10{r1}, t.11{r6}
        add rcx, rbx
        ; const t.13{r6}, 20
        mov bl, 20
        ; move t.12{r2}, t.13{r6}
        mov dl, bl
        ; sub t.12{r2}, t.12{r2}, pos{r3}
        sub dl, r8b
        ; call printStringLength@@u8@u8[t.10{r1}, t.12{r2}]
        call @printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
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
        ; 59:2 if number < 0
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

        ; void main
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const chr{r6}, 32
        mov bl, 32
        ; const t.3{r7}, 0
        mov r12, 0
        ; addrof t.2{r0}, [chars]
        lea rax, [var_0]
        ; add t.2{r0}, t.2{r0}, t.3{r7}
        add rax, r12
        ; store [t.2{r0}], chr{r6}
        mov [rax], bl
        ; const t.7{r6}, 0
        mov rbx, 0
        ; addrof t.6{r7}, [chars]
        lea r12, [var_0]
        ; add t.6{r7}, t.6{r7}, t.7{r6}
        add r12, rbx
        ; load t.5{r6}, [t.6{r7}]
        mov bl, [r12]
        ; add t.4{r6}, t.4{r6}, 1
        add bl, 1
        ; const t.9{r7}, 1
        mov r12, 1
        ; addrof t.8{r0}, [chars]
        lea rax, [var_0]
        ; add t.8{r0}, t.8{r0}, t.9{r7}
        add rax, r12
        ; store [t.8{r0}], t.4{r6}
        mov [rax], bl
        ; const t.13{r6}, 1
        mov rbx, 1
        ; addrof t.12{r7}, [chars]
        lea r12, [var_0]
        ; add t.12{r7}, t.12{r7}, t.13{r6}
        add r12, rbx
        ; load t.11{r6}, [t.12{r7}]
        mov bl, [r12]
        ; add t.10{r6}, t.10{r6}, 2
        add bl, 2
        ; const t.15{r7}, 2
        mov r12, 2
        ; addrof t.14{r0}, [chars]
        lea rax, [var_0]
        ; add t.14{r0}, t.14{r0}, t.15{r7}
        add rax, r12
        ; store [t.14{r0}], t.10{r6}
        mov [rax], bl
        ; const t.17{r6}, 2
        mov rbx, 2
        ; addrof t.16{r7}, [chars]
        lea r12, [var_0]
        ; add t.16{r7}, t.16{r7}, t.17{r6}
        add r12, rbx
        ; load result{r1}, [t.16{r7}]
        mov cl, [r12]
        ; call printIntLf@u8[result{r1}]
        call @printIntLf@u8
        add rsp, 32
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
        ; variable 0: chars[] (u8*/2048)
        var_0 rb 2048

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
