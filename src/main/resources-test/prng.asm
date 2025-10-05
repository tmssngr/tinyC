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

        ; void printChar
        ;   rsp+16: arg chr
@printChar:
        ; save clobbered non-volatile registers
        push rbx
        ; addrof t.1{r6}, chr
        lea rbx, [rsp+16]
        ; const t.2{r2}, 1
        mov rdx, 1
        ; move chr, tmp.chr{r1}
        lea r11, [rsp+16]
        mov [r11], cl
        ; move t.1{r1}, t.1{r6}
        mov rcx, rbx
        ; call printStringLength[t.1{r1}, t.2{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printUint
        ;   rsp+48: arg number
        ;   rsp+20: var buffer
@printUint:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r7}, 20
        mov r12b, 20
        ; 13:2 while true
@while_1:
        ; dec pos{r7}
        dec r12b
        ; const t.5{r3}, 10
        mov r8, 10
        ; move remainder{r4}, number{r6}
        mov r9, rbx
        ; move remainder{r0}, remainder{r4}
        mov rax, r9
        ; mod remainder{r2}, remainder{r0}, t.5{r3}
        cqo
        idiv r8
        ; move remainder{r4}, remainder{r2}
        mov r9, rdx
        ; const t.6{r3}, 10
        mov r8, 10
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, t.6{r3}
        cqo
        idiv r8
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.7{r0}(u8), remainder{r4}(i64)
        mov al, r9b
        ; const t.8{r3}, 48
        mov r8b, 48
        ; add digit{r0}, digit{r0}, t.8{r3}
        add al, r8b
        ; cast t.10{r3}(i64), pos{r7}(u8)
        movzx r8, r12b
        ; cast t.11{r3}(u8*), t.10{r3}(i64)
        ; addrof t.9{r4}, [buffer]
        lea r9, [rsp+20]
        ; add t.9{r4}, t.9{r4}, t.11{r3}
        add r9, r8
        ; store [t.9{r4}], digit{r0}
        mov [r9], al
        ; 19:3 if number == 0
        ; equals t.12{r0}, number{r6}, 0
        cmp rbx, 0
        sete al
        ; branch t.12{r0}, false, @while_1
        or al, al
        jz @while_1
        ; cast t.14{r6}(i64), pos{r7}(u8)
        movzx rbx, r12b
        ; cast t.15{r6}(u8*), t.14{r6}(i64)
        ; addrof t.13{r1}, [buffer]
        lea rcx, [rsp+20]
        ; add t.13{r1}, t.13{r1}, t.15{r6}
        add rcx, rbx
        ; const t.18{r6}, 20
        mov bl, 20
        ; sub t.17{r6}, t.17{r6}, pos{r7}
        sub bl, r12b
        ; cast t.16{r2}(i64), t.17{r6}(u8)
        movzx rdx, bl
        ; call printStringLength[t.13{r1}, t.16{r2}]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void printIntLf
        ;   rsp+32: arg number
@printIntLf:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; 27:2 if number < 0
        ; lt t.1{r7}, number{r6}, 0
        cmp rbx, 0
        setl r12b
        ; branch t.1{r7}, false, @if_3_end
        or r12b, r12b
        jz @if_3_end
        ; const t.2{r1}, 45
        mov cl, 45
        ; call printChar[t.2{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; neg number{r6}, number{r6}
        neg rbx
@if_3_end:
        ; move number{r1}, number{r6}
        mov rcx, rbx
        ; call printUint[number{r1}]
        sub rsp, 20h; shadow space
        call @printUint
        add rsp, 20h
        ; const t.3{r1}, 10
        mov cl, 10
        ; call printChar[t.3{r1}]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void initRandom
        ;   rsp+16: arg salt
@initRandom:
        sub rsp, 8
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, ecx
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
        ; move r{r2}, tmp.__random__{r0}
        mov edx, eax
        ; const t.6{r3}, 524287
        mov r8d, 524287
        ; move t.5{r4}, r{r2}
        mov r9d, edx
        ; and t.5{r4}, t.5{r4}, t.6{r3}
        and r9d, r8d
        ; const t.7{r3}, 48271
        mov r8d, 48271
        ; mul b{r4}, b{r4}, t.7{r3}
        movsxd r9, r9d
        movsxd r8, r8d
        imul  r9, r8
        ; const t.9{r1}, 15
        mov ecx, 15
        ; shiftright t.8{r2}, t.8{r2}, t.9{r1}
        sar edx, cl
        ; const t.10{r3}, 48271
        mov r8d, 48271
        ; mul c{r2}, c{r2}, t.10{r3}
        movsxd rdx, edx
        movsxd r8, r8d
        imul  rdx, r8
        ; const t.12{r3}, 65535
        mov r8d, 65535
        ; move t.11{r5}, c{r2}
        mov r10d, edx
        ; and t.11{r5}, t.11{r5}, t.12{r3}
        and r10d, r8d
        ; const t.13{r1}, 15
        mov ecx, 15
        ; move d{r3}, t.11{r5}
        mov r8d, r10d
        ; shiftleft d{r3}, d{r3}, t.13{r1}
        sal r8d, cl
        ; const t.16{r1}, 16
        mov ecx, 16
        ; shiftright t.15{r2}, t.15{r2}, t.16{r1}
        sar edx, cl
        ; add t.14{r2}, t.14{r2}, b{r4}
        add edx, r9d
        ; add e{r2}, e{r2}, d{r3}
        add edx, r8d
        ; const t.18{r3}, 2147483647
        mov r8d, 2147483647
        ; move t.17{r4}, e{r2}
        mov r9d, edx
        ; and t.17{r4}, t.17{r4}, t.18{r3}
        and r9d, r8d
        ; const t.20{r1}, 31
        mov ecx, 31
        ; shiftright t.19{r2}, t.19{r2}, t.20{r1}
        sar edx, cl
        ; move tmp.__random__{r0}, t.17{r4}
        mov eax, r9d
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r2}
        add eax, edx
        ; 123:9 return __random__
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; u8 randomU8
@randomU8:
        sub rsp, 8
        ; 127:10 return (u8)
        ; call t.1{r0} = random[] -> i32
        sub rsp, 20h; shadow space
        call @random
        add rsp, 20h
        ; cast t.0{r0}(u8), t.1{r0}(i32)
        add rsp, 8
        ret

        ; void main
@main:
        ; save clobbered non-volatile registers
        push rbx
        ; begin initialize global variables
        ; const tmp.__random__{r6}, 0
        mov ebx, 0
        ; end initialize global variables
        ; const t.2{r1}, 7439742
        mov ecx, 7439742
        ; move __random__, tmp.__random__{r6}
        lea r11, [var_0]
        mov [r11], ebx
        ; call initRandom[t.2{r1}]
        sub rsp, 20h; shadow space
        call @initRandom
        add rsp, 20h
        ; const i{r6}, 0
        mov bl, 0
        ; 5:2 for i < 50
        jmp @for_4
@for_4_body:
        ; call r{r0} = randomU8[] -> u8
        sub rsp, 20h; shadow space
        call @randomU8
        add rsp, 20h
        ; cast t.4{r1}(i64), r{r0}(u8)
        movzx rcx, al
        ; call printIntLf[t.4{r1}]
        sub rsp, 20h; shadow space
        call @printIntLf
        add rsp, 20h
        ; inc i{r6}
        inc bl
@for_4:
        ; lt t.3{r0}, i{r6}, 50
        cmp bl, 50
        setb al
        ; branch t.3{r0}, true, @for_4_body
        or al, al
        jnz @for_4_body
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printStringLength
@printStringLength:
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
        ; variable 0: __random__ (i32/4)
        var_0 rb 4

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
