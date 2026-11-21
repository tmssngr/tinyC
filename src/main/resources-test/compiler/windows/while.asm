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

        ; void _printChar@u8
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
        ; move t.1.1{r1}, t.1.1{r7}
        mov rcx, r12
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call _printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void _printUint@i64
        ;   rsp+80: arg number
        ;   rsp+40: var buffer
_printUint@i64:
        sub rsp, 40
        sub rsp, 32
        ; const pos.1{r0}, 20
        mov al, 20
        ; 33:2 while true
        ; move number.1{r3}, number{r1}
        mov r8, rcx
        jmp while_1
_printUint@i64.no_critical_edge_4:
        ; move pos.2{r0}, pos.3{r4}
        mov al, r9b
while_1:
        ; move pos.3{r4}, pos.2{r0}
        mov r9b, al
        ; sub pos.3{r4}, 1
        sub r9b, 1
        ; move remainder.1{r5}, number.1{r3}
        mov r10, r8
        ; move remainder.1{r0}, remainder.1{r5}
        mov rax, r10
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move remainder.1{r5}, remainder.1{r2}
        mov r10, rdx
        ; move number.2{r0}, number.2{r3}
        mov rax, r8
        ; div number.2{r0}, 10
        cqo
        mov rcx, 10
        idiv rcx
        ; move number.2{r3}, number.2{r0}
        mov r8, rax
        ; cast t.5.1{r0}(u8), remainder.1{r5}(i64)
        mov al, r10b
        ; add digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r1}(i64), pos.3{r4}(u8)
        movzx rcx, r9b
        ; addrof t.6.1{r2}, buffer
        lea rdx, [rsp+40]
        ; add t.6.2{r2}, t.7.1{r1}
        add rdx, rcx
        ; store [t.6.2{r2}], digit.1{r0}
        mov [rdx], al
        ; 39:3 if number == 0
        ; branch number.2{r3} notequals 0: _printUint@i64.no_critical_edge_4
        cmp r8, 0
        jne _printUint@i64.no_critical_edge_4
        ; move t.8.2{r1}, t.8.2{r2}
        mov rcx, rdx
        ; const t.11.1{r0}, 20
        mov al, 20
        ; move t.10.1{r2}, t.11.1{r0}
        mov dl, al
        ; sub t.10.1{r2}, pos.3{r4}
        sub dl, r9b
        ; call _printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 40
        ret

        ; void _printIntLf@u8
        ;   rsp+48: arg number
_printIntLf@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(u8)
        movzx rcx, cl
        ; call _printIntLf@i64[t.1.1{r1}]
        call _printIntLf@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void _printIntLf@i64
        ;   rsp+48: arg number
_printIntLf@i64:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; branch number{r6} gteq 0: if_3_end
        cmp rbx, 0
        jge if_3_end
        ; const arg.0.0{r1}, 45
        mov cl, 45
        ; call _printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; neg number.2{r0}, number{r6}
        mov rax, rbx
        neg rax
        ; move number.1{r6}, number.2{r0}
        mov rbx, rax
if_3_end:
        ; move number.1{r1}, number.1{r6}
        mov rcx, rbx
        ; call _printUint@i64[number.1{r1}]
        call _printUint@i64
        ; const arg.2.0{r1}, 10
        mov cl, 10
        ; call _printChar@u8[arg.2.0{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call _printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void _main
_main:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; const i.1{r0}, 5
        mov al, 5
        ; 5:2 while i > 0
        ; move i.2{r6}, i.1{r0}
        mov bl, al
        jmp while_4
while_4_body:
        ; move i.2{r1}, i.2{r6}
        mov cl, bl
        ; call _printIntLf@u8[i.2{r1}]
        call _printIntLf@u8
        ; move i.4{r0}, i.2{r6}
        mov al, bl
        ; sub i.4{r0}, 1
        sub al, 1
        ; move i.2{r6}, i.4{r0}
        mov bl, al
while_4:
        ; branch i.2{r6} gt 0: while_4_body, while_5
        cmp bl, 0
        ja while_4_body
while_5:
        ; move i.3{r1}, i.3{r6}
        mov cl, bl
        ; call _printIntLf@u8[i.3{r1}]
        call _printIntLf@u8
        ; add i.5{r6}, 1
        add bl, 1
        ; 13:3 if i < 5
        ; branch i.5{r6} lt 5: while_5
        cmp bl, 5
        jb while_5
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void _printStringLength@@u8@i64
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
