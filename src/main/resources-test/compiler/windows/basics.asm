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

        ; void printUint@u8
        ;   rsp+48: arg number
@printUint@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call printUint@i64[t.1{r1}]
        call @printUint@i64
        add rsp, 32
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

        ; i64 unusedArgs@u8@bool@u8@u8
        ;   rsp+16: arg a
        ;   rsp+24: arg b
        ;   rsp+32: arg c
        ;   rsp+40: arg d
@unusedArgs@u8@bool@u8@u8:
        sub rsp, 8
        ; 9:10 return (i64)
        ; cast t.4{r0}(i64), c{r3}(u8)
        movzx rax, r8b
        add rsp, 8
        ret

        ; void main
        ;   rsp+48: var t.5
        ;   rsp+49: var t.6
@main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.zero{r6}, 48
        mov bl, 48
        ; const tmp.one{r0}, 49
        mov al, 49
        ; const tmp.two{r5}, 50
        mov r10b, 50
        ; const tmp.threeFour{r1}, 34
        mov cl, 34
        ; end initialize global variables
        ; const t.3{r4}, 1
        mov r9b, 1
        ; const t.4{r2}, 1
        mov dl, 1
        ; const t.5{r3}, 2
        mov r8b, 2
        ; addrof memVarAddr{r7}, t.5
        lea r12, [rsp+48]
        ; store [memVarAddr{r7}], t.5{r3}
        mov [r12], r8b
        ; const t.6{r3}, 3
        mov r8b, 3
        ; addrof memVarAddr{r7}, t.6
        lea r12, [rsp+49]
        ; store [memVarAddr{r7}], t.6{r3}
        mov [r12], r8b
        ; addrof memVarAddr{r7}, zero
        lea r12, [var_0]
        ; store [memVarAddr{r7}], tmp.zero{r6}
        mov [r12], bl
        ; addrof memVarAddr{r7}, one
        lea r12, [var_1]
        ; store [memVarAddr{r7}], tmp.one{r0}
        mov [r12], al
        ; addrof memVarAddr{r7}, two
        lea r12, [var_2]
        ; store [memVarAddr{r7}], tmp.two{r5}
        mov [r12], r10b
        ; addrof memVarAddr{r7}, threeFour
        lea r12, [var_3]
        ; store [memVarAddr{r7}], tmp.threeFour{r1}
        mov [r12], cl
        ; move t.3{r1}, t.3{r4}
        mov cl, r9b
        ; addrof memVarAddr{r7}, t.5
        lea r12, [rsp+48]
        ; load t.5{r3}, [memVarAddr{r7}]
        mov r8b, [r12]
        ; addrof memVarAddr{r7}, t.6
        lea r12, [rsp+49]
        ; load t.6{r4}, [memVarAddr{r7}]
        mov r9b, [r12]
        ; call _ = unusedArgs@u8@bool@u8@u8[t.3{r1}, t.4{r2}, t.5{r3}, t.6{r4}] -> i64
        call @unusedArgs@u8@bool@u8@u8
        ; addrof memVarAddr{r7}, zero
        lea r12, [var_0]
        ; load tmp.zero{r6}, [memVarAddr{r7}]
        mov bl, [r12]
        ; move tmp.zero{r1}, tmp.zero{r6}
        mov cl, bl
        ; call printChar@u8[tmp.zero{r1}]
        call @printChar@u8
        ; addrof onePtr{r6}, one
        lea rbx, [var_1]
        ; load t.7{r1}, [onePtr{r6}]
        mov cl, [rbx]
        ; call printChar@u8[t.7{r1}]
        call @printChar@u8
        ; addrof twoPtr{r6}, two
        lea rbx, [var_2]
        ; const t.10{r0}, 0
        mov rax, 0
        ; add t.9{r6}, t.9{r6}, t.10{r0}
        add rbx, rax
        ; load t.8{r1}, [t.9{r6}]
        mov cl, [rbx]
        ; call printChar@u8[t.8{r1}]
        call @printChar@u8
        ; addrof memVarAddr{r7}, threeFour
        lea r12, [var_3]
        ; load tmp.threeFour{r1}, [memVarAddr{r7}]
        mov cl, [r12]
        ; call printUint@u8[tmp.threeFour{r1}]
        call @printUint@u8
        ; const t.11{r1}, 10
        mov cl, 10
        ; call printChar@u8[t.11{r1}]
        call @printChar@u8
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
