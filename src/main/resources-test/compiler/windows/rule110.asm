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

        ; void printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

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
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+64]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 64:2 for *str != 0
        jmp _for_1
_for_1_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rcx, 1
_for_1:
        ; load t.2{r2}, [str{r1}]
        mov dl, [rcx]
        ; branch t.2{r2} notequals 0: for_1_body, for_1_break
        cmp dl, 0
        jne _for_1_body
        ; 67:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printBoard
_printBoard:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const arg.0.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; const i{r6}, 0
        mov bl, 0
        ; 11:2 for i < 30
        jmp _for_2
_for_2_body:
        ; 12:3 if [...] == 0
        ; cast t.3{r7}(i64), i{r6}(u8)
        movzx r12, bl
        ; addrof t.2{r0}, [board]
        lea rax, [var_0]
        ; add t.2{r0}, t.2{r0}, t.3{r7}
        add rax, r12
        ; load t.1{r7}, [t.2{r0}]
        mov r12b, [rax]
        ; branch t.1{r7} equals 0: if_3_then, if_3_else
        cmp r12b, 0
        je _if_3_then
        ; const arg.2.0{r1}, 42
        mov cl, 42
        ; call printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        jmp _for_2_continue
_if_3_then:
        ; const arg.1.0{r1}, 32
        mov cl, 32
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
_for_2_continue:
        ; add i{r6}, i{r6}, 1
        add bl, 1
_for_2:
        ; branch i{r6} lt 30: for_2_body, for_2_break
        cmp bl, 30
        jb _for_2_body
        ; const t.4{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.4{r1}]
        call _printString@@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void main
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const i{r6}, 0
        mov bl, 0
        ; 23:2 for i < 30
        jmp _for_4
_for_4_body:
        ; const t.4{r7}, 0
        mov r12b, 0
        ; cast t.6{r0}(i64), i{r6}(u8)
        movzx rax, bl
        ; addrof t.5{r1}, [board]
        lea rcx, [var_0]
        ; add t.5{r1}, t.5{r1}, t.6{r0}
        add rcx, rax
        ; store [t.5{r1}], t.4{r7}
        mov [rcx], r12b
        ; add i{r6}, i{r6}, 1
        add bl, 1
_for_4:
        ; branch i{r6} lt 30: for_4_body, for_4_break
        cmp bl, 30
        jb _for_4_body
        ; const t.7{r6}, 1
        mov bl, 1
        ; const t.9{r7}, 29
        mov r12, 29
        ; addrof t.8{r0}, [board]
        lea rax, [var_0]
        ; add t.8{r0}, t.8{r0}, t.9{r7}
        add rax, r12
        ; store [t.8{r0}], t.7{r6}
        mov [rax], bl
        ; call printBoard[]
        call _printBoard
        ; const i{r6}, 0
        mov bl, 0
        ; 30:2 for i < 28
        jmp _for_5
_for_5_body:
        ; const t.13{r7}, 0
        mov r12, 0
        ; addrof t.12{r0}, [board]
        lea rax, [var_0]
        ; add t.12{r0}, t.12{r0}, t.13{r7}
        add rax, r12
        ; load t.11{r7}, [t.12{r0}]
        mov r12b, [rax]
        ; shiftleft t.10{r7}, t.10{r7}, 1
        shl r12b, 1
        ; const t.16{r0}, 1
        mov rax, 1
        ; addrof t.15{r2}, [board]
        lea rdx, [var_0]
        ; add t.15{r2}, t.15{r2}, t.16{r0}
        add rdx, rax
        ; load t.14{r0}, [t.15{r2}]
        mov al, [rdx]
        ; or pattern{r7}, pattern{r7}, t.14{r0}
        or r12b, al
        ; const j{r0}, 1
        mov al, 1
        ; 32:3 for j < 29
        jmp _for_6
_for_6_body:
        ; shiftleft t.18{r7}, t.18{r7}, 1
        shl r12b, 1
        ; and t.17{r7}, t.17{r7}, 7
        and r12b, 7
        ; move t.22{r2}, j{r0}
        mov dl, al
        ; add t.22{r2}, t.22{r2}, 1
        add dl, 1
        ; cast t.21{r2}(i64), t.22{r2}(u8)
        movzx rdx, dl
        ; addrof t.20{r3}, [board]
        lea r8, [var_0]
        ; add t.20{r3}, t.20{r3}, t.21{r2}
        add r8, rdx
        ; load t.19{r2}, [t.20{r3}]
        mov dl, [r8]
        ; or pattern{r7}, pattern{r7}, t.19{r2}
        or r12b, dl
        ; const t.25{r2}, 110
        mov dl, 110
        ; move pattern{r1}, pattern{r7}
        mov cl, r12b
        ; shiftright t.24{r2}, t.24{r2}, pattern{r1}
        shr dl, cl
        ; move t.23{r1}, t.24{r2}
        mov cl, dl
        ; and t.23{r1}, t.23{r1}, 1
        and cl, 1
        ; cast t.27{r2}(i64), j{r0}(u8)
        movzx rdx, al
        ; addrof t.26{r3}, [board]
        lea r8, [var_0]
        ; add t.26{r3}, t.26{r3}, t.27{r2}
        add r8, rdx
        ; store [t.26{r3}], t.23{r1}
        mov [r8], cl
        ; add j{r0}, j{r0}, 1
        add al, 1
_for_6:
        ; branch j{r0} lt 29: for_6_body, for_6_break
        cmp al, 29
        jb _for_6_body
        ; call printBoard[]
        call _printBoard
        ; add i{r6}, i{r6}, 1
        add bl, 1
_for_5:
        ; branch i{r6} lt 28: for_5_body, main_ret
        cmp bl, 28
        jb _for_5_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
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
        ; variable 0: board[] (u8*/240)
        var_0 rb 240

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

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
