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
        call _main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printChar@u8
        ;   rsp+64: arg chr
_printChar@u8:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; addrof memVarAddr{r7}, chr
        lea r12, [rsp+64]
        ; store [memVarAddr{r7}], chr{r1}
        mov [r12], cl
        ; addrof t.1.1{r1}, chr
        lea rcx, [rsp+64]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printUint@u8
        ;   rsp+48: arg number
_printUint@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call printUint@i64[t.1.1{r1}]
        call _printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 32
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 28:2 while true
        ; move number.1{r3}, number{r1}
        mov r8, rcx
_while_1:
        ; sub pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r4}, number.1{r3}
        mov r9, r8
        ; move remainder.1{r0}, remainder.1{r4}
        mov rax, r9
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r4}, remainder.1{r2}
        mov r9, rdx
        ; move number.2{r0}, number.2{r3}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r3}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r4}(i64)
        mov al, r9b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r4}(i64), pos.3{r6}(u8)
        movzx r9, bl
        ; addrof t.6.1{r5}, buffer
        lea r10, [rsp+40]
        ; add t.6.2{r5}, t.7.1{r4}
        add r10, r9
        ; store [t.6.2{r5}], digit.1{r0}
        mov [r10], al
        ; 34:3 if number == 0
        ; branch number.2{r3} notequals 0: while_1
        cmp r8, 0
        jne _while_1
        ; cast t.9.1{r0}(i64), pos.3{r6}(u8)
        movzx rax, bl
        ; addrof t.8.1{r3}, buffer
        lea r8, [rsp+40]
        ; move t.8.2{r1}, t.8.1{r3}
        mov rcx, r8
        ; add t.8.2{r1}, t.9.1{r0}
        add rcx, rax
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov dl, al
        ; sub t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        add rsp, 32
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; i64 unusedArgs@u8@bool@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
        ;   rsp+32: arg c
        ;   rsp+40: arg d
_unusedArgs@u8@bool@u8@u8:
        sub rsp, 8
        ; 9:10 return (i64)
        ; cast t.4.1{r0}(i64), c{r3}(u8)
        movzx rax, r8b
        add rsp, 8
        ret

        ; void main
_main:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; begin initialize global variables
        ; const t.3.1{r6}, 48
        mov bl, 48
        ; addrof a.4.1{r0}, zero
        lea rax, [var_0]
        ; store [a.4.1{r0}], t.3.1{r6}
        mov [rax], bl
        ; const t.5.1{r6}, 49
        mov bl, 49
        ; addrof a.6.1{r0}, one
        lea rax, [var_1]
        ; store [a.6.1{r0}], t.5.1{r6}
        mov [rax], bl
        ; const t.7.1{r6}, 50
        mov bl, 50
        ; addrof a.8.1{r0}, two
        lea rax, [var_2]
        ; store [a.8.1{r0}], t.7.1{r6}
        mov [rax], bl
        ; const t.9.1{r6}, 34
        mov bl, 34
        ; addrof a.10.1{r0}, threeFour
        lea rax, [var_3]
        ; store [a.10.1{r0}], t.9.1{r6}
        mov [rax], bl
        ; end initialize global variables
        ; const t.11.1{r2}, 1
        mov dl, 1
        ; const arg.0.0{r1}, 1
        mov cl, 1
        ; const arg.0.2{r3}, 2
        mov r8b, 2
        ; const arg.0.3{r4}, 3
        mov r9b, 3
        ; call _ = unusedArgs@u8@bool@u8@u8[arg.0.0{r1}, t.11.1{r2}, arg.0.2{r3}, arg.0.3{r4}] -> i64
        call _unusedArgs@u8@bool@u8@u8
        ; addrof a.12.1{r6}, zero
        lea rbx, [var_0]
        ; load t.13.1{r1}, [a.12.1{r6}]
        mov cl, [rbx]
        ; call printChar@u8[t.13.1{r1}]
        call _printChar@u8
        ; addrof onePtr.1{r6}, one
        lea rbx, [var_1]
        ; load t.14.1{r1}, [onePtr.1{r6}]
        mov cl, [rbx]
        ; call printChar@u8[t.14.1{r1}]
        call _printChar@u8
        ; addrof twoPtr.1{r6}, two
        lea rbx, [var_2]
        ; const t.17.1{r0}, 0
        mov rax, 0
        ; add t.16.2{r6}, t.17.1{r0}
        add rbx, rax
        ; load t.15.1{r1}, [t.16.2{r6}]
        mov cl, [rbx]
        ; call printChar@u8[t.15.1{r1}]
        call _printChar@u8
        ; addrof a.18.1{r6}, threeFour
        lea rbx, [var_3]
        ; load t.19.1{r1}, [a.18.1{r6}]
        mov cl, [rbx]
        ; call printUint@u8[t.19.1{r1}]
        call _printUint@u8
        ; const arg.5.0{r1}, 10
        mov cl, 10
        ; call printChar@u8[arg.5.0{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
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
        ; variable 0: zero (u8/1)
        var_0 rb 1
        ; variable 1: one (u8/1)
        var_1 rb 1
        ; variable 2: two (u8/1)
        var_2 rb 1
        ; variable 3: threeFour (u8/1)
        var_3 rb 1

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
